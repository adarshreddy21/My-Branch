trigger FinancialTrigger on Financials__c (after insert, after update) {
    TriggerDispatcher.Run(new FinancialTriggerHandler());
}