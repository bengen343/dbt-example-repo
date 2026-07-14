{% docs bse_snowflake__query_history %}

## Base Table: Query History

### About This Table
This is the "base" model for Snowflake's internally generated 'query_history' table. The underlying table contains a record of every query performed in the past two weeks and its performance.

The most important function of this model is to unpack additional dbt metadata that is injected into the 'query_tag' field so the performance of dbt models can be monitored and optimized.

"Base" models serve as the first point of data transformation in Snowflake. This model unpacks fields stored in JSON to their own table columns, names the columns according to standards, and applies uniform formatting to any data being ingested.

{% enddocs %}
