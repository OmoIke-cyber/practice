-- models/silver/invoices/stg_nsa_invoices.sql
select
  {{ dbt_utils.generate_surrogate_key([
    'idr_num',
    'cpt_code',
    'dos'
  ]) }} as invoice_line_id,

  customer_name,
  idr_num,
  cpt_code,
  dos,
  ehr_num,
  payor_claim_number,
  nbr_dispute_lines,
  invoice_period
from {{ ref('stg_eom_customer_files') }}
where idr_type = 'NSA'
