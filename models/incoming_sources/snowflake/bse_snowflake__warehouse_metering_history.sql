{{
    config(
        snowflake_warehouse=dynamic_warehouse_selection(),
        materialized='incremental',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        unique_key='dw_metering_history_id',
        full_refresh=false
    )
}}


with recent_queries as (
    select *

    {{ dynamic_source_selection(
        target_source=source('snowflake', 'account_usage__warehouse_metering_history'),
        source_time_field='start_time',
        target_time_field='dim_start_datetime'
        ) }}
),

field_transformation as (
    select
        -- primary keys & identifiers
        -- primary key for this table
        {{ dbt_utils.generate_surrogate_key(['warehouse_id', 'start_time']) }} as dw_metering_history_id,

        -- secondary/match keys by roughly ascending granularity
        warehouse_id::varchar as sf_warehouse_id,

        -- date/time dimensions
        end_time as dim_end_datetime,
        start_time as dim_start_datetime,

        -- query dimensions
        lower(warehouse_name) as dim_warehouse_name,

        -- metrics
        credits_used as met_credits_used,
        credits_used_cloud_services as met_credits_used_cloud_services,
        credits_used_compute as met_credits_used_compute,

        -- meta fields
        current_timestamp()::timestamp_tz as _dbt_processed_at
        

    from recent_queries
)

select *
from field_transformation
