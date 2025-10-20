with source_data as (

    select *
    from {{ source('test_source','DISPUTE_SETTLEMENT')}}
)


select * from source_data
where CLAIMCPTID is not null
limit 200