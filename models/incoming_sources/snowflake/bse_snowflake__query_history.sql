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
        target_source=source('snowflake', 'account_usage__query_history'),
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
        nullif(try_parse_json(query_tag):dbt_invocation_id::varchar, '') as dbt_invocation_id,
        transaction_id::varchar as sf_transaction_id,
        session_id::varchar as sf_session_id,
        schema_id::varchar as sf_schema_id,
        warehouse_id::varchar as sf_warehouse_id,
        database_id::varchar as sf_database_id,

        -- date/time dimensions
        end_time as dim_end_datetime,
        start_time as dim_start_datetime,

        -- dbt dimensions
        nullif(try_parse_json(query_tag):dbt_incremental_strategy::varchar, '') as dim_incremental_strategy_dbt,
        nullif(try_parse_json(query_tag):dbt_materialization_type::varchar, '') as dim_materialization_dbt,
        nullif(try_parse_json(query_tag):dbt_model_name::varchar, '') as dim_model_name_dbt,
        nullif(try_parse_json(query_tag):dbt_package_name::varchar, '') as dim_package_name_dbt,
        lower(nullif(try_parse_json(query_tag):dbt_user_name, ''))::varchar as dim_user_name_dbt,
        try_to_boolean(nullif(try_parse_json(regexp_substr(query_text, '/\\*(.*?)(\\*/|\\*/;)$', 1, 1, 'e')):is_full_refresh::varchar, '')) as is_full_refresh,

        -- dbt info
        nullif(try_parse_json(try_parse_json(query_tag):dbt_model_refs), '') as info_refs_dbt,
        nullif(try_parse_json(try_parse_json(query_tag):dbt_model_sources), '') as info_sources_dbt,
        nullif(try_parse_json(try_parse_json(query_tag):dbt_model_tags), '') as info_tags_dbt,

        -- query dimensions
        cluster_number as dim_cluster_number,
        lower(database_name) as dim_database_name,
        error_code as dim_error_code,
        lower(execution_status) as dim_execution_status,
        lower(outbound_data_transfer_cloud) as dim_outbound_cloud_transfer,
        lower(outbound_data_transfer_region) as dim_outbound_region_transfer,
        lower(query_type) as dim_query_type,
        release_version as dim_release_version,
        lower(role_name) as dim_role_name,
        lower(role_type) as dim_role_type,
        lower(schema_name) as dim_schema_name,
        lower(user_name) as dim_user_name_snowflake,
        lower(warehouse_name) as dim_warehouse_name,
        lower(warehouse_size) as dim_warehouse_size,
        lower(warehouse_type) as dim_warehouse_type,

        -- boolean dimensions
        is_client_generated_statement,

        -- metrics
        bytes_deleted as met_bytes_deleted,
        bytes_read_from_result as met_bytes_read_from_result,
        bytes_scanned as met_bytes_scanned,
        bytes_sent_over_the_network as met_bytes_sent_over_network,
        bytes_spilled_to_local_storage as met_bytes_spilled_to_local_storage,
        bytes_spilled_to_remote_storage as met_bytes_spilled_to_remote_storage,
        bytes_written as met_bytes_written,
        bytes_written_to_result as met_bytes_written_to_result,
        child_queries_wait_time as met_child_queries_wait_millis,
        compilation_time as met_compilation_millis,
        credits_used_cloud_services as met_credits_used_cloud,
        execution_time as met_execution_millis,
        external_function_total_invocations as met_external_function_invocations,
        external_function_total_received_rows as met_external_function_received_rows,
        external_function_total_received_bytes as met_external_function_received_bytes,
        external_function_total_sent_bytes as met_external_function_sent_bytes,
        external_function_total_sent_rows as met_external_function_sent_rows,
        fault_handling_time as met_fault_handling_millis,
        inbound_data_transfer_cloud as met_inbound_cloud_transfer,
        inbound_data_transfer_region as met_inbound_region_transfer,
        inbound_data_transfer_bytes as met_inbound_transfer_bytes,
        list_external_files_time as met_list_external_files_millis,
        outbound_data_transfer_bytes as met_outbound_transfer_bytes,
        partitions_scanned as met_partitions_scanned,
        partitions_total as met_partitions_total,
        percentage_scanned_from_cache as met_percent_scanned_from_cache,
        query_acceleration_bytes_scanned as met_query_acceleration_bytes_scanned,
        query_acceleration_upper_limit_scale_factor as met_query_acceleration_upper_limit_scale_factor,
        query_acceleration_partitions_scanned as met_query_acceleration_partitions_scanned,
        query_load_percent as met_query_load_percent,
        query_retry_time as met_query_retry_millis,
        queued_provisioning_time as met_queued_provisioning_millis,
        queued_repair_time as met_queued_overload_millis,
        rows_deleted as met_rows_deleted,
        rows_inserted as met_rows_inserted,
        rows_produced as met_rows_produced,
        rows_unloaded as met_rows_unloaded,
        rows_updated as met_rows_updated,
        rows_written_to_result as met_rows_written_to_result,
        total_elapsed_time as met_total_elapsed_millis,
        transaction_blocked_time as met_transaction_blocked_millis,

        -- info fields
        lower(error_message) as info_error_message,
        query_hash as info_query_hash,
        query_hash_version as info_query_hash_version,
        query_parameterized_hash as info_query_parameterized_hash,
        query_parameterized_hash_version as info_query_parameterized_hash_version,
        lower(query_retry_cause) as info_query_retry_cause,
        query_tag as info_query_tag,
        lower(query_text) as info_query_text,
        nullif(try_parse_json(secondary_role_stats), '') as info_secondary_role_stats,

        -- meta fields
        current_timestamp()::timestamp_tz as _dbt_processed_at

    from recent_queries
)

select *
from field_transformation
