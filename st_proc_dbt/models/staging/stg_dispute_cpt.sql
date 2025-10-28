-- Staging model for dispute CPT data with arbitration status
-- This model joins dispute CPT data with arbitration cases to get NSA status

with dispute_cpt_with_status as (
    select 
        a.disputenumber,
        a.arbitid,
        b.nsastatus
    from {{ source('core', 'disputecpt') }} a
    left join {{ source('core', 'arbitrationcases') }} b
        on a.arbitid = b.id
        and b.isdeleted = false
    where a.issoftdelete = 0
),

dispute_cpt_aggregated as (
    select 
         disputenumber
                 , MIN(case when nsastatus ilike '%INELIGIBLE%' THEN 1 ELSE 0 END) AS AllIneligible_YN
                 , MAX(case when nsastatus ilike '%INELIGIBLE%' THEN 1 ELSE 0 END) AS AnyIneligible_YN
                 , listagg(concat(arbitid,' - ',nsastatus ),', ')                  AS ArbitIDs
    from dispute_cpt_with_status
    group by disputenumber
)

select *
from dispute_cpt_aggregated
