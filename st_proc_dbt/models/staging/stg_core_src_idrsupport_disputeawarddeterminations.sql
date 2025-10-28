 {{ config(alias= 'stg_dispute_award_determinations') }}

select *
 from {{ source('core', 'disputeawarddeterminations') }} 