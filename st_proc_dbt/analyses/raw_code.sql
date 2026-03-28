Create or Replace TEMPORARY Table OPS.Public.T1 as 
select *
from (
    select   
            case when sending_email_address ilike '%@c2cinc.com%'			   THEN 'IDRE - C2C Innovative Solutions, Inc.'
    			 when sending_email_address ilike '%@ediphy.com%'			   THEN 'IDRE - EdiPhy Advisors, L.L.C.'	
    			 when sending_email_address ilike '%@fhas.com%'				   THEN 'IDRE - Federal Hearings and Appeals Services'
    			 when sending_email_address ilike '%@improve.health%'		   THEN 'IDRE - iMPROve Health'
    			 when sending_email_address ilike '%@ipro.org%'				   THEN 'IDRE - IPRO/Island Peer Review Organization'
    			 when sending_email_address ilike '%@acentra.com%'			   THEN 'IDRE - Keystone Peer Review Organization, Inc.'
    			 when sending_email_address ilike '%@kepro.com%'			   THEN 'IDRE - Keystone Peer Review Organization, Inc.'
    			 when sending_email_address ilike '%@maximus.com%'			   THEN 'IDRE - Maximus Federal Services, Inc.'         
    			 when sending_email_address ilike '%@mcmcllc.com%'			   THEN 'IDRE - MCMC Services, LLC'
    			 when sending_email_address ilike '%@met-hcs.com%'			   THEN 'IDRE - Medical Evaluators of Texas' 
    			 when sending_email_address ilike '%@nmrusa.com%'			   THEN 'IDRE - National Medical Reviews, Inc.'
    			 when sending_email_address ilike '%@nmrexamworks.com%'		   THEN 'IDRE - Network Medical Review Company, Ltd.' 
    			 when sending_email_address ilike '%@propeer.com%'			   THEN 'IDRE - ProPeer Resources, LLC'
    			 when sending_email_address ilike '%@provider-resources.com%'  THEN 'IDRE - Provider Resources, Inc.'                        
            END AS IDRE
                 , case when a.sending_email_address ilike any ('%@c2cinc.com%','%@ediphy.com%','%@fhas.com%','%@improve.health%'		   
                                                			 ,'%@ipro.org%','%@acentra.com%','%@kepro.com%','%@maximus.com%'
                                                             ,'%@mcmcllc.com%','%@met-hcs.com%','%@nmrusa.com%','%@nmrexamworks.com%'		   
        			                                         ,'%@propeer.com%','%@provider-resources.com%')  
                     THEN 1 ELSE 0 END                                                               AS Sender_IDRE_YN
                , case when a.sending_email_address ilike '%@cms.hhs.gov%'           THEN 1 else 0 end as Sender_CMS_YN
                , case when a.sending_email_address ilike '%@halomd.com%' 
                         or a.sending_email_address ilike '%@md-management.net%'     THEN 1 else 0 end as Sender_HaloMD_YN
                , case when a.sending_email_address ilike '%@soundphysicians.com%' THEN 1 else 0 end as Sender_Sound_YN  
                        
                , case when a.receiving_email_address ilike any ('%@c2cinc.com%','%@ediphy.com%','%@fhas.com%','%@improve.health%'		   
                                                			 ,'%@ipro.org%','%@acentra.com%','%@kepro.com%','%@maximus.com%'
                                                             ,'%@mcmcllc.com%','%@met-hcs.com%','%@nmrusa.com%','%@nmrexamworks.com%'		   
        			                                         ,'%@propeer.com%','%@provider-resources.com%')  
                     THEN 1 ELSE 0 END                                                                 AS Receiver_IDRE_YN
                , case when a.receiving_email_address ilike '%@cms.hhs.gov%'           THEN 1 else 0 end as Receiver_CMS_YN
                , case when a.receiving_email_address ilike '%@halomd.com%' 
                         or a.receiving_email_address ilike '%@md-management.net%'     THEN 1 else 0 end as Receiver_HaloMD_YN  
                , case when a.receiving_email_address ilike '%@soundphysicians.com%' THEN 1 else 0 end as Receiver_Sound_YN               
                , case  when a.subject ilike 'undeliverable%'                                        THEN 'UNDELIVERABLE'
                        when a.subject ilike any ('read:%','delivered:%' ,'relayed:%','%not read:%') THEN 'READ_RECEIPTS'
                        when a.sending_email_address ilike any ('%@halomd%','%@md-management.net%')  
                         and a.receiving_email_address ilike any ('%@halomd%','%@md-management.net%') THEN 'INTERNAL_EMAILS'    
                      when   a.subject ilike any ('%QPA%','%OON%','%request for open negotiation%','%submission request for%')
                                                                                    THEN 'NSA_OPEN_NEGOTIATION'
                      when a.subject ilike '%Not Eligible for Open Negotiation%'    THEN 'NSA_ON_INELIGIBLE'   
                      when a.body ILIKE ANY ('%request the dispute to be reopened%','%ineligible is incorrect%'
                                                          ,'%claim(s) meets all necessary criteria%','%closed in error%') THEN 'CONTESTED'
                    		  when a.subject ilike '%Withdrawal of Ineligible Notice%'      THEN 'INELIGIBILITY_WITHDRAWN' 
                    		  when a.body ilike '%disregard the not eligible%'              THEN 'INELIGIBILITY_WITHDRAWN' 
                              when a.EMAIL_TYPE ilike 'WITHDRAW_%'                          THEN 'INELIGIBLE'
                    		  when a.subject ilike ANY ('%IDREClosureNoticeWithdrawn_DISP%',
                              '%Your Dispute is Withdrawn from the Federal IDR Process%','%Withdraw Confirmation%DISP%',
                              '%DISP-%withdrawn%','%DISP%withdrawal notice%'
                              ,'%Your Dispute has been Withdrawn from the Federal IDR Process - DISP-%',
                              '%Your Dispute is Closed/Withdrawn for the Federal IDR Process - DISP-%','%IDREClosureNoticeNotEligible_%',
                              '%dispute has been formally withdrawn%','%Withdrawal Request DISP-%','%Federal IDR Process is Not Applicable%',
                              '%IDREClosureNoticeAdministrative_%',
                              '%Case Dismissal Notice%','%not eligible for federal IDR%','IDR: Administrative Closure - DISP%',
                              '%DISP%Administrative Closure%','%iMPROve Health IDREAPP%Dispute Ineligible%',
                              '%Notice of non-payment and case closure%','%DISP%Not Eligible%',
                              '%DISP-% NOTICE of Withdrawal Decision','%Your Dispute has Been Withdrawn%DISP-%',
                              '%DISP%Confirmation of Withdrawal%','%Dispute Withdrawn (DISP-%','%Administrative Closure%DISP%',
                              '%DISP%ineligible cooling%','%non-payment and case closure%','%your dispute is not eligible%'
                              ,'%Dispute%not eligible%Federal IDR%','%DISP%Not Eligible%','%DISP%Your IDR dispute has been closed%')                              THEN 'INELIGIBLE'
                              
                              when a.body ilike '%tvalid reason for the ineligibility%'   THEN 'INELIGIBLE' 
                              when a.subject ilike '%fee%due%'                                     THEN 'FEE_PAYMENT_DUE'
                              when a.subject ilike '%invoice%'                                   THEN 'FEE_PAYMENT_DUE'
                              when a.subject ilike '%proof of payment%'                          THEN 'FEE_RELATED'    
                              when a.subject ilike '%received your fee payment%'                 THEN 'FEES_RECEIVED_NOTIFICATION' 
                              when a.subject ilike ANY ('%Correction%', '%Erroneous%', '%Reconsideration%') THEN 'CONTESTED'
                              
                              when a.subject ilike any ('%withdraw%','%mark ineligible%','%Resubmission Review%'
                                                ,'%closure request%','%Dispute closure%','%ineligible dispute%')
                              and (sending_email_address ilike '%@halomd.com%' 
                                or sending_email_address ilike '%@md-management.net%')  THEN 'REQUEST_TO_WITHDRAW_DISPUTE'
                              when a.body ilike any ('%mark as ineligible%','%request the closure%')
                               and (sending_email_address ilike '%@halomd.com%' 
                                 or sending_email_address ilike '%@md-management.net%') THEN 'REQUEST_TO_WITHDRAW_DISPUTE'              
                              when a.subject ilike '%additional information complete%'    THEN 'INFO_REQUEST_COMPLETE'
                              when a.subject ilike '%confirmation%info%received%'         THEN 'INFO_REQUEST_COMPLETE' 
                              when a.subject ilike any ('%Additional Info%Needed%','%Request for%Info%','%additional info%requested%'
                                    ,'%reminder%additional info%','%disp%case%Needed')  THEN 'REQUEST_FOR_INFORMATION'
                              when a.body ilike any ('%attached requested information%','%Additional Information Requested%'  
                                                  ,'%please provide the required evidence to support your dispute%'
                                                  ,'%Your proof should be ATTACHED as a REPLY to this email%')
                                                                                        THEN 'REQUEST_FOR_INFORMATION'   
                              when coalesce(email_type,'') NOT IN                       
                                        ('FEES_RECEIVED_NOTIFICATION','IDRE_SELECTION','SUBMISSION_DUE','INITIATION','FORMAL_RECEIVED'
                                        ,'AWARD_DETERMINATION','IDRE_RESELECTION_RESPONSE_FORM','IDRE_SELECTION_NOTIFICATION'
                                        ,'IDRE_RESELECTION','FEE_PAYMENT_DUE_C2C','HEALTH_PLAN_TYPE_UPDATE','IDRE_SELECTION_RECEIVED'
                                        ,'INELIGIBLE_IPRO','IDRE_SELECTION_RESPONSE','FEE_PAYMENT_DUE_MET','REQUEST_TO_WITHDRAW_DISPUTE'
                                        ,'FEE_PAYMENT_DUE_NETWORK_MEDICAL_REVIEW','NSA_OPEN_NEGOTIATION','FEE_PAYMENT_DUE_IMPROVEHEALTH')
                                    AND (sending_email_address ilike '%@cms%' or receiving_email_address ilike '%@cms%')
                                        THEN 'CMS_UNCATEGORIZED'
                    	END AS EMAILTYPE2                   
               ,case when a.subject ilike '%initiation%resubmission%'      THEN 'Resubmission'
                     when a.subject ilike '%cool%'                         THEN 'Cooling'  
                     when a.body ilike '%cool%'                            THEN 'Cooling'  
                     when  body ilike '%updated the health plan type%'  
                      and  sender_cms_YN = 1 and receiver_halomd_YN = 1     THEN 'Plan Type'
                     when  body ilike '%updated the health plan type%'  
                      and  sender_sound_YN = 1 and receiver_halomd_YN = 1   THEN 'Plan Type'
                     when a.body ilike '%rescinded%'                        THEN 'Award Rescinded/Vacated'
                     when a.subject ilike '%vacated%'                       THEN 'Award Rescinded/Vacated'            
                end AS ExceptionType
            , case when a.body ilike any ('%State law%','%State specified law%','%State arbitration%'
                               ,'%State process%')                          THEN 'State'
                   when a.body like any ('%SSL %','%SSL%','% SSL%')      THEN 'State'-- keep case sensitive          
                   when a.subject ilike any ('%State law%','%State specified law%','%State arbitration%'
                                ,'%State process%')                          THEN 'State'
                   when a.subject like any ('%SSL %','%SSL%','% SSL%')   THEN 'State'  -- keep case sensitive
                   when a.subject ilike any ('%in-network%','%in network%')   THEN 'In-Network'
                   when a.body ilike any ('%in-network%','%in network%')       THEN 'In-Network'
    
                   end AS IneligibilityReason          
            ,subject
            ,body
            ,sending_email_address
            ,receiving_email_address
            ,customer_acronym
            ,dispute_number
            ,cst_received_timestamp

    from        CORE.EMAIL.classified_emails a
    where   coalesce(sending_email_address,'')   not ilike '%microsoft%' 
    and     coalesce(receiving_email_address,'') not ilike '%microsoft%'   
    and     not(sending_email_address ilike '%halomd%' and receiving_email_address ilike '%halomd%')
    and     idr_level = 'NSA'
    ) a
where EMAILTYPE2 not IN ('FEE_PAYMENT_DUE','FEE_RELATED','FEES_RECEIVED_NOTIFICATION','NSA_OPEN_NEGOTIATION'
                        ,'UNDELIVERABLE','READ_RECEIPTS','NSA_ON_INELIGIBLE','INTERNAL_EMAILS','CMS_UNCATEGORIZED'
                        ,'INFO_REQUEST_COMPLETE','REQUEST_FOR_INFORMATION');
=====================================================================================================================
                      
Create or Replace TEMPORARY Table OPS.Public.T1J as      
select *
from (
  select    case when fromemail ilike '%@c2cinc.com%'			   THEN 'IDRE - C2C Innovative Solutions, Inc.'
    			 when fromemail ilike '%@ediphy.com%'			   THEN 'IDRE - EdiPhy Advisors, L.L.C.'	
    			 when fromemail ilike '%@fhas.com%'				   THEN 'IDRE - Federal Hearings and Appeals Services'
    			 when fromemail ilike '%@improve.health%'		   THEN 'IDRE - iMPROve Health'
    			 when fromemail ilike '%@ipro.org%'				   THEN 'IDRE - IPRO/Island Peer Review Organization'
    			 when fromemail ilike '%@acentra.com%'			   THEN 'IDRE - Keystone Peer Review Organization, Inc.'
    			 when fromemail ilike '%@kepro.com%'			   THEN 'IDRE - Keystone Peer Review Organization, Inc.'
    			 when fromemail ilike '%@maximus.com%'			   THEN 'IDRE - Maximus Federal Services, Inc.'         
    			 when fromemail ilike '%@mcmcllc.com%'			   THEN 'IDRE - MCMC Services, LLC'
    			 when fromemail ilike '%@met-hcs.com%'			   THEN 'IDRE - Medical Evaluators of Texas' 
    			 when fromemail ilike '%@nmrusa.com%'			   THEN 'IDRE - National Medical Reviews, Inc.'
    			 when fromemail ilike '%@nmrexamworks.com%'		   THEN 'IDRE - Network Medical Review Company, Ltd.' 
    			 when fromemail ilike '%@propeer.com%'			   THEN 'IDRE - ProPeer Resources, LLC'
    			 when fromemail ilike '%@provider-resources.com%'  THEN 'IDRE - Provider Resources, Inc.'                        
            END AS IDRE
               , case when fromemail ilike any ('%@c2cinc.com%','%@ediphy.com%','%@fhas.com%','%@improve.health%'		   
                                                			 ,'%@ipro.org%','%@acentra.com%','%@kepro.com%','%@maximus.com%'
                                                             ,'%@mcmcllc.com%','%@met-hcs.com%','%@nmrusa.com%','%@nmrexamworks.com%'		   
        			                                         ,'%@propeer.com%','%@provider-resources.com%')  
                     THEN 1 ELSE 0 END                                                               AS Sender_IDRE_YN
                , case when fromemail ilike '%@cms.hhs.gov%'           THEN 1 else 0 end as Sender_CMS_YN
                , case when fromemail ilike '%@halomd.com%' 
                         or fromemail ilike '%@md-management.net%'     THEN 1 else 0 end as Sender_HaloMD_YN
                , case when fromemail ilike '%@soundphysicians.com%' THEN 1 else 0 end as Sender_Sound_YN  
                , case when toemail ilike any ('%@c2cinc.com%','%@ediphy.com%','%@fhas.com%','%@improve.health%'		   
                                                			 ,'%@ipro.org%','%@acentra.com%','%@kepro.com%','%@maximus.com%'
                                                             ,'%@mcmcllc.com%','%@met-hcs.com%','%@nmrusa.com%','%@nmrexamworks.com%'
        			                                         ,'%@propeer.com%','%@provider-resources.com%')  
                     THEN 1 ELSE 0 END                                                                 AS Receiver_IDRE_YN
                , case when toemail ilike '%@cms.hhs.gov%'           THEN 1 else 0 end as Receiver_CMS_YN
                , case when toemail ilike '%@halomd.com%' 
                         or toemail ilike '%@md-management.net%'     THEN 1 else 0 end as Receiver_HaloMD_YN  
                , case when toemail ilike '%@soundphysicians.com%' THEN 1 else 0 end as Receiver_Sound_YN               
                , case  when a.subject ilike 'undeliverable%'                                        THEN 'UNDELIVERABLE'
                        when a.subject ilike any ('read:%','delivered:%' ,'relayed:%','%not read:%') THEN 'READ_RECEIPTS'
                        when fromemail ilike any ('%@halomd%','%@md-management.net%')  
                         and toemail ilike any ('%@halomd%','%@md-management.net%') THEN 'INTERNAL_EMAILS'    
                      when   a.subject ilike any ('%QPA%','%OON%','%request for open negotiation%','%submission request for%')
                                                                                    THEN 'NSA_OPEN_NEGOTIATION'
                      when a.subject ilike '%Not Eligible for Open Negotiation%'    THEN 'NSA_ON_INELIGIBLE'   
                      when a.body ILIKE ANY ('%request the dispute to be reopened%','%ineligible is incorrect%'
                                                          ,'%claim(s) meets all necessary criteria%','%closed in error%') THEN 'CONTESTED'
                    		  when a.subject ilike '%Withdrawal of Ineligible Notice%'      THEN 'INELIGIBILITY_WITHDRAWN' 
                    		  when a.body ilike '%disregard the not eligible%'              THEN 'INELIGIBILITY_WITHDRAWN' 
                    		  when a.subject ilike ANY ('%IDREClosureNoticeWithdrawn_DISP%',
                              '%Your Dispute is Withdrawn from the Federal IDR Process%','%Withdraw Confirmation%DISP%',
                              '%DISP-%withdrawn%','%DISP%withdrawal notice%'
                              ,'%Your Dispute has been Withdrawn from the Federal IDR Process - DISP-%',
                              '%Your Dispute is Closed/Withdrawn for the Federal IDR Process - DISP-%','%IDREClosureNoticeNotEligible_%',
                              '%dispute has been formally withdrawn%','%Withdrawal Request DISP-%','%Federal IDR Process is Not Applicable%',
                              '%IDREClosureNoticeAdministrative_%',
                              '%Case Dismissal Notice%','%not eligible for federal IDR%','IDR: Administrative Closure - DISP%',
                              '%DISP%Administrative Closure%','%iMPROve Health IDREAPP%Dispute Ineligible%',
                              '%Notice of non-payment and case closure%','%DISP%Not Eligible%',
                              '%DISP-% NOTICE of Withdrawal Decision','%Your Dispute has Been Withdrawn%DISP-%',
                              '%DISP%Confirmation of Withdrawal%','%Dispute Withdrawn (DISP-%','%Administrative Closure%DISP%',
                              '%DISP%ineligible cooling%','%non-payment and case closure%','%your dispute is not eligible%'
                              ,'%Dispute%not eligible%Federal IDR%','%DISP%Not Eligible%','%DISP%Your IDR dispute has been closed%')                              THEN 'INELIGIBLE'
                              
                              when a.body ilike '%tvalid reason for the ineligibility%'          THEN 'INELIGIBLE' 
                              when a.subject ilike '%fee%due%'                                   THEN 'FEE_PAYMENT_DUE'
                              when a.subject ilike '%invoice%'                                   THEN 'FEE_PAYMENT_DUE'
                              when a.subject ilike '%proof of payment%'                          THEN 'FEE_RELATED'    
                              when a.subject ilike '%received your fee payment%'                 THEN 'FEES_RECEIVED_NOTIFICATION' 
                              when a.subject ilike ANY ('%Correction%', '%Erroneous%', '%Reconsideration%') THEN 'CONTESTED'
                              
                              when a.subject ilike any ('%withdraw%','%mark ineligible%','%Resubmission Review%'
                                                ,'%closure request%','%Dispute closure%','%ineligible dispute%')
                              and (fromemail ilike '%@halomd.com%' 
                                or fromemail ilike '%@md-management.net%')  THEN 'REQUEST_TO_WITHDRAW_DISPUTE'
                              when a.body ilike any ('%mark as ineligible%','%request the closure%',
                                                    '%request closure%')
                               and (fromemail ilike '%@halomd.com%' 
                                 or fromemail ilike '%@md-management.net%') THEN 'REQUEST_TO_WITHDRAW_DISPUTE'              
                              when a.subject ilike '%additional information complete%'    THEN 'INFO_REQUEST_COMPLETE'
                              when a.subject ilike '%confirmation%info%received%'         THEN 'INFO_REQUEST_COMPLETE' 
                              when a.subject ilike any ('%Additional Info%Needed%','%Request for%Info%','%additional info%requested%'
                                    ,'%reminder%additional info%','%disp%case%Needed')  THEN 'REQUEST_FOR_INFORMATION'
                              when a.body ilike any ('%attached requested information%','%Additional Information Requested%'  
                                                  ,'%please provide the required evidence to support your dispute%'
                                                  ,'%Your proof should be ATTACHED as a REPLY to this email%')
                                                                                        THEN 'REQUEST_FOR_INFORMATION'              
                    	END AS EMAILTYPE2                  
                   ,case when a.subject ilike '%initiation%resubmission%'      THEN 'Resubmission'
                         when a.subject ilike '%cool%'                         THEN 'Cooling'  
                         when a.body ilike '%cool%'                            THEN 'Cooling'  
                         when  a.body ilike '%updated the health plan type%'  
                          and  sender_cms_YN = 1 and receiver_halomd_YN = 1     THEN 'Plan Type'
                         when  a.body ilike '%updated the health plan type%'  
                          and  sender_sound_YN = 1 and receiver_halomd_YN = 1   THEN 'Plan Type'
                         when a.body ilike '%rescinded%'                        THEN 'Award Rescinded/Vacated'
                         when a.subject ilike '%vacated%'                       THEN 'Award Rescinded/Vacated'            
                    end AS ExceptionType
                , case when a.body ilike any ('%State law%','%State specified law%','%State arbitration%'
                                   ,'%State process%')                          THEN 'State'
                       when a.body like any ('%SSL %','%SSL%','% SSL%')      THEN 'State'-- keep case sensitive          
                       when a.subject ilike any ('%State law%','%State specified law%','%State arbitration%'
                                    ,'%State process%')                          THEN 'State'
                       when a.subject like any ('%SSL %','%SSL%','% SSL%')   THEN 'State'  -- keep case sensitive
                       when a.subject ilike any ('%in-network%','%in network%')   THEN 'In-Network'
                       when a.body ilike any ('%in-network%','%in network%')       THEN 'In-Network'
        
                       end AS IneligibilityReason    
              , a.subject
              , a.body        
              , fromemail as fromemail
              , toemail as toemail
              , emailedcustomer as customer_acronym
              , REGEXP_SUBSTR(a.body, 'DISP-\\d+') AS DisputeNumber      
              , emaildate as cst_received_timestamp          
    
    from        raw.dwsql.SRC_IDRSUPPORT_EMAILS  a    
    left join OPS.Public.T1 b
    on        a.subject = b.subject
    and       a.body    = b.body
    where     b.subject is null
    and       coalesce(fromemail,'')   not ilike '%microsoft%' 
    and       coalesce(toemail,'') not ilike '%microsoft%'   
    ) a
where EMAILTYPE2 not IN ('FEE_PAYMENT_DUE','FEE_RELATED','FEES_RECEIVED_NOTIFICATION','NSA_OPEN_NEGOTIATION'
                        ,'UNDELIVERABLE','READ_RECEIPTS','NSA_ON_INELIGIBLE','INTERNAL_EMAILS','CMS_UNCATEGORIZED'
                        ,'INFO_REQUEST_COMPLETE','REQUEST_FOR_INFORMATION');
========================================================================================================================

Create or Replace TEMPORARY Table OPS.Public.MultiDisp as      
    SELECT distinct
        t.subject,
        t.body,
        cst_received_timestamp,
        'Snowflake' AS EmailSource,
        REGEXP_SUBSTR(t.body, 'DISP-\\d+', 1, g.seq + 1) AS DisputeNumber2
    FROM OPS.Public.T1 t,
         LATERAL (
             SELECT seq4() AS seq 
             FROM TABLE(GENERATOR(ROWCOUNT => 100))
         ) g
    WHERE REGEXP_SUBSTR(t.body, 'DISP-\\d+', 1, g.seq + 1) IS NOT NULL
    and    exceptiontype is null
    union all
    SELECT distinct
        t.subject,
        t.body,
        cst_received_timestamp,
        'Jitbit' AS EmailSource,
        REGEXP_SUBSTR(t.body, 'DISP-\\d+', 1, g.seq + 1) AS DisputeNumber2
    FROM OPS.Public.T1J t,
         LATERAL (
             SELECT seq4() AS seq 
             FROM TABLE(GENERATOR(ROWCOUNT => 100))
         ) g
    WHERE REGEXP_SUBSTR(t.body, 'DISP-\\d+', 1, g.seq + 1) IS NOT NULL
    and    exceptiontype is null;
  ===========================================================  
Create or Replace TEMPORARY Table OPS.Public.MultiDisp2 as      
select  a.*
from    OPS.Public.MultiDisp a
left join ( select      body, subject, cst_received_timestamp, max(len(disputenumber2)) AS LongestDisp
            from        OPS.Public.MultiDisp a
            group by    body, subject, cst_received_timestamp
            having      count(*) > 1
          ) b
on      a.body = b.body
and     a.subject = b.subject
and     a.cst_received_timestamp = b.cst_received_timestamp
where     len(a.disputenumber2) >= LongestDisp - 1;
=================================================================

Create or Replace TEMPORARY Table OPS.Public.T2 as 
select      a.*
          , coalesce(multi.DisputeNumber2, a.dispute_number) AS DisputeNumber2
          , case when ExceptionType = 'Cooling' 
                  and (current_date() < dateadd('d',90,a.cst_received_timestamp)) THEN NULL
                 when ExceptionType = 'Cooling' 
                  and (current_date() < dateadd('d',90,a.cst_received_timestamp)) THEN NULL
                 ELSE ExceptionType END AS ExceptionType2
          , dm.disputestatus
          , cpt.AllIneligible_YN
          , cpt.AnyIneligible_YN
          , cpt.ArbitIDs
          , dm.idreselectiondate
          , case when det.TOTALAWARDAMOUNT is not null THEN 1 ELSE 0 END AS DisputeAward_YN
          , det.awarddate  
          , case when dm.disputenumber is not null then 1 else 0 END AS InDisputeMaster_YN
          , case when dm.certifiedentity ilike '%C2C%Solution%'					THEN 'C2C Innovative Solutions, Inc.'
				 when dm.certifiedentity ilike '%EdiPhy%'						THEN 'EdiPhy Advisors, L.L.C.'
				 when dm.CertifiedEntity ilike '%Federal Hearings and Appeals%' THEN 'Federal Hearings and Appeals Services'
				 when dm.CertifiedEntity ilike '%fhas%'							THEN 'Federal Hearings and Appeals Services'
				 when dm.CertifiedEntity ilike '%iMPROve Health%'				THEN 'iMPROve Health'
				 when dm.CertifiedEntity ilike '%Island Peer Review%'			THEN 'IPRO/Island Peer Review Organization'
				 when dm.CertifiedEntity ilike '%Keystone Peer Review%'			THEN 'Keystone Peer Review Organization, Inc.'
				 when dm.CertifiedEntity ilike '%Maximus%'						THEN 'Maximus Federal Services, Inc.'
				 when dm.CertifiedEntity ilike '%MCMC%'							THEN 'MCMC Services, LLC'
				 when dm.CertifiedEntity ilike '%Medical Evaluators of Texas%'	THEN 'Medical Evaluators of Texas'
				 when dm.CertifiedEntity ilike '%National Medical Reviews%'		THEN 'National Medical Reviews, Inc.'
				 when dm.CertifiedEntity ilike '%Network Medical Review%'		THEN 'Network Medical Review Company, Ltd.'
				 when dm.CertifiedEntity ilike '%ProPeer Resources%'			THEN 'ProPeer Resources, LLC'
				 when dm.CertifiedEntity ilike '%Provider Resources%'			THEN 'Provider Resources, Inc.'
			end  AS CertifiedEntityClean            
from       (select * from OPS.Public.T1 
            union 
            select * from OPS.Public.T1J) a
left join   OPS.Public.MultiDisp2 multi
on          a.body = multi.body
and         a.subject = multi.subject
and         a.cst_received_timestamp = multi.cst_received_timestamp

left join  CORE.SRC_IDRSUPPORT.DISPUTEMASTER dm
on         coalesce(multi.disputenumber2, a.dispute_number)  = dm.disputenumber
left join  (select disputenumber
                 , MIN(case when nsastatus ilike '%INELIGIBLE%' THEN 1 ELSE 0 END) AS AllIneligible_YN
                 , MAX(case when nsastatus ilike '%INELIGIBLE%' THEN 1 ELSE 0 END) AS AnyIneligible_YN
                 , listagg(concat(arbitid,' - ',nsastatus ),', ')                  AS ArbitIDs
            from (
                select     a.disputenumber
                         , a.arbitid
                         , b.nsastatus 
                from       CORE.SRC_IDRSUPPORT.DISPUTECPT a
                left join  CORE.ARBITRATION.ARBITRATIONCASES  b
                on         a.arbitid = b.id       
                and        b.ISDELETED = FALSE 
                WHERE      a.issoftdelete = 0
                GROUP BY   a.disputenumber
                         , a.arbitid
                         , b.nsastatus 
                ) a
            group by disputenumber                
            ) cpt
on         coalesce(multi.disputenumber2, a.dispute_number)  = cpt.disputenumber
left join   CORE.SRC_IDRSUPPORT.DISPUTEAWARDDETERMINATIONS det
on          coalesce(multi.disputenumber2, a.dispute_number) = det.disputenumber;
 ===========================================================   
     
Create or Replace TEMPORARY Table OPS.Public.T3 as 
 select  
       case when emailtype2 = 'INELIGIBLE EMAIL' 
             AND (sender_halomd_YN = 1 or sender_sound_YN = 1)
             and (Receiver_IDRE_YN = 1 or Receiver_CMS_YN = 1)
            THEN cst_received_timestamp --END AS "Halo - IDRE Ineligibility Reply Date",
            when emailtype2 = 'INELIGIBILITY CONTESTED' 
             AND (sender_halomd_YN = 1 or sender_sound_YN = 1)
             and (Receiver_IDRE_YN = 1 or Receiver_CMS_YN = 1)
            THEN cst_received_timestamp --END AS "Halo - IDRE Ineligibility Reply Date",
            when emailtype2 = 'CONFIRMED'
             AND (sender_halomd_YN = 1 or sender_sound_YN = 1)
             and (Receiver_IDRE_YN = 1 or Receiver_CMS_YN = 1)
            THEN cst_received_timestamp END AS "Halo - IDRE Ineligibility Reply Date",
            
        case when emailtype2 = 'INELIGIBLE EMAIL'
             and Sender_IDRE_YN = 1
             THEN cst_received_timestamp END AS "IDRE - IDRE Ineligibility Date",
           case when emailtype2 = 'INELIGIBLE EMAIL'
             and (Receiver_IDRE_YN = 0 and Receiver_CMS_YN = 0)
             and (sender_halomd_YN = 1 or sender_sound_YN = 1) -- CMS
             THEN 1 else 0 END AS "Halo - Ineligibility Not to IDRE",
             
        case when emailtype2 = 'WITHDRAWAL REQUEST' 
             AND (sender_halomd_YN = 1 or sender_sound_YN = 1)
             and (Receiver_IDRE_YN = 1 or Receiver_CMS_YN = 1)
            THEN cst_received_timestamp END AS "Halo - Withdrawal Request Date",  
           case when emailtype2 = 'WITHDRAWAL REQUEST'
                 and (Receiver_IDRE_YN = 0 and Receiver_CMS_YN = 0)
                 and (sender_halomd_YN = 1 or sender_sound_YN = 1)
                THEN 1 else 0 END AS "Halo - Invalid Withdrawal Request YN", 
                
        case when emailtype2 = 'CONFIRMED'
             and Sender_IDRE_YN = 1
            THEN cst_received_timestamp END AS "IDRE - Withdrawal Confirmed Date",

 
           case when emailtype2 = 'INELIGIBILITY WITHDRAWN' 
             and Sender_IDRE_YN = 1  
             THEN cst_received_timestamp END AS "IDRE - Ineligibility Withdrawn Date",
            
            case when emailtype2 = 'INFO REQUEST' 
             and Sender_IDRE_YN = 1  
             THEN cst_received_timestamp END AS "IDRE - Info Request Date",
             
            case when emailtype2 = 'INFO REQUEST' 
             and Receiver_IDRE_YN = 1 and sender_halomd_YN = 1             
             THEN cst_received_timestamp END AS "IDRE - Info Request Response Date", 
             
          case when emailtype2 = 'INFO REQUEST COMPLETE'  
             and Sender_IDRE_YN = 1  
              THEN cst_received_timestamp END AS "IDRE - Info Request Complete Date",           

           case when emailtype2 = 'INELIGIBLE EMAIL' 
             AND (sender_halomd_YN = 1 or sender_sound_YN = 1)
             and Receiver_IDRE_YN = 1 
            THEN cst_received_timestamp -- END AS "Halo - IDRE Ineligibility Reply Date",
            when emailtype2 = 'WITHDRAWAL REQUEST' 
             AND (sender_halomd_YN = 1 or sender_sound_YN = 1)
             and Receiver_IDRE_YN = 1
            THEN cst_received_timestamp --END AS "Halo - Withdrawal Request Date",         
            when emailtype2 = 'CONFIRMED'
             and Sender_IDRE_YN = 1
            THEN cst_received_timestamp --END AS "IDRE - Withdrawal Confirmed Date",
            when emailtype2 = 'INELIGIBLE EMAIL'
             and Sender_IDRE_YN = 1
             THEN cst_received_timestamp -- END AS "IDRE - IDRE Ineligibility Date",
            when emailtype2 = 'INELIGIBILITY WITHDRAWN' 
             and Sender_IDRE_YN = 1  
             THEN cst_received_timestamp
             when exceptiontype2 is not null then cst_received_timestamp
                  
            when emailtype2 = 'INFO REQUEST' 
             and Receiver_IDRE_YN = 1 and sender_halomd_YN = 1             
             THEN cst_received_timestamp -- END AS "IDRE - Info Request Response Date"
             
            when emailtype2 = 'INELIGIBILITY WITHDRAWN' 
             and Sender_IDRE_YN = 1  
             THEN cst_received_timestamp
             
             when emailtype2 = 'INFO REQUEST' 
              and Sender_IDRE_YN = 1  
              THEN cst_received_timestamp
             when emailtype2 = 'INFO REQUEST COMPLETE'  
              and Sender_IDRE_YN = 1  
              THEN cst_received_timestamp              
               END 
             AS LastEmailOfInterestDate,                  
           case when Receiver_IDRE_YN = 0 and Receiver_CMS_YN = 1 then 'Sent to CMS Only'
                when idre <> concat('IDRE - ',CertifiedEntityClean)
                and Receiver_CMS_YN = 1  then 'Sent to CMS Only'
                when idre <> concat('IDRE - ',CertifiedEntityClean)
                and Receiver_CMS_YN = 0  then 'Wrong IDRE'
           end AS ReceiverIssue
           ,*
   from    OPS.Public.T2 
   where   disputenumber2 is not null
   and     upper(coalesce(disputestatus,'')) not IN ('INELIGIBLE','WITHDRAWN');
        

Create or Replace TEMPORARY Table OPS.Public.MG_Ineligibility as
select  * 
from    (
        select case when max(case when ExceptionType2 = 'Resubmission' then 1 else 0 end) = 1 THEN 'Resubmission'
                   -- when max(case when ExceptionType2 = 'Cooling' then 1 else 0 end) = 1      THEN 'Cooling'
                 --   when max(case when ExceptionType2 = 'Plan Type' then 1 else 0 end) = 1    THEN 'Plan Type'
                    when max(case when ExceptionType2 = 'Award Rescinded/Vacated' then 1 else 0 end) = 1    THEN 'Award Rescinded/Vacated'
                    
                    
                    when max("IDRE - Ineligibility Withdrawn Date") > coalesce(max("IDRE - IDRE Ineligibility Date"),'1/1/1900')
                     and max("IDRE - Ineligibility Withdrawn Date") > coalesce(max("IDRE - Withdrawal Confirmed Date"),'1/1/1900')
                     and max("IDRE - Ineligibility Withdrawn Date") > coalesce(max("Halo - IDRE Ineligibility Reply Date"),'1/1/1900')                       
                    then 'IDRE Ineligibility / IDRE Withdrew Ineligibility'
                    
                    when max("Halo - Withdrawal Request Date") is not null and max("IDRE - Withdrawal Confirmed Date") is not null  
                    THEN 'Halo Withdrawal Request / IDRE Confirmed Ineligibility'              
        
                   -- when max("Halo - Withdrawal Request Date") < max("Halo - IDRE Ineligibility Reply Date")  
                   -- THEN 'Halo Withdrawal Request / IDRE Ineligibility'              
                                        
                    when max("Halo - Withdrawal Request Date") is not null
                     and max("IDRE - Withdrawal Confirmed Date") is null
                     and max("IDRE - IDRE Ineligibility Date") is null
                    THEN 'Halo Withdrawal Request / No IDRE Response'                    
                    
                    when (max("IDRE - IDRE Ineligibility Date") is not null
                      or max("IDRE - Withdrawal Confirmed Date") is not null)
                     and max("Halo - Withdrawal Request Date") is null
                     and max("Halo - IDRE Ineligibility Reply Date") is null
                     THEN 'Ineligibility by IDRE / No Halo Response'
                               
                    when min("IDRE - Ineligibility Withdrawn Date") is not null
                     and max("IDRE - Ineligibility Withdrawn Date") > coalesce(max("IDRE - IDRE Ineligibility Date"),'1/1/1900')
                     and max("IDRE - Ineligibility Withdrawn Date") > coalesce(max("IDRE - Withdrawal Confirmed Date"),'1/1/1900')                     
                    then 'IDRE Ineligibility / IDRE Withdrew Ineligibility'

                    when max("Halo - IDRE Ineligibility Reply Date") > coalesce(max("IDRE - IDRE Ineligibility Date"),'1/1/1900')
                     and max("Halo - IDRE Ineligibility Reply Date") > coalesce(max("IDRE - Ineligibility Withdrawn Date"),'1/1/1900')                                                and max("Halo - IDRE Ineligibility Reply Date") > coalesce(max("IDRE - Withdrawal Confirmed Date"),'1/1/1900')                              
                     and max("Halo - IDRE Ineligibility Reply Date") > coalesce(min("IDRE - IDRE Ineligibility Date"),'1/1/1900')                                                     and max("Halo - IDRE Ineligibility Reply Date") > coalesce(min("IDRE - Withdrawal Confirmed Date"),'1/1/1900')                              
                    then 'Ineligibility by IDRE / Halo Replied / No IDRE Response'     

                    when max("Halo - IDRE Ineligibility Reply Date") is not null 
                     and max("IDRE - IDRE Ineligibility Date") > coalesce(max("Halo - IDRE Ineligibility Reply Date"),'1/1/1900')
                     and max("IDRE - IDRE Ineligibility Date") > coalesce(max("IDRE - Ineligibility Withdrawn Date"),'1/1/1900') 
                    then 'Ineligibility by IDRE / Halo Replied / IDRE Confirmed'    -- break into no Halo response vs yes response vs to just CMS/wrong IDRE   
                    
                    when max("Halo - IDRE Ineligibility Reply Date") is not null 
                     and max("IDRE - IDRE Ineligibility Date") > coalesce(max("Halo - IDRE Ineligibility Reply Date"),'1/1/1900')
                     and max("IDRE - IDRE Ineligibility Date") > coalesce(max("IDRE - Ineligibility Withdrawn Date"),'1/1/1900') 
                    then 'Ineligibility by IDRE / Halo Replied / IDRE Response Last' -- break into no Halo response vs yes response vs to just CMS/wrong IDRE   
                  
                    when max("IDRE - Info Request Complete Date") is not null and max("IDRE - Withdrawal Confirmed Date") is not null                      
                    THEN 'Info Request / IDRE Confirmed Ineligibility'                        

                    when max("IDRE - Info Request Date") is not null and max("IDRE - Withdrawal Confirmed Date") is not null                      
                    THEN 'Info Request / IDRE Confirmed Ineligibility'                    
                  when max("IDRE - Info Request Complete Date") is not null
                    then 'Info Request / IDRE Confirmed Request Complete'
                  when max("IDRE - Info Request Response Date") >= max("IDRE - Info Request Date")
                    then 'Info Request / Halo Replied'                    
                  when max("IDRE - Info Request Date") > coalesce(max("IDRE - Info Request Complete Date"),'1/1/1900')
                    then 'Info Request / No Halo Response'
                  --  else 'Exception'
                    end AS IneligibilityStatus 
              , disputenumber2
              , disputestatus
              , max(IneligibilityReason) AS IneligibilityReason
              , CertifiedEntityClean AS IDRE
              , case when max(coalesce(AnyIneligible_YN,0)) = 1 THEN 'NSA Case(s) Ineligible'
                     when max(coalesce(AnyIneligible_YN,0)) = 0 THEN 'NSA Case(s) Active'
                end          as NSACaseStatus
              , max(a.arbitids) AS arbitids
              --, max(a.DisputeAward_YN) AS DisputeAward_YN
              , max("Halo - Withdrawal Request Date")       AS "Halo - Last Withdrawal Request Date"
              , max("IDRE - Withdrawal Confirmed Date")     AS "IDRE - Last Withdrawal Confirmed Date"
              , max("IDRE - IDRE Ineligibility Date")       AS "IDRE - Last IDRE Ineligibility Date"              
              , max("Halo - IDRE Ineligibility Reply Date") AS "Halo - Last IDRE Ineligibility Reply Date"
              , max("IDRE - Ineligibility Withdrawn Date")  AS "IDRE - Last Ineligibility Withdrawn Date" 
              , max("IDRE - Info Request Date")             AS "IDRE - Info Request Date"  
              , max("IDRE - Info Request Complete Date")    AS "IDRE - Info Request Complete Date"
              
              , case when max(LastEmailOfInterestDate) <= dateadd(d,-30,getdate())
                      and max(a.DisputeAward_YN) = 0 THEN 'No Award, 30 Days Since Last Email'
                     when max(a.DisputeAward_YN) = 1 THEN 'Awarded'
                     ELSE 'Award Pending'
                     END AS AwardDateBucket
              , case when max(idreselectiondate) <= dateadd(d,-60,getdate())
                      and max(a.DisputeAward_YN) = 0 THEN 'No Award, 60 Days Since IDRE Assigned'
                     when max(a.DisputeAward_YN) = 1 THEN 'Awarded'
                     ELSE 'Award Pending'
                     END AS AwardDateBucket2                     
              , max(LastEmailOfInterestDate)  AS LastEmailOfInterestDate 
              , current_date() AS LastUpdateDate
        from        OPS.Public.T3 a         
        where       coalesce(ReceiverIssue,'') <> 'Wrong IDRE'
        and         LastEmailOfInterestDate is not null
        group by    disputenumber2, CertifiedEntityClean, disputestatus
        ) a;
