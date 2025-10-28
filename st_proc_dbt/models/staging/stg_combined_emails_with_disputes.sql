-- Intermediate model combining all email data with dispute master information
-- This model combines classified emails, jitbit emails, and dispute master data

with combined_emails as (
    select 
        *,
        'Snowflake' as email_source
    from {{ ref('stg_core__emails__classified_emails') }}
    
    union all
    
    select 
        *,
        'Jitbit' as email_source
    from {{ ref('stg_raw__dwsql__idrsupoort_emails') }}
),

emails_with_dispute_numbers as (
    select 
        a.*,
        coalesce(multi.dispute_number_extracted, a.dispute_number) as dispute_number_final,
        case 
            when a.ExceptionType = 'Cooling' 
                 and current_date() < dateadd('d', 90, a.cst_received_timestamp) then null
            else a.ExceptionType 
        end as EXCEPTIONTYPE2
    from combined_emails a
    left join {{ ref('stg_multi_dispute_extraction') }} multi
        on a.body = multi.body
        and a.subject = multi.subject
        and a.cst_received_timestamp = multi.cst_received_timestamp
),

emails_with_dispute_data as (
    select 
        e.*
         , dm.disputestatus
          , cpt.AllIneligible_YN
          , cpt.AnyIneligible_YN
          , cpt.ArbitIDs
          , dm.idreselectiondate
          , case when det.TOTALAWARDAMOUNT is not null THEN 1 ELSE 0 END AS DisputeAward_YN
          , det.awarddate  
          , case when dm.disputenumber is not null then 1 else 0 END AS InDisputeMaster_YN
          , dm.CERTIFIEDENTITYCLEAN
    from emails_with_dispute_numbers e
    left join {{ ref('stg_dispute_master') }} dm
        on e.dispute_number_final = dm.disputenumber
    left join {{ ref('stg_dispute_cpt') }} cpt
        on e.dispute_number_final = cpt.disputenumber
    left join {{ ref('stg_core_src_idrsupport_disputeawarddeterminations') }} det
        on e.dispute_number_final = det.disputenumber
)

select *
from emails_with_dispute_data
where dispute_number_final is not null
  and upper(coalesce(disputestatus, '')) not in ('INELIGIBLE', 'WITHDRAWN')
