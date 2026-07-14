# Definitions for fields common to multiple source data systems.
{%docs _dbt_processed_at %}
The timestamp when dbt last processed this record.
{% enddocs %}

{%docs _fivetran_deleted %}
Boolean flag indicating if this record has been deleted in the source system, as tracked by Fivetran.
{% enddocs %}

{%docs _fivetran_synced %}
Timestamp indicating when this record was last synced by Fivetran from the source system.
{% enddocs %}

{%docs _glue_processed_at %}
Timestamp indicating when this record was last processed by AWS Glue.
{% enddocs %}
