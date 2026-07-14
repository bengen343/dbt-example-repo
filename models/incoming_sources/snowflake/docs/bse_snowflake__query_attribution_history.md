{% docs bse_snowflake__query_attribution_history %}

## Base Table: Query Attribution History

### About This Table
This is the "base" model for Snowflake's internally generated 'query_attribution_history' table. The underlying table contains a record of every query performed in the past two weeks and the estimated snowflake credit consumption of those queries.

"Base" models serve as the first point of data transformation in Snowflake. This model unpacks fields stored in JSON to their own table columns, names the columns according to standards, and applies uniform formatting to any data being ingested.

{% enddocs %}
