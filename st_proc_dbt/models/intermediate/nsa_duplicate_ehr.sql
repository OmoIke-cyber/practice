-- models/silver/invoices/nsa_duplicate_ehr.sql
select
  ehr_num,
  payor_claim_number,
  dos,
  count(*) as duplicate_count
from {{ ref('stg_nsa_invoices') }}
group by ehr_num, payor_claim_number, dos
having count(*) > 1
