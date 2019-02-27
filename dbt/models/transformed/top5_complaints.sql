with clean_data as (
  select *
  from {{ ref('clean_data') }}
)

select complaint_type,
       count("*") as nr_complaints
from clean_data
group by 1
order by 2 desc
limit 5