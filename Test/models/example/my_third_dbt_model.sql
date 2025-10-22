select * from  {{ ref('my_first_dbt_model') }}

union all

select ARBITRATIONCASEID, 'NX' as location, 'Debby' as manager
from {{ ref('stg_core_disputes__DISPUTE__SETTLEMENT')}}