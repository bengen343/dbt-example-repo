{{
    config(
        snowflake_warehouse=dynamic_warehouse_selection(),
        materialized='incremental',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        unique_key='sf_query_id',
        full_refresh=false
    )
}}


with recent_queries as (
    select *

    {{ dynamic_source_selection(
        target_source=source('snowflake', 'account_usage__query_attribution_history'),
        source_time_field='start_time',
        target_time_field='dim_start_datetime'
        ) }}
),

field_transformation as (
    select
        -- primary keys & identifiers
        -- primary key for this table
        query_id as sf_query_id,

        -- secondary/match keys by roughly ascending granularity
        parent_query_id as sf_parent_query_id,
        root_query_id as sf_root_query_id,
        try_parse_json(query_tag):dbt_invocation_id::varchar as dbt_invocation_id,
        warehouse_id::varchar as sf_warehouse_id,

        -- date/time dimensions
        end_time as dim_end_datetime,
        start_time as dim_start_datetime,

        -- dbt dimensions
        try_parse_json(query_tag):dbt_incremental_strategy::varchar as dim_incremental_strategy_dbt,
        try_parse_json(query_tag):dbt_materialization_type::varchar as dim_materialization_dbt,
        try_parse_json(query_tag):dbt_model_name::varchar as dim_model_name_dbt,
        try_parse_json(query_tag):dbt_package_name::varchar as dim_package_name_dbt,
        lower(try_parse_json(query_tag):dbt_user_name)::varchar as dim_user_name_dbt,

        -- dbt info
        try_parse_json(try_parse_json(query_tag):dbt_model_refs) as info_refs_dbt,
        try_parse_json(try_parse_json(query_tag):dbt_model_sources) as info_sources_dbt,
        try_parse_json(try_parse_json(query_tag):dbt_model_tags) as info_tags_dbt,

        -- query dimensions
        lower(user_name) as dim_user_name_snowflake,
        lower(warehouse_name) as dim_warehouse_name,

        -- query metrics
        credits_attributed_compute as met_credits_attributed_compute,
        credits_used_query_acceleration as met_credits_used_query_acceleration,

        -- info fields
        query_hash as info_query_hash,
        query_parameterized_hash as info_query_parameterized_hash,
        query_tag as info_query_tag,

        -- meta fields
        current_timestamp()::timestamp_tz as _dbt_processed_at

    from recent_queries
)

select *
from field_transformation
