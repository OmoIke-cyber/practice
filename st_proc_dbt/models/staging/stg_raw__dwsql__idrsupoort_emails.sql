-- Staging model for emails from Jitbit source
-- This model cleans and standardizes email data from the src_idrsupport_emails table

with jitbit_email_classification as (
    select 
        -- IDRE Classification
   case when fromemail ilike '%@c2cinc.com%'			   THEN 'IDRE - C2C Innovative Solutions, Inc.'
    			 when fromemail ilike '%@ediphy.com%'			   THEN 'IDRE - EdiPhy Advisors, L.L.C.'	
    			 when fromemail ilike '%@fhas.com%'				   THEN 'IDRE - Federal Hearings and Appeals Services'
    			 when fromemail ilike '%@improve.health%'		   THEN 'IDRE - iMPROve Health'
    			 when fromemail ilike '%@ipro.org%'				   THEN 'IDRE - IPRO/Island Peer Review Organization'
    			 when fromemail ilike '%@acentrcom%'			   THEN 'IDRE - Keystone Peer Review Organization, Inc.'
    			 when fromemail ilike '%@kepro.com%'			   THEN 'IDRE - Keystone Peer Review Organization, Inc.'
    			 when fromemail ilike '%@maximus.com%'			   THEN 'IDRE - Maximus Federal Services, Inc.'         
    			 when fromemail ilike '%@mcmcllc.com%'			   THEN 'IDRE - MCMC Services, LLC'
    			 when fromemail ilike '%@met-hcs.com%'			   THEN 'IDRE - Medical Evaluators of Texas' 
    			 when fromemail ilike '%@nmruscom%'			   THEN 'IDRE - National Medical Reviews, Inc.'
    			 when fromemail ilike '%@nmrexamworks.com%'		   THEN 'IDRE - Network Medical Review Company, Ltd.' 
    			 when fromemail ilike '%@propeer.com%'			   THEN 'IDRE - ProPeer Resources, LLC'
    			 when fromemail ilike '%@provider-resources.com%'  THEN 'IDRE - Provider Resources, Inc.'                        
            END AS IDRE

        -- Sender classifications
                       , case when fromemail ilike any ('%@c2cinc.com%','%@ediphy.com%','%@fhas.com%','%@improve.health%'		   
                                                			 ,'%@ipro.org%','%@acentrcom%','%@kepro.com%','%@maximus.com%'
                                                             ,'%@mcmcllc.com%','%@met-hcs.com%','%@nmruscom%','%@nmrexamworks.com%'		   
        			                                         ,'%@propeer.com%','%@provider-resources.com%')  
                     THEN 1 ELSE 0 END                                                               AS Sender_IDRE_YN
         , case when fromemail ilike '%@cms.hhs.gov%'           THEN 1 else 0 end as Sender_CMS_YN
                , case when fromemail ilike '%@halomd.com%' 
                         or fromemail ilike '%@md-management.net%'     THEN 1 else 0 end as Sender_HaloMD_YN
                , case when fromemail ilike '%@soundphysicians.com%' THEN 1 else 0 end as Sender_Sound_YN  
                , case when toemail ilike any ('%@c2cinc.com%','%@ediphy.com%','%@fhas.com%','%@improve.health%'		   
                                                			 ,'%@ipro.org%','%@acentrcom%','%@kepro.com%','%@maximus.com%'
                                                             ,'%@mcmcllc.com%','%@met-hcs.com%','%@nmruscom%','%@nmrexamworks.com%'
        			                                         ,'%@propeer.com%','%@provider-resources.com%')  
                     THEN 1 ELSE 0 END                                                                 AS Receiver_IDRE_YN
        
        -- Receiver classifications

       
                , case when toemail ilike '%@cms.hhs.gov%'           THEN 1 else 0 end as Receiver_CMS_YN
                , case when toemail ilike '%@halomd.com%' 
                         or toemail ilike '%@md-management.net%'     THEN 1 else 0 end as Receiver_HaloMD_YN  
                , case when toemail ilike '%@soundphysicians.com%' THEN 1 else 0 end as Receiver_Sound_YN   ,
        -- Email type classification (same logic as classified emails)
        case 
            when subject ilike 'undeliverable%' then 'UNDELIVERABLE'
            when subject ilike any ('read:%', 'delivered:%', 'relayed:%', '%not read:%') then 'READ_RECEIPTS'
            when fromemail ilike any ('%@halomd%', '%@md-management.net%') 
                 and toemail ilike any ('%@halomd%', '%@md-management.net%') then 'INTERNAL_EMAILS'
            when subject ilike any ('%QPA%', '%OON%', '%request for open negotiation%', '%submission request for%') then 'NSA_OPEN_NEGOTIATION'
            when subject ilike '%Not Eligible for Open Negotiation%' then 'NSA_ON_INELIGIBLE'
            when body ilike any (
                '%request the dispute to be reopened%', '%ineligible is incorrect%',
                '%claim(s) meets all necessary criteria%', '%closed in error%'
            ) then 'CONTESTED'
            when subject ilike '%Withdrawal of Ineligible Notice%' then 'INELIGIBILITY_WITHDRAWN'
            when body ilike '%disregard the not eligible%' then 'INELIGIBILITY_WITHDRAWN'
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
            ) and (fromemail ilike '%@halomd.com%' or fromemail ilike '%@md-management.net%') 
            then 'REQUEST_TO_WITHDRAW_DISPUTE'
            when body ilike any ('%mark as ineligible%', '%request the closure%', '%request closure%')
                 and (fromemail ilike '%@halomd.com%' or fromemail ilike '%@md-management.net%') 
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
        
        -- Original fields (mapped to match classified emails structure)
        subject,
        body,
        fromemail as sending_email_address,
        toemail as receiving_email_address,
        emailedcustomer as customer_acronym,
        regexp_substr(body, 'DISP-\\d+') as DisputeNumber,
        emaildate as cst_received_timestamp
        
    from {{ source('raw', 'src_idrsupport_emails') }}
    where coalesce(fromemail, '') not ilike '%microsoft%'
      and coalesce(toemail, '') not ilike '%microsoft%'
      -- Exclude emails that already exist in classified_emails
      and not exists (
          select 1 from {{ ref('stg_core__emails__classified_emails') }} ce
          where ce.subject = src_idrsupport_emails.subject
            and ce.body = src_idrsupport_emails.body
      )
)

select *
from jitbit_email_classification
where emailtype2 not in (
    'FEE_PAYMENT_DUE', 'FEE_RELATED', 'FEES_RECEIVED_NOTIFICATION', 'NSA_OPEN_NEGOTIATION',
    'UNDELIVERABLE', 'READ_RECEIPTS', 'NSA_ON_INELIGIBLE', 'INTERNAL_EMAILS', 'CMS_UNCATEGORIZED',
    'INFO_REQUEST_COMPLETE', 'REQUEST_FOR_INFORMATION'
)
