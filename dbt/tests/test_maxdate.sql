with clean as (

    select max(date_created) as clean_date 
    from  {{ ref('clean_data') }}

),

target as (

    select max(date_created) as max_date
    from {{ ref('noise_complaints') }}

)

select  * 
from target
full join clean
on target.max_date = clean.clean_date
where target.max_date IS NULL OR clean.clean_date IS NULL