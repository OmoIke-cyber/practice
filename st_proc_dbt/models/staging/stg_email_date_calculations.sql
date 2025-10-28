-- Intermediate model calculating email dates and business logic
-- This model processes the combined email data to extract key dates and classifications

with email_date_calculations as (
    select 
        *,
        
        -- Calculate key email dates based on email type and sender/receiver
      
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


 -- Calculate last email of interest date
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

       
        
        -- Identify receiver issues
           case when Receiver_IDRE_YN = 0 and Receiver_CMS_YN = 1 then 'Sent to CMS Only'
                when idre <> concat('IDRE - ',CertifiedEntityClean)
                and Receiver_CMS_YN = 1  then 'Sent to CMS Only'
                when idre <> concat('IDRE - ',CertifiedEntityClean)
                and Receiver_CMS_YN = 0  then 'Wrong IDRE'
           end AS ReceiverIssue
        
    from {{ ref('stg_combined_emails_with_disputes') }}
)

select *
from email_date_calculations
where coalesce(ReceiverIssue, '') <> 'Wrong IDRE'
  and LastEmailOfInterestDate is not null
