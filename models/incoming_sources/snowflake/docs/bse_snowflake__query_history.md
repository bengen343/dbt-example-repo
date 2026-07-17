{% docs bse_snowflake__query_history %}

## Base Table: Query History

### About This Table
This is the Bronze layer "base" model for Snowflake's internally generated `query_history` table, sourced from the account's `account_usage` share. As part of our first processing layer, this base model standardizes the raw query history into a structured format ready for downstream transformation.

Every row in this model represents a single query executed against the Snowflake account, along with the performance and resource-consumption statistics Snowflake records for it. The underlying source retains roughly the last two weeks of query activity.

The most important function of this model is to unpack the additional dbt metadata that is injected into the `query_tag` field so the performance of dbt models can be monitored and optimized. Fields such as the dbt invocation identifier, model name, package name, materialization, and referenced models are parsed out of the tag and promoted to their own typed columns.

### Role in Medallion Architecture
This model operates in the **Bronze layer** of our Medallion Architecture. Base models serve as the first point of data transformation in Snowflake where we:
- Ingest data from source systems, in this case Snowflake's own `account_usage` views.
- Apply standardization to field names following our conventions.
- Unpack fields stored in JSON, such as `query_tag`, into their own typed table columns.
- Apply uniform formatting and data type casting to any data being ingested.

The goal of the Bronze layer is to create a standardized copy of the source data without modifying the underlying business logic or values. This model does not aggregate, filter, or join data, it simply restructures it for downstream consumption.

### Data Source & Lineage
**Primary Source:**
- **Source System**: Snowflake `account_usage.query_history` view, referenced as `account_usage__query_history`.
- **Ingestion Method**: Direct query against the `account_usage` share.
- **Sync Strategy**: Incremental updates filtered on `start_time` via the `dynamic_source_selection` macro.

### Data Structure & Key Transformations
This model performs several critical standardization transformations:

**Field Naming & Prefixes:**
- `sf_*`: Snowflake identifiers (query, transaction, session, schema, warehouse, and database keys).
- `dbt_invocation_id`: The dbt-generated identifier for the invocation that ran the query, parsed from `query_tag`.
- `dim_*`: Dimensional attributes (execution status, query type, role, warehouse, and the dbt materialization and model dimensions).
- `is_*`: Boolean flags such as `is_full_refresh` and `is_client_generated_statement`.
- `met_*`: Metric fields containing numeric values (bytes, credits, row counts, and millisecond timings).
- `info_*`: High-cardinality or complex fields (query text, query hashes, error messages, and JSON payloads).

**dbt Metadata Extraction:**
- Parses the JSON `query_tag` to surface the dbt invocation, model name, package name, incremental strategy, materialization type, and executing user.
- Extracts the referenced models, sources, and tags of the model being built into VARIANT `info_*` fields.
- Derives `is_full_refresh` from the model comment embedded in the query text.

**Data Quality:**
- Applies lowercase standardization to text dimensions for consistency.
- Nullifies empty strings extracted from JSON with `nullif`.
- Casts identifiers to VARCHAR and preserves complex structures as VARIANT for downstream flexibility.

### Technical Notes
- Materialized as an **incremental** model using the `delete+insert` strategy with a `unique_key` of `sf_query_id` and `on_schema_change='append_new_columns'`.
- Configured with `full_refresh=false` because the underlying `account_usage` view only retains a rolling window of history.
- Uses the **dynamic warehouse selection** macro to optimize compute resource allocation.
- Employs the **dynamic source selection** macro for intelligent incremental filtering on `start_time`.
- Processing timestamp captured in `_dbt_processed_at` for dbt execution tracking.

### Downstream Dependencies
This base model serves as a building block for infrastructure monitoring, most notably:
- `fct_dbt_model_invocations`, which aggregates these query records to the dbt model invocation grain and allocates warehouse cost.

{% enddocs %}
