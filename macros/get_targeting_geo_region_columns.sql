{% macro get_targeting_geo_region_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "country_id", "datatype": dbt.type_string()},
    {"name": "region_id", "datatype": dbt.type_string()},
    {"name": "region_name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
