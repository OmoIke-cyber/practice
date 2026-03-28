-- Mart model for ineligibility analysis
-- This model aggregates email data to determine ineligibility status and key metrics

with ineligibility_aggregation as (
    select 
        dispute_number_final as disputenumber,
        CertifiedEntityClean as IDRE,
        disputestatus,
        
        -- Determine ineligibility status based on email patterns
     case when max(case when exceptiontype2 = 'Resubmission' then 1 else 0 end) = 1 THEN 'Resubmission'
                   -- when max(case when ExceptionType2 = 'Cooling' then 1 else 0 end) = 1      THEN 'Cooling',
                 --   when max(case when ExceptionType2 = 'Plan Type' then 1 else 0 end) = 1    THEN 'Plan Type',
                    when max(case when ExceptionType2 = 'Award Rescinded/Vacated' then 1 else 0 end) = 1    THEN 'Award Rescinded/Vacated'
                    
                    
                    when max('IDRE - Ineligibility Withdrawn Date') > coalesce(max('IDRE - IDRE Ineligibility Date'),'1/1/1900')
                     and max('IDRE - Ineligibility Withdrawn Date') > coalesce(max('IDRE - Withdrawal Confirmed Date'),'1/1/1900')
                     and max('IDRE - Ineligibility Withdrawn Date') > coalesce(max('Halo - IDRE Ineligibility Reply Date'),'1/1/1900')                       
                    then 'IDRE Ineligibility / IDRE Withdrew Ineligibility'
                    
                    when max('Halo - Withdrawal Request Date') is not null and max('IDRE - Withdrawal Confirmed Date') is not null  
                    THEN 'Halo Withdrawal Request / IDRE Confirmed Ineligibility'            
        
                   -- when max('Halo - Withdrawal Request Date') < max('Halo - IDRE Ineligibility Reply Date')  
                   -- THEN 'Halo Withdrawal Request / IDRE Ineligibility'              
                                        
                    when max('Halo - Withdrawal Request Date') is not null
                     and max('IDRE - Withdrawal Confirmed Date') is null
                     and max('IDRE - IDRE Ineligibility Date') is null
                    THEN 'Halo Withdrawal Request / No IDRE Response'                    
                    
                    when (max('IDRE - IDRE Ineligibility Date') is not null
                      or max('IDRE - Withdrawal Confirmed Date') is not null)
                     and max('Halo - Withdrawal Request Date') is null
                     and max('Halo - IDRE Ineligibility Reply Date') is null
                     THEN 'Ineligibility by IDRE / No Halo Response'
                               
                    when min('IDRE - Ineligibility Withdrawn Date') is not null
                     and max('IDRE - Ineligibility Withdrawn Date') > coalesce(max('IDRE - IDRE Ineligibility Date'),'1/1/1900')
                     and max('IDRE - Ineligibility Withdrawn Date') > coalesce(max('IDRE - Withdrawal Confirmed Date'),'1/1/1900')                     
                    then 'IDRE Ineligibility / IDRE Withdrew Ineligibility'

                    when max('Halo - IDRE Ineligibility Reply Date') > coalesce(max('IDRE - IDRE Ineligibility Date'),'1/1/1900')
                     and max('Halo - IDRE Ineligibility Reply Date') > coalesce(max('IDRE - Ineligibility Withdrawn Date'),'1/1/1900')                                                and max('Halo - IDRE Ineligibility Reply Date') > coalesce(max('IDRE - Withdrawal Confirmed Date'),'1/1/1900')                              
                     and max('Halo - IDRE Ineligibility Reply Date') > coalesce(min('IDRE - IDRE Ineligibility Date'),'1/1/1900')                                                     and max('Halo - IDRE Ineligibility Reply Date') > coalesce(min('IDRE - Withdrawal Confirmed Date'),'1/1/1900')                              
                    then 'Ineligibility by IDRE / Halo Replied / No IDRE Response'    

                    when max('Halo - IDRE Ineligibility Reply Date') is not null 
                     and max('IDRE - IDRE Ineligibility Date') > coalesce(max('Halo - IDRE Ineligibility Reply Date'),'1/1/1900')
                     and max('IDRE - IDRE Ineligibility Date') > coalesce(max('IDRE - Ineligibility Withdrawn Date'),'1/1/1900') 
                    then 'Ineligibility by IDRE / Halo Replied / IDRE Confirmed'    -- break into no Halo response vs yes response vs to just CMS/wrong IDRE   
                    
                    when max('Halo - IDRE Ineligibility Reply Date') is not null 
                     and max('IDRE - IDRE Ineligibility Date') > coalesce(max('Halo - IDRE Ineligibility Reply Date'),'1/1/1900')
                     and max('IDRE - IDRE Ineligibility Date') > coalesce(max('IDRE - Ineligibility Withdrawn Date'),'1/1/1900') 
                    then 'Ineligibility by IDRE / Halo Replied / IDRE Response Last' -- break into no Halo response vs yes response vs to just CMS/wrong IDRE   
                  
                    when max('IDRE - Info Request Complete Date') is not null and max('IDRE - Withdrawal Confirmed Date') is not null                      
                    THEN 'Info Request / IDRE Confirmed Ineligibility'                       

                    when max('IDRE - Info Request Date') is not null and max('IDRE - Withdrawal Confirmed Date') is not null                      
                    THEN 'Info Request / IDRE Confirmed Ineligibility'                    
                  when max('IDRE - Info Request Complete Date') is not null
                    then 'Info Request / IDRE Confirmed Request Complete'
                  when max('IDRE - Info Request Response Date') >= max('IDRE - Info Request Date')
                    then 'Info Request / Halo Replied'                    
                  when max('IDRE - Info Request Date') > coalesce(max('IDRE - Info Request Complete Date'),'1/1/1900')
                    then 'Info Request / No Halo Response'
                  --  else 'Exception'
                    end AS IneligibilityStatus,

        -- Aggregate other fields
        max(IneligibilityReason) AS IneligibilityReason,
        
         case when max(coalesce(AnyIneligible_YN,0)) = 1 THEN 'NSA Case(s) Ineligible'
                     when max(coalesce(AnyIneligible_YN,0)) = 0 THEN 'NSA Case(s) Active'
                end          as NSACaseStatus
              , 
          max(arbitids) AS arbitids
        
        -- Key dates
              --, max(DisputeAward_YN) AS DisputeAward_YN
               , max('Halo - Withdrawal Request Date')       AS "Halo - Last Withdrawal Request Date"
              , max('IDRE - Withdrawal Confirmed Date')     AS "IDRE - Last Withdrawal Confirmed Date"
              , max('IDRE - IDRE Ineligibility Date')       AS "IDRE - Last IDRE Ineligibility Date"            
              , max('Halo - IDRE Ineligibility Reply Date') AS "Halo - Last IDRE Ineligibility Reply Date"
              , max('IDRE - Ineligibility Withdrawn Date')  AS "IDRE - Last Ineligibility Withdrawn Date"
              , max('IDRE - Info Request Date')             AS "IDRE - Info Request Date"
              , max('IDRE - Info Request Complete Date')    AS "IDRE - Info Request Complete Date"
        
        -- Award status buckets
                , case when max(LastEmailOfInterestDate) <= dateadd(d,-30,getdate())
                      and max(DisputeAward_YN) = 0 THEN 'No Award, 30 Days Since Last Email'
                     when max(DisputeAward_YN) = 1 THEN 'Awarded'
                     ELSE 'Award Pending'
                     END AS AwardDateBucket
              , case when max(idreselectiondate) <= dateadd(d,-60,getdate())
                      and max(DisputeAward_YN) = 0 THEN 'No Award, 60 Days Since IDRE Assigned'
                     when max(DisputeAward_YN) = 1 THEN 'Awarded'
                     ELSE 'Award Pending'
                     END AS AwardDateBucket2                     
              , max(LastEmailOfInterestDate)  AS LastEmailOfInterestDate 
              , current_date() AS LastUpdateDate
        
    from {{ ref('stg_email_date_calculations') }}
    group by dispute_number_final, CertifiedEntityClean, disputestatus
)

select *
from ineligibility_aggregation
