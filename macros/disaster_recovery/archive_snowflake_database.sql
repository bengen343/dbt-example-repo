{#
    archive_snowflake_database

    On each run it:
      1. CLONE:  creates a new database `<<PROJECT_NAME>>_ARCHIVE_YYYYMMDD__HHMMSS`
                 and zero-copy clones every TABLE of every schema in
                 the passed database into it (Snowflake CREATE TABLE ... CLONE).
      2. PRUNE:  lists all existing `<<PROJECT_NAME>>_ARCHIVE_%` databases, buckets
                 them by age, thins each bucket down to `dbs_per_period`, and drops
                 anything that has aged out of the retention windows.

    The pruning:
      - archives are sorted most-recent-first
      - a pointer walks the list, filling one bucket per (timeframe, period) while
        the archive is newer than `now - span * period`
      - within a bucket the OLDEST `dbs_per_period` are kept, newer duplicates dropped
      - any archive older than the final window is dropped
    Month arithmetic is done by hand (with day clamping) using `modules.datetime`.

    Args:
        source_database (str): database to archive (required in practice).
        retention_timeframes (list[dict] | none): ordered retention windows. Each entry:
            {   
                'name': str,
                'span': 'days'|'weeks'|'months'|'years',
                'periods': int, 'dbs_per_period': int
            }
            Defaults to: daily for 1 week, then weekly for 8 weeks, then monthly for 1 year.

    Usage:
        dbt run-operation archive_snowflake_database --args '{source_database: MY_DATABASE}'
#}

{% macro archive_snowflake_database(source_database='', retention_timeframes=none) %}

    {% set now = modules.datetime.datetime.now() %}
    {% set archive_prefix = source_database ~ '_ARCHIVE_' %}
    {% set date_format = '%Y%m%d__%H%M%S' %}
    {% set archive_name = archive_prefix ~ now.strftime(date_format) %}

    {# -------------------------------------------------------------------- #}
    {# 1. CLONE: create the archive db, then clone every table of every schema #}
    {# -------------------------------------------------------------------- #}
    {% set create_db %} CREATE DATABASE {{ archive_name }}; {% endset %}
    {% do run_query(create_db) %}
    {% do log('Archive DB created: ' ~ archive_name, info=True) %}

    {% set show_schemas %} SHOW TERSE SCHEMAS IN DATABASE {{ source_database }}; {% endset %}
    {% set schema_results = run_query(show_schemas) %}
    {# SHOW TERSE SCHEMAS: column 1 is the schema name #}
    {% for schema in schema_results.columns[1].values() %}
        {% if schema not in ['INFORMATION_SCHEMA'] %}

            {% set create_schema %} CREATE SCHEMA IF NOT EXISTS {{ archive_name }}.{{ schema }}; {% endset %}
            {% do run_query(create_schema) %}

            {% set show_tables %} SHOW TERSE TABLES IN SCHEMA {{ source_database }}.{{ schema }}; {% endset %}
            {% set table_results = run_query(show_tables) %}
            {% set table_count = namespace(n=0) %}
            {# SHOW TERSE TABLES: column 1 is the table name #}
            {% for table in table_results.columns[1].values() %}
                {% set clone_table %}
                    CREATE TABLE {{ archive_name }}.{{ schema }}.{{ table }}
                    CLONE {{ source_database }}.{{ schema }}.{{ table }};
                {% endset %}
                {% do run_query(clone_table) %}
                {% set table_count.n = table_count.n + 1 %}
            {% endfor %}

            {% do log(archive_name ~ '.' ~ schema ~ ' cloned (' ~ table_count.n ~ ' tables)', info=True) %}
        {% endif %}
    {% endfor %}

    {# -------------------------------------------------------------------- #}
    {# 2. PRUNE: thin out archives that have aged past the retention windows  #}
    {# -------------------------------------------------------------------- #}
    {% set retention = retention_timeframes if retention_timeframes is not none else [
        {'name': '1_week',  'span': 'days',   'periods': 7,  'dbs_per_period': 1},
        {'name': '8_weeks', 'span': 'weeks',  'periods': 8,  'dbs_per_period': 1},
        {'name': '1_year',  'span': 'months', 'periods': 12, 'dbs_per_period': 1}
    ] %}

    {# gather existing archives and parse their timestamp suffix into datetimes #}
    {% set show_archives %} SHOW TERSE DATABASES LIKE '{{ archive_prefix }}%'; {% endset %}
    {% set archive_results = run_query(show_archives) %}
    {% set db_datetimes = [] %}
    {% for db_name in archive_results.columns[1].values() %}
        {% set suffix = db_name.split(archive_prefix)[-1] %}
        {% do db_datetimes.append(modules.datetime.datetime.strptime(suffix, date_format)) %}
    {% endfor %}
    {# most recent first, matching RemoveDatabaseArchive #}
    {% set db_datetimes = db_datetimes | sort(reverse=True) %}
    {% set total = db_datetimes | length %}

    {% set drop_dbs = [] %}
    {% set ptr = namespace(i=0, done=false) %}

    {% for tf in retention %}
        {% for period in range(1, tf.periods + 1) %}
            {% if not ptr.done %}

                {# boundary = now - (span * period); anything newer belongs in this period #}
                {% if tf.span == 'weeks' %}
                    {% set boundary = now - modules.datetime.timedelta(weeks=period) %}
                {% elif tf.span == 'days' %}
                    {% set boundary = now - modules.datetime.timedelta(days=period) %}
                {% else %}
                    {# months / years: subtract calendar months, clamp the day to the month #}
                    {# length (avoids building an invalid date like Feb 30). February is treated #}
                    {# as 28 days -- leap-year precision isn't needed for retention bucketing. #}
                    {% set months_back = period * (12 if tf.span == 'years' else 1) %}
                    {% set month_index = now.year * 12 + (now.month - 1) - months_back %}
                    {% set b_year = month_index // 12 %}
                    {% set b_month = (month_index % 12) + 1 %}
                    {% set days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] %}
                    {% set max_day = days_in_month[b_month - 1] %}
                    {% set b_day = now.day if now.day <= max_day else max_day %}
                    {% set boundary = modules.datetime.datetime(b_year, b_month, b_day, now.hour, now.minute, now.second) %}
                {% endif %}

                {# consume consecutive archives that fall inside this period #}
                {% set bucket = [] %}
                {% set stop = namespace(v=false) %}
                {% for _ in range(total) %}
                    {% if not stop.v and not ptr.done and boundary < db_datetimes[ptr.i] %}
                        {% do bucket.append(db_datetimes[ptr.i]) %}
                        {% set ptr.i = ptr.i + 1 %}
                        {% if ptr.i == total %}{% set ptr.done = true %}{% endif %}
                    {% else %}
                        {% set stop.v = true %}
                    {% endif %}
                {% endfor %}

                {# keep the oldest `dbs_per_period`; drop the newer surplus (bucket is newest-first) #}
                {% if bucket | length > tf.dbs_per_period %}
                    {% set surplus = (bucket | length) - tf.dbs_per_period %}
                    {% for d in bucket[:surplus] %}
                        {% do drop_dbs.append(d) %}
                    {% endfor %}
                {% endif %}

            {% endif %}
        {% endfor %}
    {% endfor %}

    {# anything older than the final retention window is dropped outright #}
    {% if ptr.i < total %}
        {% for d in db_datetimes[ptr.i:] %}
            {% do drop_dbs.append(d) %}
        {% endfor %}
    {% endif %}

    {% for d in drop_dbs %}
        {% set drop_name = archive_prefix ~ d.strftime(date_format) %}
        {% set drop_db %} DROP DATABASE IF EXISTS {{ drop_name }}; {% endset %}
        {% do run_query(drop_db) %}
        {% do log('Dropped expired archive: ' ~ drop_name, info=True) %}
    {% endfor %}

    {% do log('Pruning complete: dropped ' ~ (drop_dbs | length) ~ ' archive(s), ' ~ (total - (drop_dbs | length)) ~ ' remain', info=True) %}

{% endmacro %}
