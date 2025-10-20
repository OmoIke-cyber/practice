select * from  {{ ref('my_first_dbt_model') }}

union all

select ARBITRATIONCASEID, 'NX' as location, 'Debby' as manager
from {{ source('test_source','DISPUTE_SETTLEMENT')}}