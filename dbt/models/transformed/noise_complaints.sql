{{
    config(
        materialized='incremental'
    )
}}

with clean_data as (
  select *
  from {{ ref('clean_data') }}
)

select 
  date_created,
  
{% for type in ["Noise - Residential", "Noise - Commercial"] %}
  sum(case when complaint_type = '{{type}}' then 1 else 0 end) as {{ type.lower().split(' ')[2] }},
{% endfor %}

  count("*") as all_complaints 
from clean_data
where complaint_type like "Noise%"

{% if is_incremental() %}
  and timestamp_created > (select max(timestamp_created) from {{ this }})
{% endif %}

group by 1
order by 1 asc

