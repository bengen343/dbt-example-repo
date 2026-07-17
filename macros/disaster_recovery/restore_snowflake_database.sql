{#
    restore_snowflake_database

    The reverse of archive_snowflake_database. Takes an archive database created by
    that macro and restores its contents back into an EXISTING destination database,
    overwriting the destination's tables in place while preserving grants so external
    systems do not lose access.

    Grant-preservation strategy (the whole point of this macro):
      - DATABASE grants: the destination database object is never dropped or replaced,
        so its grants are left completely untouched.
      - SCHEMA grants: destination schemas are never replaced -- CREATE SCHEMA IF NOT
        EXISTS is a no-op when the schema already exists -- so their grants are preserved.
      - TABLE grants: each table is rebuilt with
            CREATE OR REPLACE TABLE <dest> CLONE <archive> COPY GRANTS
        When a statement both replaces and clones, COPY GRANTS gives precedence to the
        table being REPLACED (the destination table), so downstream roles keep exactly
        the access they had -- the archive's own grants are ignored.

    Note: a single CREATE OR REPLACE DATABASE ... CLONE ... COPY GRANTS is deliberately
    NOT used, because COPY GRANTS is not recursive -- it would preserve only the
    database-level grants and drop every schema/table grant underneath.

    Scope:
      - Only tables are restored (the archive macro only clones tables).
      - Tables/schemas that exist in the destination but NOT in the archive are left
        as-is; this macro overwrites, it does not mirror-and-prune.

    Args:
        archive_database (str): the *_ARCHIVE_YYYYMMDD__HHMMSS database to restore from.
        destination_database (str): the existing database to overwrite. Must already exist.

    Usage:
        dbt run-operation restore_snowflake_database --args '{archive_database: MY_DATABASE_ARCHIVE_20260101__120000, destination_database: MY_DATABASE}'
#}

{% macro restore_snowflake_database(archive_database='', destination_database='') %}

    {% do log('Restoring ' ~ destination_database ~ ' from archive ' ~ archive_database, info=True) %}

    {% set show_schemas %} SHOW TERSE SCHEMAS IN DATABASE {{ archive_database }}; {% endset %}
    {% set schema_results = run_query(show_schemas) %}
    {# SHOW TERSE SCHEMAS: column 1 is the schema name #}
    {% for schema in schema_results.columns[1].values() %}
        {% if schema not in ['INFORMATION_SCHEMA'] %}

            {# ensure the schema exists in the destination WITHOUT replacing it, so any #}
            {# existing schema-level grants are preserved (no-op when it already exists) #}
            {% set create_schema %} CREATE SCHEMA IF NOT EXISTS {{ destination_database }}.{{ schema }}; {% endset %}
            {% do run_query(create_schema) %}

            {% set show_tables %} SHOW TERSE TABLES IN SCHEMA {{ archive_database }}.{{ schema }}; {% endset %}
            {% set table_results = run_query(show_tables) %}
            {% set table_count = namespace(n=0) %}
            {# SHOW TERSE TABLES: column 1 is the table name #}
            {% for table in table_results.columns[1].values() %}
                {# OR REPLACE overwrites the destination table's structure + content from #}
                {# the archive; COPY GRANTS retains the grants of the table being replaced #}
                {# (the destination table), not the archive source. #}
                {% set restore_table %}
                    CREATE OR REPLACE TABLE {{ destination_database }}.{{ schema }}.{{ table }}
                    CLONE {{ archive_database }}.{{ schema }}.{{ table }}
                    COPY GRANTS;
                {% endset %}
                {% do run_query(restore_table) %}
                {% set table_count.n = table_count.n + 1 %}
            {% endfor %}

            {% do log(destination_database ~ '.' ~ schema ~ ' restored (' ~ table_count.n ~ ' tables)', info=True) %}
        {% endif %}
    {% endfor %}

    {% do log('Restore of ' ~ destination_database ~ ' complete', info=True) %}

{% endmacro %}
