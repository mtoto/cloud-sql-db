{{
    config(
        materialized='incremental'
    )
}}

select 
  created_date as timestamp_created,
  date( created_date ) as date_created,
  time( created_date ) as time_created,
  created_date as date_time,
  unique_key as id,
  agency,
  agency_name,
  complaint_type,
  descriptor as complaint_description,
  resolution_description,
  incident_zip as zip_code,
  coalesce(intersection_street_1, street_name) as street,
  borough
from `dbt-sql.311raw.data` 

{% if is_incremental() %}
  where created_date > (select max(created_date) from {{ this }})
{% endif %}