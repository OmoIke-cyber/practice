-- Staging model for multi-dispute email extraction
-- This model extracts multiple dispute numbers from email bodies using regex

with snowflake_multi_disputes as (
    select distinct
        subject,
        body,
        cst_received_timestamp,
        'Snowflake' as email_source,
        regexp_substr(body, 'DISP-\\d+', 1, g.seq + 1) as dispute_number_extracted
    from {{ ref('stg_core__emails__classified_emails') }},
         lateral (
             select seq4() as seq 
             from table(generator(rowcount => 100))
         ) g
    where regexp_substr(body, 'DISP-\\d+', 1, g.seq + 1) is not null
      and ExceptionType is null
),

jitbit_multi_disputes as (
    select distinct
        subject,
        body,
        cst_received_timestamp,
        'Jitbit' as email_source,
        regexp_substr(body, 'DISP-\\d+', 1, g.seq + 1) as dispute_number_extracted
    from {{ ref('stg_raw__dwsql__idrsupoort_emails') }},
         lateral (
             select seq4() as seq 
             from table(generator(rowcount => 100))
         ) g
    where regexp_substr(body, 'DISP-\\d+', 1, g.seq + 1) is not null
      and ExceptionType is null
),

combined_multi_disputes as (
    select * from snowflake_multi_disputes
    union all
    select * from jitbit_multi_disputes
),
MultiDisp_Longest as (
        select 
            body, 
            subject, 
            cst_received_timestamp, 
            max(len(dispute_number_extracted)) as longest_dispute_length
        from combined_multi_disputes
        group by body, subject, cst_received_timestamp
        having count(*) > 1
    ) ,
-- Filter to keep only the longest dispute numbers for multi-dispute emails
filtered_multi_disputes as (
    select a.*
    from combined_multi_disputes a
    left join MultiDisp_Longest b
    on a.body = b.body
       and a.subject = b.subject
       and a.cst_received_timestamp = b.cst_received_timestamp
    where len(a.dispute_number_extracted) >= coalesce(b.longest_dispute_length - 1, len(a.dispute_number_extracted))
)

select *
from filtered_multi_disputes
