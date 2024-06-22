/**
    Name: OpportunityLineItemScheduleHandler
    Author: Vertex Computer Systems Inc
    Description: Establishes Revenue Schedules for Opportunity Line Items. As of now, only monthly schedules are established using the number of months field on the Opportunity Line Item object.

**/

public class OpportunityLineItemScheduleHandler{

     /**
        Name: handleInsertUpdate
        Description: common method for handling both insert and updates. This method is invoked by after insert/after update trigger on 
                     OpportunityLineItem and after update trigger on Opportunity.
        Parameters:
            a) lineitems: List of lineitems to possibly create schedules for
            b) jobStartDateChanged: Set to true if the method was called as a result of job start date field changing on the Opportunity.
        
        returns: void
        
    **/
   public static void handleInsertUpdate(OpportunityLineItem[] lineItems,boolean jobStartDateChanged){
       OpportunityLineItem[] lineItemsToUpdate = new OpportunityLineItem[]{};
     
                        
       for(OpportunityLineItem opLnItm: (OpportunityLineItem[])[Select Id,TotalPrice,HasRevenueSchedule,UnitPrice,Opportunity.Job_Start_Date__c,Number_of_Months__c, PricebookEntry.Product2.Create_Single_Revenue_Schedule__c,isClone__c from OpportunityLineItem where Id in :lineItems]){
                  
        
            /* Re-establish schedules if at least one of the following conditions are satisfied:
                a) This is a new Opportunity line item
                b) The Opportunity job start date has changed
                c) The total price has changed (either unit price or quantity changed), and there are no existing schedules. The check for existing schedules prevents user edits to an existing schedule from triggering an auto recalculation
                d) The number of monthly installments has changed
            */
           
              if((Trigger.isInsert || jobStartDateChanged  || opLnItm.isClone__c ||
                (opLnItm.TotalPrice!=((OpportunityLineItem)Trigger.oldMap.get(opLnItm.Id)).TotalPrice && !opLnItm.HasRevenueSchedule)|| 
            (opLnItm.PricebookEntry.Product2.Create_Single_Revenue_Schedule__c == false && opLnItm.Number_of_Months__c!=((OpportunityLineItem)Trigger.oldMap.get(opLnItm.Id)).Number_of_Months__c)) &&
                   opLnItm.TotalPrice !=null && opLnItm.TotalPrice!=0 && opLnItm.Number_of_Months__c!=null && opLnItm.Opportunity.Job_Start_Date__c!=null  ){
                    lineItemsToUpdate.add(opLnItm);
                   
                    }
            
        }

        System.Debug('lineItemsToUpdate '+lineItemsToUpdate.size());
        
        if(lineItemsToUpdate.size()>0){
           // if(Trigger.isUpdate)
                updateScheduleDates(lineItemsToUpdate);
            /*else
                futureMethod(lineItemsToUpdate);*/
        }  
   }

   /**
        Name: isLastDayOfMonth
        Description: Returns true if the given date is the last day of the month. False, if not. 
        Note: Leap years are treated as regular years.
        Parameters: inpDate - the date
   **/
   private static boolean isLastDayOfMonth(Date inpDate){
       Integer month = inpDate.month();
       Integer day = inpDate.day();
       Set<Integer> monthsWith30days = new Set<Integer>{4,6,9,11};
       if(monthsWith30days.contains(month) && day>=30){
           return true;
       }else if(month==2 && day>=28){
           return true;
       }else if(day>=31){
           return true;
       }else{
           return false;
       }
   }

    /**
        Name: getLastDayOfMonth
        Description: given a month, returns the last day of the month. 28 for Feb even for leap years
        Parameters: Input month
    **/
    private static Integer getLastDayOfMonth(Integer month){
       month = Integer.valueOf(Math.floor(month/13))+Math.mod(month,13);
       Set<Integer> monthsWith30days = new Set<Integer>{4,6,9,11};
       if(monthsWith30days.contains(month)){
           return 30;
       }else if(month==2){
           return 28;
       }else
            return 31;
   }


   /**
        Description: Establishes revenue schedules. If there are existing schedules, they are deleted before the new schedules are inserted. When a new line item is created, if it has scheduling enabled, Salesforce automatically creates schedules. These are deleted in this method as well. If the Opportunity Job start date is last day of a month, all schedules are adjusted to be on the last days of the respective months.
   **/
   private static void updateScheduleDates(OpportunityLineItem[] lineItems){
        OpportunityLineItemSchedule[] schedules = new OpportunityLineItemSchedule[]{};
        
      
        for(OpportunityLineItem opLnItm: lineItems){
            Integer i=0;
          
             //we start from the Opportunity job start date
            Date initialDate = opLnItm.Opportunity.Job_Start_Date__c;

            //Determine if the job start date is last day of month
            boolean isLastDayOfMonth = isLastDayOfMonth(initialDate);
            system.debug('opLnItm.TotalPrice--->'+opLnItm.TotalPrice);
            Decimal totalPrice = opLnItm.TotalPrice==null?0:opLnItm.TotalPrice;
            OpportunityLineItemSchedule sch = null;
        
            system.debug('totalPrice--->'+totalPrice);
                      
            // Use the Number of months picklist to get the number of installments to be created. If its blank, use 1
            system.debug('opLnItm.Number_of_Months__c--->'+opLnItm.Number_of_Months__c);
            Integer numOfSchedules = Integer.valueOf(opLnItm.Number_of_Months__c);
            if(opLnItm.PricebookEntry.Product2.Create_Single_Revenue_Schedule__c){
                numOfSchedules = 1;
            }
            //Divide the revenue equally amongst the installments
            Decimal price = (totalPrice/numOfSchedules);
            system.debug('price--->'+price);
            do{
                Date scheduleDate = Date.newInstance(initialDate.year(),initialDate.month()+i,
                                        isLastDayOfMonth?getLastDayOfMonth(initialDate.month()+i):initialDate.day());
                sch = new OpportunityLineItemSchedule(OpportunityLineItemId=opLnItm.Id,Type='Revenue',Revenue=price,ScheduleDate=scheduleDate,Description='Created by Revenue Installment Trigger');
                schedules.add(sch);
            }while(++i<numOfSchedules);
        }

        // Set save point so that if something goes wrong after we delete existing schedules, we can roll back
        SavePoint sp = Database.setSavepoint();
        try{
            // delete existing schedules            
            OpportunityLineItemSchedule[] existingSchedules = [Select Id from OpportunityLineItemSchedule where OpportunityLineItemID in :lineItems];
            if(existingSchedules.size()>0){
                delete existingSchedules;
            }            
            // add new schedules
            if(schedules.size()>0){
                insert schedules;
            }          
            
        }catch(DmlException ex){
            // If something fails, rollback to save point.
            Database.rollback(sp);
            throw ex;
        }
   }

}