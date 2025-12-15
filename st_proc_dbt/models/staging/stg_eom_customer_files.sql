-- models/bronze/src_eom_customer_files.sql
select
  customer_name,
  cast(invoice_period as date) as invoice_period,
  idr_type,
  idr_num,
  cpt_code,
  cast(dos as date) as dos,
  ehr_num,
  trim(payor_claim_number) as payor_claim_number,
  nbr_dispute_lines
from {{ source('inv', 'eom_customer_files') }}
