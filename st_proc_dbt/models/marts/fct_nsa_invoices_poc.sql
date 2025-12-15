-- models/gold/invoices/fct_nsa_invoices_poc.sql
select
  invoice_line_id,
  customer_name,
  idr_num,
  cpt_code,
  dos,
  ready_for_invoicing,
  issue
from {{ ref('nsa_invoices_with_flags') }}
