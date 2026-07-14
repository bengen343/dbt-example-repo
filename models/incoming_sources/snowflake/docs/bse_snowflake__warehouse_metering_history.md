{% docs bse_snowflake__warehouse_metering_history %}

## Base Table: Warehouse Metering History

### About This Table
This is the "base" model for Snowflake's internally generated 'warehouse_metering_history' table.  The underlying table contains a record of the credit usage warehouses have accumulated.

The most important function of this model is to be able to run queries to return the hourly credit usage for a single warehouse (or all the warehouses) within the last 365 days (1 year).

"Base" models serve as the first point of data transformation in Snowflake. This model unpacks fields stored in JSON to their own table columns, names the columns according to standards, and applies uniform formatting to any data being ingested.

{% enddocs %}
