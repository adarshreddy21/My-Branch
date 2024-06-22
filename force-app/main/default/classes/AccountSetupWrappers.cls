public class AccountSetupWrappers {
	public class AccountDataWrapper{
        @AuraEnabled public String epaId{get;set;}
        @AuraEnabled public String genRegId{get;set;}
        @AuraEnabled public String country{get;set;}
        @AuraEnabled public String generatorStatus{get;set;}
        @AuraEnabled public String stateEpaId{get;set;}
        @AuraEnabled public String shippingStreet{get;set;}
        @AuraEnabled public String shippingState{get;set;}
        @AuraEnabled public String shippingCity{get;set;}
        @AuraEnabled public String primaryServiceProvider{get;set;}
    }
     public class AccountResponseWrapper{
        @AuraEnabled public Boolean isEPAValid{get;set;}
        @AuraEnabled public AccountValidatorController.EPAIdResponse response{get;set;}
     }
    public class AccountWrapper
    {   
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public CorporateAddressWrapper CorporateAddress {get;set;}
        @AuraEnabled
        public String primaryServiceProviderNew {get;set;}
        @AuraEnabled
        public boolean sameAsCorpAddress {get;set;}
        @AuraEnabled
        public BillingAddressWrapper BillingAddress {get;set;}
        @AuraEnabled
        public ContactsWrapper[] contacts{get;set;}
        @AuraEnabled
        public String primaryBusiness{get;set;}
        @AuraEnabled
        public String parentId{get;set;}
        @AuraEnabled
		public String chainId{get;set;}
        @AuraEnabled
        public String epaId{get;set;}
        @AuraEnabled
        public String stateEpaId{get;set;}
        @AuraEnabled
        public String genRegId{get;set;}
        @AuraEnabled
        public String accountSource{get;set;}
        @AuraEnabled
        public String sicDesc{get;set;}
		@AuraEnabled
        public String sicCodeDescription{get;set;}
        @AuraEnabled
        public String rank{get;set;}
        @AuraEnabled
        public String taxExemptionType{get;set;}
        @AuraEnabled
        public String taxFileName{get;set;}
        @AuraEnabled
        public String generatorStatus{get;set;}
        @AuraEnabled
        public String documentId{get;set;}
        @AuraEnabled
        public String industrySegment{get;set;}
        @AuraEnabled
        public String skoSalesSegment{get;set;}
        @AuraEnabled
        public String accountClass{get;set;}
        @AuraEnabled
        public boolean manifestAddressSameAsCorp{get;set;}
        @AuraEnabled
        public String manifestAddress1{get;set;}
        @AuraEnabled
        public String manifestLocality1{get;set;}
        @AuraEnabled
        public String manifestRegionCode{get;set;}
        @AuraEnabled
        public String manifestPostalCode{get;set;}
        @AuraEnabled
        public String manifestCountryCode{get;set;}
        @AuraEnabled
        public String manifestAddress2{get;set;}
        @AuraEnabled
        public String accountPhone{get;set;}
        @AuraEnabled
        public Boolean autoCreateOpportunity{get;set;}
        @AuraEnabled
        public Id opportunityRecordTypeId{get;set;}
        @AuraEnabled
        public String duplicateReason{get;set;}
        @AuraEnabled
        public String duplicateJustification{get;set;}
        @AuraEnabled
        public String recordTypeId{get;set;}
        @AuraEnabled
        public String brokergroup{get;set;}
        @AuraEnabled
        public String currencyCode{get;set;} 		
         
        public AccountWrapper parse(String json){
            return (AccountWrapper) System.JSON.deserialize(json, AccountWrapper.class);
        }  
    } 
    public class CorporateAddressWrapper {
        @AuraEnabled
        public String ShippingStreet{get;set;}  
        @AuraEnabled
        public String ShippingCity{get;set;} 
        @AuraEnabled
        public String ShippingState{get;set;} 
        @AuraEnabled  
        public String ShippingPostalCode{get;set;}
        @AuraEnabled
        public String ShippingCountry{get;set;}  
        @AuraEnabled
        public String CorporateAddress2{get;set;}
    }
    
    public class BillingAddressWrapper {
        @AuraEnabled
        public String BillingStreet{get;set;}  
        @AuraEnabled
        public String BillingCity{get;set;}
        @AuraEnabled
        public String BillingState{get;set;}
        @AuraEnabled 
        public String BillingPostalCode{get;set;}
        @AuraEnabled
        public String BillingCountry{get;set;}
        @AuraEnabled
        public String BillingAddress2{get;set;}
    }
    
     public class ContactsWrapper {
        @AuraEnabled
        public String salutation{get;set;}
        @AuraEnabled
        public List<String> contactType{get;set;}
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled	
        public String title{get;set;}
        @AuraEnabled
        public String lastName{get;set;}
        @AuraEnabled
        public String phone{get;set;}	
        @AuraEnabled
        public String email{get;set;}	
        @AuraEnabled
        public String mobile{get;set;}	
        @AuraEnabled
        public boolean rltContact{get;set;}
        @AuraEnabled
        public String phoneExtension{get;set;}
        @AuraEnabled
        public id accountId{get;set;}
    }    
    
    public class OperationResult{
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String message{get;set;}
    }
}