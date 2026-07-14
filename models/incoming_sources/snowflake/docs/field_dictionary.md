# Definitions for fields ingested, renamed, created from Snowflake application source data.

{%docs dbt_invocation_id %}
A string designating the dbt-generated unique identifier for the invocation of dbt that ran this query.
{% enddocs %}

{%docs dim_cluster_number %}
The cluster (in a multi-cluster warehouse) that this statement executed on.
{% enddocs %}

{%docs dim_database_name %}
Database that was specified in the context of the query at compilation.
{% enddocs %}

{%docs dim_end_datetime %}
Statement end time (in UTC).
{% enddocs %}

{%docs dim_error_code %}
Error code, if the query returned an error.
{% enddocs %}

{%docs dim_execution_status %}
Execution status for the query. Valid values: success, fail, incident.
{% enddocs %}

{%docs dim_execution_start_datetime %}
The timestamp when query execution began (in UTC). This represents when the query started running on the warehouse, after any time spent queued.
{% enddocs %}

{%docs dim_incremental_strategy_dbt %}
A string designating the incremental strategy, if any, used by dbt. Ie 'merge', 'delete+insert'.
{% enddocs %}

{%docs dim_materialization_dbt %}
A string designating the dbt materialization type for this model. Ie, 'incremental', 'table', 'view'.
{% enddocs %}

{%docs dim_model_name_dbt %}
A string designating the dbt model name that this query was executed to build.
{% enddocs %}

{%docs dim_outbound_cloud_transfer %}
Target cloud provider for statements that unload data to another region and/or cloud.
{% enddocs %}

{%docs dim_outbound_region_transfer %}
Target region for statements that unload data to another region and/or cloud.
{% enddocs %}

{%docs dim_package_name_dbt %}
A string designating the dbt package name that contains the model this query was executed to build.
{% enddocs %}

{%docs dim_query_type %}
DML, query, etc. If the query failed, then the query type may be unknown.
{% enddocs %}

{%docs dim_release_version %}
Release version in the format of major_release.minor_release.patch_release.
{% enddocs %}

{%docs dim_role_name %}
Role that was active in the session at the time of the query.
{% enddocs %}

{%docs dim_role_type %}
Specifies whether an application, database_role, or role that executed the query.
{% enddocs %}

{%docs dim_schema_name %}
Schema that was specified in the context of the query at compilation.
{% enddocs %}

{%docs dim_start_datetime %}
Statement start time (in UTC).
{% enddocs %}

{%docs dim_user_name_dbt %}
A string designating the user name of the dbt user executing the query.
{% enddocs %}

{%docs dim_user_name_snowflake %}
Snowflake user who issued the query.
{% enddocs %}

{%docs dim_warehouse_name %}
Warehouse that the query executed on, if any.
{% enddocs %}

{%docs dim_warehouse_size %}
Size of the warehouse when this statement executed.
{% enddocs %}

{%docs dim_warehouse_type %}
Type of the warehouse when this statement executed.
{% enddocs %}

{%docs dw_metering_history_id %}
A string designating the unique identifier of the warehouse metering history. This is a composite key composed of the warehouse_id and the start_time. Since there can be multiple warehouse_id's per start_time it can lead to duplicate records.
{% enddocs %}

{%docs info_error_message %}
Error message, if the query returned an error.
{% enddocs %}

{%docs info_query_hash %}
The hash value computed based on the canonicalized SQL text.
{% enddocs %}

{%docs info_query_hash_version %}
The version of the logic used to compute 'query_hash'.
{% enddocs %}

{%docs info_query_parameterized_hash %}
The hash value computed based on the parameterized query.
{% enddocs %}

{%docs info_query_parameterized_hash_version %}
The version of the logic used to compute 'query_parameterized_hash'.
{% enddocs %}

{%docs info_query_retry_cause %}
Array of error messages for actionable errors. The array contains one error message for each query retry. If there is no query retry, the array is empty. For more information, see Query retry columns.
{% enddocs %}

{%docs info_query_tag %}
Query tag set for this statement through the QUERY_TAG session parameter.
{% enddocs %}

{%docs info_query_text %}
Text of the SQL statement. Limit is 100K characters. SQL statements containing more than 100K characters will be truncated.
{% enddocs %}

{%docs info_refs_dbt %}
A variant containing a list of the dbt models referenced by the model being built by this query.
{% enddocs %}

{%docs info_secondary_role_stats %}
A JSON-formatted string that contains three fields regarding secondary roles that were evaluated in the query: a list of secondary roles or ALL depending on the session, a count of the number of secondary roles, and the internal/system-generated ID for each secondary role. The count and number of IDs have a maximum of 50.
{% enddocs %}

{%docs info_sources_dbt %}
A variant containing a list of the dbt sources referenced by the model being built by this query.
{% enddocs %}

{%docs info_tags_dbt %}
A variant containing a list of the dbt tags assigned to the model being built by this query.
{% enddocs %}

{%docs is_client_generated_statement %}
Indicates whether the query was client-generated.
{% enddocs %}

{%docs is_full_refresh %}
A boolean designating whether or not the particular invocation of a model was a 'full refresh' of that model.
{% enddocs %}

{%docs met_bytes_deleted %}
Number of bytes deleted by the query.
{% enddocs %}

{%docs met_bytes_read_from_result %}
Number of bytes read from a result object.
{% enddocs %}

{%docs met_bytes_scanned %}
Number of bytes scanned by this statement.
{% enddocs %}

{%docs met_bytes_sent_over_network %}
Volume of data sent over the network.
{% enddocs %}

{%docs met_bytes_spilled_to_local_storage %}
Volume of data spilled to local disk.
{% enddocs %}

{%docs met_bytes_spilled_to_remote_storage %}
Volume of data spilled to remote disk.
{% enddocs %}

{%docs met_bytes_written %}
Number of bytes written (e.g. when loading into a table).
{% enddocs %}

{%docs met_bytes_written_to_result %}
Number of bytes written to a result object. For example, select * from . . . would produce a set of results in tabular format representing each field in the selection. In general, the results object represents whatever is produced as a result of the query, and met_bytes_written_to_result represents the size of the returned result.
{% enddocs %}

{%docs met_child_queries_wait_millis %}
Time (in milliseconds) to complete the cached lookup when calling a memoizable function.
{% enddocs %}

{%docs met_compilation_millis %}
Compilation time (in milliseconds).
{% enddocs %}

{%docs met_credits_attributed_compute %}
Number of credits attributed to this query. Includes only the credit usage for the query execution and doesn't include any warehouse idle time.
{% enddocs %}

{%docs met_credits_used %}
Total number of credits used for the warehouse in the hour. This is a sum of CREDITS_USED_COMPUTE and CREDITS_USED_CLOUD_SERVICES. This value does not take into account the adjustment for cloud services, and may therefore be greater than the credits that are billed. To determine how many credits were actually billed, run queries against the METERING_DAILY_HISTORY view.
{% enddocs %}

{%docs met_credits_used_cloud %}
Number of credits used for cloud services. This value does not take into account the adjustment for cloud services, and may therefore be greater than the credits that are billed. To determine how many credits were actually billed, run queries against the metering_daily_history view.
{% enddocs %}

{%docs met_credits_used_cloud_services %}
Number of credits used for cloud services in the hour.
{% enddocs %}

{%docs met_credits_used_compute %}
Number of credits used for the warehouse in the hour.
{% enddocs %}

{%docs met_credits_used_query_acceleration %}
Number of credits consumed by the Query Acceleration Service to accelerate the query. NULL if the query is not accelerated. The total cost for an accelerated query is the sum of this column and the met_credits_attributed_compute column.
{% enddocs %}

{%docs met_execution_millis %}
Execution time (in milliseconds).
{% enddocs %}

{%docs met_external_function_invocations %}
The aggregate number of times that this query called remote services. For important details, see the Usage Notes.
{% enddocs %}

{%docs met_external_function_received_bytes %}
The total number of bytes that this query received from all calls to all remote services.
{% enddocs %}

{%docs met_external_function_received_rows %}
The total number of rows that this query received from all calls to all remote services.
{% enddocs %}

{%docs met_external_function_sent_bytes %}
The total number of bytes that this query sent in all calls to all remote services.
{% enddocs %}

{%docs met_external_function_sent_rows %}
The total number of bytes that this query sent in all calls to all remote services.
{% enddocs %}

{%docs met_fault_handling_millis %}
Total execution time (in milliseconds) for query retries caused by errors that are not actionable. For more information, see Query retry columns.
{% enddocs %}

{%docs met_inbound_cloud_transfer %}
Source cloud provider for statements that load data from another region and/or cloud.
{% enddocs %}

{%docs met_inbound_region_transfer %}
Source region for statements that load data from another region and/or cloud.
{% enddocs %}

{%docs met_inbound_transfer_bytes %}
Number of bytes transferred in a replication operation from another account. The source account could be in the same region or a different region than the current account.
{% enddocs %}

{%docs met_list_external_files_millis %}
Time (in milliseconds) spent listing external files.
{% enddocs %}

{%docs met_outbound_transfer_bytes %}
Number of bytes transferred in statements that unload data from Snowflake tables.
{% enddocs %}

{%docs met_partitions_scanned %}
Number of micro-partitions scanned.
{% enddocs %}

{%docs met_partitions_total %}
Total micro-partitions of all tables included in this query.
{% enddocs %}

{%docs met_percent_scanned_from_cache %}
Percentage of data scanned from the local disk cache. The value ranges from 0.0 to 1.0. Multiply by 100 to get a true percentage.
{% enddocs %}

{%docs met_query_acceleration_bytes_scanned %}
Number of bytes scanned by the query acceleration service.
{% enddocs %}

{%docs met_query_acceleration_partitions_scanned %}
Number of partitions scanned by the query acceleration service.
{% enddocs %}

{%docs met_query_acceleration_upper_limit_scale_factor %}
Upper limit scale factor that a query would have benefited from.
{% enddocs %}

{%docs met_query_load_percent %}
The approximate percentage of active compute resources in the warehouse for this query execution.
{% enddocs %}

{%docs met_query_retry_millis %}
Total execution time (in milliseconds) for query retries caused by actionable errors. For more information, see Query retry columns.
{% enddocs %}

{%docs met_query_runtime_millis %}
Total query runtime in milliseconds, calculated as the difference between execution start time and query end time.
{% enddocs %}

{%docs met_query_runtime_seconds %}
Total query runtime in seconds, calculated as met_query_runtime_millis divided by 1000.
{% enddocs %}

{%docs met_queued_overload_millis %}
Time (in milliseconds) spent in the warehouse queue, due to the warehouse being overloaded by the current query workload.
{% enddocs %}

{%docs met_queued_provisioning_millis %}
Time (in milliseconds) spent in the warehouse queue, waiting for the warehouse compute resources to provision, due to warehouse creation, resume, or resize.
{% enddocs %}

{%docs met_rows_deleted %}
Number of rows deleted by the query.
{% enddocs %}

{%docs met_rows_inserted %}
Number of rows inserted by the query.
{% enddocs %}

{%docs met_rows_produced %}
The number of rows produced by this statement. The ROWS_PRODUCED column will be deprecated in a future release. The value in the ROWS_PRODUCED column does not always reflect the logical number of rows affected by a query. Snowflake recommends using the rows_inserted, rows_updated, rows_written_to results, or rows_deleted columns instead.
{% enddocs %}

{%docs met_rows_unloaded %}
Number of rows unloaded during data export.
{% enddocs %}

{%docs met_rows_updated %}
Number of rows updated by the query.
{% enddocs %}

{%docs met_rows_written_to_result %}
Number of rows written to a result object. For create table as select (CTAS) and all DML operations, this result is 1.
{% enddocs %}

{%docs met_total_elapsed_millis %}
Elapsed time (in milliseconds).
{% enddocs %}

{%docs met_transaction_blocked_millis %}
Time (in milliseconds) spent blocked by a concurrent DML.
{% enddocs %}

{%docs sf_database_id %}
Internal/system-generated identifier for the database that was in use.
{% enddocs %}

{%docs sf_parent_query_id %}
Query ID of the parent query or NULL if the query does not have a parent.
{% enddocs %}

{%docs sf_query_id %}
Internal/system-generated identifier for the SQL statement.
{% enddocs %}

{%docs sf_root_query_id %}
Query ID of the topmost query in the chain or NULL if the query does not have a parent.
{% enddocs %}

{%docs sf_schema_id %}
Internal/system-generated identifier for the schema that was in use.
{% enddocs %}

{%docs sf_session_id %}
Session that executed the statement.
{% enddocs %}

{%docs sf_transaction_id %}
ID of the transaction that contains the statement or 0 if the statement is not executed within a transaction.
{% enddocs %}

{%docs sf_warehouse_id %}
Internal/system-generated identifier for the warehouse that was used.
{% enddocs %}
