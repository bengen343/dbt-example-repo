{% docs bse_snowflake__warehouse_metering_history %}

## Base Table: Warehouse Metering History

### About This Table
This is the Bronze layer "base" model for Snowflake's internally generated `warehouse_metering_history` table, sourced from the account's `account_usage` share. As part of our first processing layer, this base model standardizes the raw metering history into a structured format ready for downstream transformation.

Every row in this model represents the credit usage a single warehouse accumulated within a single hour. The underlying source retains roughly the last 365 days (one year) of metering history, so this model supports querying the hourly credit usage for an individual warehouse, or for all of Snowflake warehouses, over that window.

This model is the authoritative record of the credits actually billed per warehouse per hour. Downstream models use it to allocate real warehouse cost back to the individual queries and dbt models that consumed it.

### Role in Medallion Architecture
This model operates in the **Bronze layer** of our Medallion Architecture. Base models serve as the first point of data transformation in Snowflake where we:
- Ingest data from source systems, in this case Snowflake's own `account_usage` views.
- Apply standardization to field names following our conventions.
- Synchronize timestamps and apply uniform data type casting.

The goal of the Bronze layer is to create a standardized copy of the source data without modifying the underlying business logic or values. This model does not aggregate, filter, or join data, it simply restructures it for downstream consumption.

### Data Source & Lineage
**Primary Source:**
- **Source System**: Snowflake `account_usage.warehouse_metering_history` view, referenced as `account_usage__warehouse_metering_history`.
- **Ingestion Method**: Direct query against the `account_usage` share.
- **Sync Strategy**: Incremental updates filtered on `start_time` via the `dynamic_source_selection` macro.

### Data Structure & Key Transformations
This model performs several critical standardization transformations:

**Field Naming & Prefixes:**
- `dw_metering_history_id`: A data warehouse surrogate key generated from `warehouse_id` and `start_time`, serving as the primary key. Because a warehouse can produce multiple records for the same `start_time`, this key can occasionally repeat across rows.
- `sf_*`: Snowflake identifiers (the warehouse key).
- `dim_*`: Dimensional attributes (warehouse name and the hourly start and end timestamps).
- `met_*`: Metric fields containing the credits used, credits used for cloud services, and credits used for compute.

**Data Quality:**
- Applies lowercase standardization to the warehouse name for consistency.
- Casts identifiers to VARCHAR.

### Technical Notes
- Materialized as an **incremental** model using the `delete+insert` strategy with a `unique_key` of `dw_metering_history_id` and `on_schema_change='append_new_columns'`.
- Configured with `full_refresh=false` because the underlying `account_usage` view only retains a rolling window of history.
- Uses the **dynamic warehouse selection** macro to optimize compute resource allocation.
- Employs the **dynamic source selection** macro for intelligent incremental filtering on `start_time`.
- Processing timestamp captured in `_dbt_processed_at` for dbt execution tracking.

### Downstream Dependencies
This base model serves as a building block for infrastructure monitoring, most notably:
- `fct_dbt_model_invocations`, which uses the billed hourly credits recorded here to allocate real compute cost to individual queries and dbt models.

{% enddocs %}
