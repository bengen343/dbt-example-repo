{% docs bse_snowflake__query_attribution_history %}

## Base Table: Query Attribution History

### About This Table
This is the Bronze layer "base" model for Snowflake's internally generated `query_attribution_history` table, sourced from the account's `account_usage` share. As part of our first processing layer, this base model standardizes the raw attribution history into a structured format ready for downstream transformation.

Every row in this model represents a single query executed against the Snowflake account together with the compute credits Snowflake attributes to it. Unlike `bse_snowflake__query_history`, which captures broad performance statistics, this model focuses on the estimated credit consumption of each query. The underlying source retains roughly the last two weeks of query activity.

Like the query history model, this base model also unpacks the dbt metadata injected into the `query_tag` field so attributed credit consumption can be tied back to the dbt model that incurred it.

### Role in Medallion Architecture
This model operates in the **Bronze layer** of our Medallion Architecture. Base models serve as the first point of data transformation in Snowflake where we:
- Ingest data from source systems, in this case Snowflake's own `account_usage` views.
- Apply standardization to field names following our conventions.
- Unpack fields stored in JSON, such as `query_tag`, into their own typed table columns.
- Apply uniform formatting and data type casting to any data being ingested.

The goal of the Bronze layer is to create a standardized copy of the source data without modifying the underlying business logic or values. This model does not aggregate, filter, or join data, it simply restructures it for downstream consumption.

### Data Source & Lineage
**Primary Source:**
- **Source System**: Snowflake `account_usage.query_attribution_history` view, referenced as `account_usage__query_attribution_history`.
- **Ingestion Method**: Direct query against the `account_usage` share.
- **Sync Strategy**: Incremental updates filtered on `start_time` via the `dynamic_source_selection` macro.

### Data Structure & Key Transformations
This model performs several critical standardization transformations:

**Field Naming & Prefixes:**
- `sf_*`: Snowflake identifiers (the query key plus the parent, root, and warehouse keys used to relate a query to its retries and hierarchy).
- `dbt_invocation_id`: The dbt-generated identifier for the invocation that ran the query, parsed from `query_tag`.
- `dim_*`: Dimensional attributes (warehouse and executing users, plus the dbt materialization and model dimensions).
- `met_*`: Metric fields containing the compute credits attributed to the query and the credits used for query acceleration.
- `info_*`: High-cardinality or complex fields (query hashes and the JSON `query_tag` payload).

**dbt Metadata Extraction:**
- Parses the JSON `query_tag` to surface the dbt invocation, model name, package name, incremental strategy, materialization type, and executing user.
- Extracts the referenced models, sources, and tags of the model being built into VARIANT `info_*` fields.

**Data Quality:**
- Applies lowercase standardization to text dimensions for consistency.
- Casts identifiers to VARCHAR and preserves complex structures as VARIANT for downstream flexibility.

### Technical Notes
- Materialized as an **incremental** model using the `delete+insert` strategy with a `unique_key` of `sf_query_id` and `on_schema_change='append_new_columns'`.
- Configured with `full_refresh=false` because the underlying `account_usage` view only retains a rolling window of history.
- Uses the **dynamic warehouse selection** macro to optimize compute resource allocation.
- Employs the **dynamic source selection** macro for intelligent incremental filtering on `start_time`.
- Processing timestamp captured in `_dbt_processed_at` for dbt execution tracking.

### Downstream Dependencies
This base model serves as a building block for infrastructure monitoring, most notably:
- `fct_dbt_model_invocations`, which joins the attributed compute credits recorded here onto each query by `sf_query_id`.

{% enddocs %}
