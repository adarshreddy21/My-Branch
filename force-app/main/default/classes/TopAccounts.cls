public class TopAccounts {
   
    //this invocable method takes a single contact id from Flow from a record variable
    //and returns a list of lists of opportunities associated with that contact.
    //the list of lists is stored as a collection variable in the Flow.
    @InvocableMethod (label = 'Get Top Accounts By Location' description = 'returns top accounts by location.')
    
    //this method returns a List of Lists of Opps to the flow and receives a List of Ids
    public static List<List<WrapperForCAM>> getTopAccountsByLocation (List<Account> accounts) {
       Account acc =accounts.get(0);
        //Store in a list the id, closedate and Amounts of opps whose Primary Contact came in the variable "ids"
        //and who have a stage of Clsoed Won and a Close Date of this year
        AggregateResult[] results = [SELECT  ShippingCity, sum(Current_Year_Customer_Revenue__c) TotalAmount FROM Account where Key_Account_Name__c =:acc.Name 
			and status__c='Active' and win_id__c<>null
			group by ShippingCity order by sum(Current_Year_Customer_Revenue__c) desc limit 10]; 
        
        List<WrapperForCAM> wrapperAccounts=new List<WrapperForCAM>();
        for(AggregateResult result:results){
            WrapperForCAM wrapperAccount=new WrapperForCAM();
            wrapperAccount.amount = acc.CurrencyIsoCode+' '+ Decimal.valueOf(String.valueOf(result.get('TotalAmount')));
            wrapperAccount.shippingCity = String.valueOf(result.get('shippingCity'));
                
            wrapperAccounts.Add(wrapperAccount);
        }
        return new List<List<WrapperForCAM>>{wrapperAccounts};
    }  
}