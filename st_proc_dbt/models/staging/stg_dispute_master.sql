-- Staging model for dispute master data
-- This model cleans and standardizes dispute master information

select 
    disputenumber,
    disputestatus,
    certifiedentity,
    idreselectiondate,
    
    -- Clean certified entity names
    case 
        when certifiedentity ilike '%C2C%Solution%' then 'C2C Innovative Solutions, Inc.'
        when certifiedentity ilike '%EdiPhy%' then 'EdiPhy Advisors, L.L.C.'
        when certifiedentity ilike '%Federal Hearings and Appeals%' then 'Federal Hearings and Appeals Services'
        when certifiedentity ilike '%fhas%' then 'Federal Hearings and Appeals Services'
        when certifiedentity ilike '%iMPROve Health%' then 'iMPROve Health'
        when certifiedentity ilike '%Island Peer Review%' then 'IPRO/Island Peer Review Organization'
        when certifiedentity ilike '%Keystone Peer Review%' then 'Keystone Peer Review Organization, Inc.'
        when certifiedentity ilike '%Maximus%' then 'Maximus Federal Services, Inc.'
        when certifiedentity ilike '%MCMC%' then 'MCMC Services, LLC'
        when certifiedentity ilike '%Medical Evaluators of Texas%' then 'Medical Evaluators of Texas'
        when certifiedentity ilike '%National Medical Reviews%' then 'National Medical Reviews, Inc.'
        when certifiedentity ilike '%Network Medical Review%' then 'Network Medical Review Company, Ltd.'
        when certifiedentity ilike '%ProPeer Resources%' then 'ProPeer Resources, LLC'
        when certifiedentity ilike '%Provider Resources%' then 'Provider Resources, Inc.'
    end as CERTIFIEDENTITYCLEAN

from {{ source('core', 'disputemaster') }}
