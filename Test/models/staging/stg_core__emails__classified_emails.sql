-- Staging model for classified emails from Snowflake source
-- This model cleans and standardizes email data from the classified_emails table

with email_classification as (
    select 
        -- IDRE Classification
        case 
            when sending_email_address ilike '%@c2cinc.com%' then 'IDRE - C2C Innovative Solutions, Inc.'
            when sending_email_address ilike '%@ediphy.com%' then 'IDRE - EdiPhy Advisors, L.L.C.'
            when sending_email_address ilike '%@fhas.com%' then 'IDRE - Federal Hearings and Appeals Services'
            when sending_email_address ilike '%@improve.health%' then 'IDRE - iMPROve Health'
            when sending_email_address ilike '%@ipro.org%' then 'IDRE - IPRO/Island Peer Review Organization'
            when sending_email_address ilike '%@acentra.com%' then 'IDRE - Keystone Peer Review Organization, Inc.'
            when sending_email_address ilike '%@kepro.com%' then 'IDRE - Keystone Peer Review Organization, Inc.'
            when sending_email_address ilike '%@maximus.com%' then 'IDRE - Maximus Federal Services, Inc.'
            when sending_email_address ilike '%@mcmcllc.com%' then 'IDRE - MCMC Services, LLC'
            when sending_email_address ilike '%@met-hcs.com%' then 'IDRE - Medical Evaluators of Texas'
            when sending_email_address ilike '%@nmrusa.com%' then 'IDRE - National Medical Reviews, Inc.'
            when sending_email_address ilike '%@nmrexamworks.com%' then 'IDRE - Network Medical Review Company, Ltd.'
            when sending_email_address ilike '%@propeer.com%' then 'IDRE - ProPeer Resources, LLC'
            when sending_email_address ilike '%@provider-resources.com%' then 'IDRE - Provider Resources, Inc.'
        end as idre,
        
        -- Sender classifications
        case 
            when sending_email_address ilike any (
                '%@c2cinc.com%', '%@ediphy.com%', '%@fhas.com%', '%@improve.health%',
                '%@ipro.org%', '%@acentra.com%', '%@kepro.com%', '%@maximus.com%',
                '%@mcmcllc.com%', '%@met-hcs.com%', '%@nmrusa.com%', '%@nmrexamworks.com%',
                '%@propeer.com%', '%@provider-resources.com%'
            ) then 1 
            else 0 
        end as Sender_IDRE_YN,
        
        case when sending_email_address ilike '%@cms.hhs.gov%' then 1 else 0 end as Sender_CMS_YN,
        case when sending_email_address ilike '%@halomd.com%' or sending_email_address ilike '%@md-management.net%' then 1 else 0 end as Sender_HaloMD_YN,
        case when sending_email_address ilike '%@soundphysicians.com%' then 1 else 0 end as Sender_Sound_YN,
        
        -- Receiver classifications
        case 
            when receiving_email_address ilike any (
                '%@c2cinc.com%', '%@ediphy.com%', '%@fhas.com%', '%@improve.health%',
                '%@ipro.org%', '%@acentra.com%', '%@kepro.com%', '%@maximus.com%',
                '%@mcmcllc.com%', '%@met-hcs.com%', '%@nmrusa.com%', '%@nmrexamworks.com%',
                '%@propeer.com%', '%@provider-resources.com%'
            ) then 1 
            else 0 
        end as receiver_idre_yn,
        
        case when receiving_email_address ilike '%@cms.hhs.gov%' then 1 else 0 end as receiver_cms_yn,
        case when receiving_email_address ilike '%@halomd.com%' or receiving_email_address ilike '%@md-management.net%' then 1 else 0 end as receiver_halomd_yn,
        case when receiving_email_address ilike '%@soundphysicians.com%' then 1 else 0 end as receiver_sound_yn,
        
        -- Email type classification
        case 
            when subject ilike 'undeliverable%' then 'UNDELIVERABLE'
            when subject ilike any ('read:%', 'delivered:%', 'relayed:%', '%not read:%') then 'READ_RECEIPTS'
            when sending_email_address ilike any ('%@halomd%', '%@md-management.net%') 
                 and receiving_email_address ilike any ('%@halomd%', '%@md-management.net%') then 'INTERNAL_EMAILS'
            when subject ilike any ('%QPA%', '%OON%', '%request for open negotiation%', '%submission request for%') then 'NSA_OPEN_NEGOTIATION'
            when subject ilike '%Not Eligible for Open Negotiation%' then 'NSA_ON_INELIGIBLE'
            when body ilike any (
                '%request the dispute to be reopened%', '%ineligible is incorrect%',
                '%claim(s) meets all necessary criteria%', '%closed in error%'
            ) then 'CONTESTED'
            when subject ilike '%Withdrawal of Ineligible Notice%' then 'INELIGIBILITY_WITHDRAWN'
            when body ilike '%disregard the not eligible%' then 'INELIGIBILITY_WITHDRAWN'
            when email_type ilike 'WITHDRAW_%' then 'INELIGIBLE'
            when subject ilike any (
                '%IDREClosureNoticeWithdrawn_DISP%', '%Your Dispute is Withdrawn from the Federal IDR Process%',
                '%Withdraw Confirmation%DISP%', '%DISP-%withdrawn%', '%DISP%withdrawal notice%',
                '%Your Dispute has been Withdrawn from the Federal IDR Process - DISP-%',
                '%Your Dispute is Closed/Withdrawn for the Federal IDR Process - DISP-%',
                '%IDREClosureNoticeNotEligible_%', '%dispute has been formally withdrawn%',
                '%Withdrawal Request DISP-%', '%Federal IDR Process is Not Applicable%',
                '%IDREClosureNoticeAdministrative_%', '%Case Dismissal Notice%',
                '%not eligible for federal IDR%', 'IDR: Administrative Closure - DISP%',
                '%DISP%Administrative Closure%', '%iMPROve Health IDREAPP%Dispute Ineligible%',
                '%Notice of non-payment and case closure%', '%DISP%Not Eligible%',
                '%DISP-% NOTICE of Withdrawal Decision', '%Your Dispute has Been Withdrawn%DISP-%',
                '%DISP%Confirmation of Withdrawal%', '%Dispute Withdrawn (DISP-%',
                '%Administrative Closure%DISP%', '%DISP%ineligible cooling%',
                '%non-payment and case closure%', '%your dispute is not eligible%',
                '%Dispute%not eligible%Federal IDR%', '%DISP%Not Eligible%',
                '%DISP%Your IDR dispute has been closed%'
            ) then 'INELIGIBLE'
            when body ilike '%tvalid reason for the ineligibility%' then 'INELIGIBLE'
            when subject ilike '%fee%due%' then 'FEE_PAYMENT_DUE'
            when subject ilike '%invoice%' then 'FEE_PAYMENT_DUE'
            when subject ilike '%proof of payment%' then 'FEE_RELATED'
            when subject ilike '%received your fee payment%' then 'FEES_RECEIVED_NOTIFICATION'
            when subject ilike any ('%Correction%', '%Erroneous%', '%Reconsideration%') then 'CONTESTED'
            when subject ilike any (
                '%withdraw%', '%mark ineligible%', '%Resubmission Review%',
                '%closure request%', '%Dispute closure%', '%ineligible dispute%'
            ) and (sending_email_address ilike '%@halomd.com%' or sending_email_address ilike '%@md-management.net%') 
            then 'REQUEST_TO_WITHDRAW_DISPUTE'
            when body ilike any ('%mark as ineligible%', '%request the closure%')
                 and (sending_email_address ilike '%@halomd.com%' or sending_email_address ilike '%@md-management.net%') 
            then 'REQUEST_TO_WITHDRAW_DISPUTE'
            when subject ilike '%additional information complete%' then 'INFO_REQUEST_COMPLETE'
            when subject ilike '%confirmation%info%received%' then 'INFO_REQUEST_COMPLETE'
            when subject ilike any (
                '%Additional Info%Needed%', '%Request for%Info%', '%additional info%requested%',
                '%reminder%additional info%', '%disp%case%Needed'
            ) then 'REQUEST_FOR_INFORMATION'
            when body ilike any (
                '%attached requested information%', '%Additional Information Requested%',
                '%please provide the required evidence to support your dispute%',
                '%Your proof should be ATTACHED as a REPLY to this email%'
            ) then 'REQUEST_FOR_INFORMATION'
            when coalesce(email_type, '') not in (
                'FEES_RECEIVED_NOTIFICATION', 'IDRE_SELECTION', 'SUBMISSION_DUE', 'INITIATION', 'FORMAL_RECEIVED',
                'AWARD_DETERMINATION', 'IDRE_RESELECTION_RESPONSE_FORM', 'IDRE_SELECTION_NOTIFICATION',
                'IDRE_RESELECTION', 'FEE_PAYMENT_DUE_C2C', 'HEALTH_PLAN_TYPE_UPDATE', 'IDRE_SELECTION_RECEIVED',
                'INELIGIBLE_IPRO', 'IDRE_SELECTION_RESPONSE', 'FEE_PAYMENT_DUE_MET', 'REQUEST_TO_WITHDRAW_DISPUTE',
                'FEE_PAYMENT_DUE_NETWORK_MEDICAL_REVIEW', 'NSA_OPEN_NEGOTIATION', 'FEE_PAYMENT_DUE_IMPROVEHEALTH'
            ) and (sending_email_address ilike '%@cms%' or receiving_email_address ilike '%@cms%')
            then 'CMS_UNCATEGORIZED'
        end as emailtype2,
        
        -- Exception type classification
        case 
            when subject ilike '%initiation%resubmission%' then 'Resubmission'
            when subject ilike '%cool%' then 'Cooling'
            when body ilike '%cool%' then 'Cooling'
            when body ilike '%updated the health plan type%' 
                 and sender_cms_yn = 1 and receiver_halomd_yn = 1 then 'Plan Type'
            when body ilike '%updated the health plan type%' 
                 and sender_sound_yn = 1 and receiver_halomd_yn = 1 then 'Plan Type'
            when body ilike '%rescinded%' then 'Award Rescinded/Vacated'
            when subject ilike '%vacated%' then 'Award Rescinded/Vacated'
        end as ExceptionType,
        
        -- Ineligibility reason classification
        case 
            when body ilike any ('%State law%', '%State specified law%', '%State arbitration%', '%State process%') then 'State'
            when body like any ('%SSL %', '%SSL%', '% SSL%') then 'State'  -- case sensitive
            when subject ilike any ('%State law%', '%State specified law%', '%State arbitration%', '%State process%') then 'State'
            when subject like any ('%SSL %', '%SSL%', '% SSL%') then 'State'  -- case sensitive
            when subject ilike any ('%in-network%', '%in network%') then 'In-Network'
            when body ilike any ('%in-network%', '%in network%') then 'In-Network'
        end as IneligibilityReason,
        
        -- Original fields
        subject,
        body,
        sending_email_address,
        receiving_email_address,
        customer_acronym,
        dispute_number,
        cst_received_timestamp
        
    from {{ source('core', 'classified_emails') }}
    where coalesce(sending_email_address, '') not ilike '%microsoft%'
      and coalesce(receiving_email_address, '') not ilike '%microsoft%'
      and not (sending_email_address ilike '%halomd%' and receiving_email_address ilike '%halomd%')
      and idr_level = 'NSA'
)

select *
from email_classification
where emailtype2 not in (
    'FEE_PAYMENT_DUE', 'FEE_RELATED', 'FEES_RECEIVED_NOTIFICATION', 'NSA_OPEN_NEGOTIATION',
    'UNDELIVERABLE', 'READ_RECEIPTS', 'NSA_ON_INELIGIBLE', 'INTERNAL_EMAILS', 'CMS_UNCATEGORIZED',
    'INFO_REQUEST_COMPLETE', 'REQUEST_FOR_INFORMATION' )
