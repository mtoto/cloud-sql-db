with noises as (
  select *
  from {{ ref('noise_complaints') }}
)

select date_created, residential, 
       {{ rolling_avg('residential','date_created', 7) }}
from noises