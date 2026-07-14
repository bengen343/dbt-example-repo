{%- macro set_query_tag() -%}
  
  
  {%- set dbt_invocation_id = invocation_id -%}
  {%- set dbt_user_name = target.user -%}
  {%- set dbt_model_name = model.name -%}
  {%- set dbt_schema_name = model.schema -%}
  {%- set dbt_package_name = model.package_name -%}
  {%- set dbt_materialization_type = model.config.materialized -%}
  {%- set dbt_incremental_strategy = model.config.incremental_strategy -%}
  {%- set dbt_model_sources = model.sources -%}
  {%- set dbt_model_refs = model.refs -%}
  {%- set dbt_model_tags = model.tags -%}
  

  {%- if dbt_model_name -%}
    {%- if dbt_model_refs|string|length > 1000 -%}
      {%- set dbt_model_refs = '[]' -%}
    {%- endif -%}

    {%- set new_query_tag = "{'dbt_invocation_id': '%s', 'dbt_user_name': '%s', 'dbt_model_name': '%s', 'dbt_schema_name': '%s', 'dbt_package_name': '%s', 'dbt_materialization_type': '%s', 'dbt_incremental_strategy': '%s'}"
      | format(
                
                dbt_invocation_id,
                dbt_user_name,
                dbt_model_name,
                dbt_schema_name,
                dbt_package_name,
                dbt_materialization_type,
                dbt_incremental_strategy
    ) -%}
    {%- set original_query_tag = get_current_query_tag() -%}
    {{ log('Setting query_tag to '' ~ new_query_tag ~ ''. Will reset to '' ~ original_query_tag ~ '' after materialization.') }}
    {%- do run_query('alter session set query_tag = "{}"'.format(new_query_tag)) -%}
    {{ return(original_query_tag)}}
  
  {%- endif -%}
  
  {{ return(none) }}

{%- endmacro -%}