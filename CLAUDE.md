# Claude Code Instructions for dbt-example-repo

## Project Context
This is a dbt project using dbt Fusion + Snowflake. It follows a Medallion Architecture (Bronze/Silver/Gold) with strict naming conventions. All development occurs inside a VSCode Dev Container.

---

## Model Naming

1. All models use a prefix that matches their architectural layer, followed by `_`, then the model name in snake_case (plural where possible):
   - `bse_` — Base (Bronze): raw source ingestion, minimal transformation
   - `int_` — Intermediate (Silver): joins, pivots, reshaping within a domain
   - `ent_` — Entity (Silver): all attributes of a business entity (dimension analogue)
   - `fct_` — Fact (Silver): immutable records of a single action type
   - `act_` — Activity (Silver): multi-type immutable event records
   - `brg_` — Bridge (Silver): join-resolution tables (keys only)
   - `scd_` — Slowly Changing Dimension (Silver): historic snapshots of entities
   - `mrt_` — Mart (Gold): denormalized BI-facing tables with business logic
   - `elt_` — Reverse ELT (Gold): tables shaped for export to external systems
   - `dte_` — Calendar (Gold): pre-aggregated daily metrics

2. Base model names must follow the formula exactly: `bse_<source_system>__<table_name>` (double underscore between source and table). Example: `bse_mongo__policy_policy`.

---

## Field Naming

3. All output fields must use a semantic prefix:
   - `dim_*` — Dimensional attributes for grouping/filtering (<500 distinct values)
   - `met_*` — Numeric metrics where aggregation (sum/avg) is meaningful
   - `info_*` — High-cardinality or complex fields (names, JSON, descriptions)
   - `is_*` — Boolean flags

4. ID/key fields use a two-letter source-system prefix instead of `dim_`/`met_`. Examples: `a0_` (Auth0), `sf_` (Snowflake), `dw_` (data warehouse).

5. Internal dbt metadata fields are prefixed with `_`: `_dbt_processed_at`, `_fivetran_synced`, `_fivetran_deleted`.

6. Every model's final `SELECT` must order columns in this sequence:
   1. IDs / Keys / Identifiers
   2. Date/Time Dimensions
   3. `dim_*` fields (alphabetical)
   4. `is_*` fields (alphabetical)
   5. `met_*` fields (alphabetical)
   6. `info_*` fields (alphabetical)
   7. Meta fields (`_dbt_processed_at`, `_fivetran_*` etc.)

---

## SQL & Model Structure

7. Every model's first line must be a `config()` block with `snowflake_warehouse=dynamic_warehouse_selection()`.

8. Use CTEs rather than subqueries. The final statement is always `select * from <last_cte>`. Name the final transformation CTE `field_transformation` or `field_selection`.

9. For large models, wrap logical field groups in `--#region <group name>` / `--#endregion <group name>` comments.

10. Always cast `current_timestamp()` as `timestamp_tz` when adding `_dbt_processed_at`.

11. Use `{{ ref('model_name') }}` for model references and `{{ source('source', 'table') }}` for raw sources. Never hardcode database/schema/table paths.

12. Use `{{ dbt_utils.star(from=ref('model'), except=['col1','col2']) }}` when selecting most columns from an upstream model.

---

## Materialization & Incremental Strategy

13. Base (`bse_`) models that ingest large, append-only source tables should be `incremental` with `incremental_strategy='delete+insert'` and a `unique_key`. Set `on_schema_change='append_new_columns'`.

14. Intermediate (`int_`), entity (`ent_`), and mart (`mrt_`) models default to `materialized='table'` unless there is a specific reason otherwise.

15. For all models, use `dynamic_source_selection()` macro to limit rows processed on incremental runs.

---

## Warehouse Sizing

16. New models default to `XS_WH` (no entry needed in `generate_warehouse_sizes.sql`).

---

## Documentation & Configuration (YAML)

18. Every model must have a companion `.yml` file in a `docs/` subdirectory within the model's folder. The file describes the model and all columns with `{{ doc("field_name") }}` references where docs exist.

19. Column names in YAML files are uppercase (Snowflake convention). Example: `name: DIM_START_DATETIME`.

20. Apply `not_null` and `unique` tests to primary key columns. Apply `not_null` to `_DBT_PROCESSED_AT`.

21. Models must carry relevant `tags` in their `config` block. Use applicable tags defined in `.pre-commit-config.yaml`.

22. Any `mrt_`, `elt_`, or other model consumed outside dbt must have an `exposure` defined in its YAML file. Follow the template in `models/marts/mrt_dbt_model_invocations.yml`. Maintain roughly alphabetical field order.

---

## Misc

29. Business logic (re-categorizations, allocations, filters) belongs exclusively in Gold layer models (`mrt_`, `elt_`, `dte_`), not in Bronze or Silver layers.
