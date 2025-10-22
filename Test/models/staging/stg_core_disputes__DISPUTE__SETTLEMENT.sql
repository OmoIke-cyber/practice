{{ config(materialized='view') }}

with source_data as (

    select *
    from {{ source('test_source','DISPUTE_SETTLEMENT')}}
)


select * from source_data