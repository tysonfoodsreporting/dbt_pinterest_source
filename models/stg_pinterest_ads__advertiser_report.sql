{{ config(enabled=var('ad_reporting__pinterest_ads_enabled', True),
    unique_key = ['source_relation','advertiser_id','date_day'],
    partition_by={
      "field": "date_day", 
      "data_type": "TIMESTAMP",
      "granularity": "day"
    }
    ) }}
with base as (

    select * 
    from {{ ref('stg_pinterest_ads__advertiser_report_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pinterest_ads__advertiser_report_tmp')),
                staging_columns=get_advertiser_report_columns()
            )
        }}
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='pinterest_ads_union_schemas', 
            union_database_variable='pinterest_ads_union_databases') 
        }}

    from base
),

final as (

    select
        source_relation, 
        TIMESTAMP(DATETIME(TIMESTAMP(date), "America/Chicago")) as date_day,
        cast(advertiser_id as {{ dbt.type_string() }}) as advertiser_id,
        coalesce(impression_1,0) + coalesce(impression_2,0) as impressions,
        coalesce(clickthrough_1,0) + coalesce(clickthrough_2,0) as clicks,
        coalesce(spend_in_micro_dollar, 0) / 1000000.0 as spend,
        coalesce(total_conversions, 0) as total_conversions,
        coalesce(total_conversions_quantity, 0) as total_conversions_quantity,
        coalesce(total_conversions_value_in_micro_dollar, 0) / 1000000.0 as total_conversions_value

        {{ pinterest_ads_fill_pass_through_columns(pass_through_fields=var('pinterest__advertiser_report_passthrough_metrics'), except=['total_conversions','total_conversions_quantity','total_conversions_value']) }}

    from fields
)

select *
from final
