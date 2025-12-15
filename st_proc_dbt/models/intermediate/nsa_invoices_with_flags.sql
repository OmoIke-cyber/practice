-- models/silver/invoices/stg_nsa_invoices_with_flags.sql
select
  nsa.*,

  case
    when dup.ehr_num is not null then false
    else true
  end as ready_for_invoicing,

  case
    when dup.ehr_num is not null
      then 'Duplicate EHRNumber across NSA disputes'
  end as issue
from {{ ref('stg_nsa_invoices') }} nsa
left join {{ ref('nsa_duplicate_ehr') }} dup
  on nsa.ehr_num = dup.ehr_num
 and nsa.payor_claim_number = dup.payor_claim_number
 and nsa.dos = dup.dos
