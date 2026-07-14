{%- macro generate_warehouse_sizes() -%}
-- This macro assigns warehouse sizes to models.
-- The first value in the array is for full-refresh, the second for incremental.

{{ return({
    "bse_snowflake__query_history": ["L_WH", "M_WH"],
    "bse_snowflake__warehouse_metering_history": ["M_WH", "XS_WH"],
    })
}}

{%- endmacro -%}
