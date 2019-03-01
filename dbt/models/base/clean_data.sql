{{
    config(
        materialized='incremental'
    )
}}

select 
  datetime(created_date, "America/New_York") as datetime_created,
  date( created_date, "America/New_York" ) as date_created,
  time( created_date, "America/New_York" ) as time_created,
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
  where created_date > (select max(timestamp_created) from {{ this }})
{% endif %}