{% test table_equality(model, compare_model, compare_columns=None, exclude_columns=None, precision = None) %}
    {{ config(enabled = (target.name == "test")) }}
    {{ dbt_utils.default__test_equality(model, compare_model, compare_columns, exclude_columns, precision) }}
{% endtest %}