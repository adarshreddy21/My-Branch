public class AccountDuplicateSearch {
    /**
        * Return all accounts matching this address
        *  The field AnnualRevenue is misused to return the probability of match
        * Corporate address == Shipping Address
    */ 
    private static Id customerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
    private static Id brokerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_BROKER).getRecordTypeId();
    private static Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
    private static Id brokerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_BROKER_LOCATION).getRecordTypeId();
    private final Set<String> accountStatusToCheck = new Set<String>{'Active','Inactive'};
    private List<AbbreviationMapping__mdt> abbrList = AbbreviationMapping__mdt.getAll().values();
    public List<Account> classifyAndGetDuplicateAccounts(AccountSetupWrappers.AccountWrapper accWrapper) {
        Id parentId;
        Set<Id> childIds = new Set<Id>(); 
        if(accWrapper.recordTypeId != null && (accWrapper.recordTypeId == customerLocationAccountRecordType || accWrapper.recordTypeId == brokerLocationAccountRecordType))
        {
            
            List<AccountTokenisation__c> accsTokenMatch = new List<AccountTokenisation__c>();
            List<Account> accsMatchConsolidated = new List<Account>();
            AccountSetupWrappers.CorporateAddressWrapper shippingAddress = accWrapper.CorporateAddress;
            shippingAddress.ShippingCity = shippingAddress.ShippingCity.trim();
            if(shippingAddress.ShippingPostalCode != null  && shippingAddress.ShippingPostalCode.contains('-') && shippingAddress.ShippingCountry == 'US'){
                shippingAddress.ShippingPostalCode=shippingAddress.ShippingPostalCode.split('-')[0];
            }
            //first search parent 
            List<AccountTokenisation__c> accountTokensationsParentAccount = [SELECT Account__R.Id, Account__R.Name,Account__R.WIN_ID_Type__c,Account__R.Primary_Service_Provider_New__c,Account__R.Primary_Business__c, Account__R.ShippingStreet, Account__R.ShippingPostalCode, Account__R.ShippingCity, Account__R.ShippingCountry,Account__R.ShippingState,Account__R.AI_Probability__c, Account__R.AnnualRevenue, Account__R.Type, Account__R.Status__c,TokenisedStreet__c, TokenisedShippingPostalCode__c 
                                                                             FROM AccountTokenisation__c
                                                                             WHERE Account__R.ShippingCountry = :shippingAddress.ShippingCountry AND 
                                                                             TokenisedShippingPostalCode__c  =:shippingAddress.ShippingPostalCode 
                                                                             AND Account__R.Status__c in :accountStatusToCheck
                                                                             AND Account__R.ShippingStreet<>NULL
                                                                             AND Account__R.ShippingPostalCode<> NULL
                                                                             AND Account__R.WIN_Id__c<>NULL
                                                                             AND Account__R.Id =:accWrapper.parentId];
            parentId = accWrapper.parentId;
            //second search the child records
            List<AccountTokenisation__c> accountTokensationsChildAccounts = [SELECT Account__R.Id, Account__R.Name,Account__R.WIN_ID_Type__c,Account__R.Primary_Service_Provider_New__c,Account__R.Primary_Business__c, Account__R.ShippingStreet, Account__R.ShippingPostalCode, Account__R.ShippingCity, Account__R.ShippingCountry,Account__R.ShippingState,Account__R.AI_Probability__c, Account__R.AnnualRevenue, Account__R.Type, Account__R.Status__c,TokenisedStreet__c, TokenisedShippingPostalCode__c 
                                                                             FROM AccountTokenisation__c
                                                                             WHERE Account__R.ShippingCountry = :shippingAddress.ShippingCountry AND 
                                                                             TokenisedShippingPostalCode__c  =:shippingAddress.ShippingPostalCode 
                                                                             AND Account__R.Status__c in :accountStatusToCheck
                                                                             AND Account__R.ShippingStreet<>NULL
                                                                             AND Account__R.ShippingPostalCode<> NULL
                                                                             AND Account__R.WIN_Id__c<>NULL
                                                                             AND Account__R.ParentId =:accWrapper.parentId 
                                                                             Order by  Account__R.Name asc];
            if(!accountTokensationsChildAccounts.IsEmpty())
            {
                for(AccountTokenisation__c accToken : accountTokensationsChildAccounts) 
                {
                    childIds.add(accToken.Account__R.Id);
                }
            }
            //if count less than 10 then go for search logic
            if(!accountTokensationsParentAccount.IsEmpty()){
                accsTokenMatch.addAll(accountTokensationsParentAccount);
            }
            if(!accountTokensationsChildAccounts.IsEmpty())
            {
                accsTokenMatch.addAll(accountTokensationsChildAccounts);
            }
            shippingAddress.ShippingStreet=Accounts.tokeniseAccountFields(shippingAddress.ShippingStreet, abbrList);
            Integer inputStreetLength= shippingAddress.ShippingStreet.length();
            String enteredShippingStreetNumber= shippingAddress.ShippingStreet.ReplaceAll('[^0-9]', '');
            String Name10   = phonetic(accWrapper.accountName, 10);
            String Street10 = phonetic(shippingAddress.ShippingStreet, 10);
            for (AccountTokenisation__c accToken: accsTokenMatch) {
                Account acc =accToken.Account__r;
                string shippingStreet = acc.ShippingStreet;
                if(acc.AccountTokenisation__r!=null && !acc.AccountTokenisation__r.IsEmpty()){
                    shippingStreet = acc.AccountTokenisation__r[0].TokenisedStreet__c;
                }
                String shippingStreetNumber= shippingStreet.ReplaceAll('[^0-9]', '');
                Integer stringLength=shippingStreet.length()>inputStreetLength?shippingStreet.length():inputStreetLength;
                Integer mismatchCharacters= shippingStreet.getLevenshteinDistance(shippingAddress.ShippingStreet);
                acc.AnnualRevenue =0;
                Boolean SameName     = (acc.Name == accWrapper.accountName || acc.Name.replaceAll('[^a-zA-Z0-9\\s+]', '')==accWrapper.accountName.replaceAll('[^a-zA-Z0-9\\s+]', '')|| acc.Name.indexOf(accWrapper.accountName)>=0);
                Boolean SameStreet   = shippingStreet == shippingAddress.ShippingStreet && shippingStreetNumber==enteredShippingStreetNumber;
                Boolean HighLike20Street= ((((stringLength-mismatchCharacters)*100/stringLength))>=65) && shippingStreetNumber==enteredShippingStreetNumber;
                Boolean HighLike10Street= ops(shippingStreet).indexOf(shippingAddress.ShippingStreet)>=0 || shippingAddress.ShippingStreet.indexOf(shippingStreet)>=0;
                Boolean Like10Name   = (phonetic(acc.Name, 10) == Name10);
                Boolean Like10Street = (phonetic(shippingStreet, 10) == Street10);
                if (SameName && (SameStreet || HighLike10Street))
                    acc.AnnualRevenue = 105;
                else if ((SameStreet || (SameName && HighLike10Street)) ) acc.AnnualRevenue = 104;
                else if ((HighLike20Street || (SameName && HighLike10Street)) ) acc.AnnualRevenue = 103;
                else if ( (SameStreet || HighLike10Street) ) acc.AnnualRevenue = 103;
                else if (Like10Street )   acc.AnnualRevenue = 102;
                else if (Like10Name && (SameStreet || HighLike10Street) )            acc.AnnualRevenue = 101;
                if(acc.Status__c=='Active'){
                    if(acc.Type=='Customer' || acc.Type=='Broker'){
                        acc.AnnualRevenue +=2;
                    }
                    else{
                        acc.AnnualRevenue +=1;
                    }
                }
                accsMatchConsolidated.add(acc);
            }
            accsMatchConsolidated.Sort(new AccountComparator());
            if(accsMatchConsolidated.Size()>=10){
                return sortLocationAccounts(parentId,childIds,accsMatchConsolidated);
            }
            Map<Id, Account> duplicateAccountMap;
            List<Account> accountsDuplicateSearch = getDuplicateAccounts(accWrapper);
            if(!accsMatchConsolidated.IsEmpty() && !accountsDuplicateSearch.IsEmpty())
            {
                duplicateAccountMap = new Map<Id, Account>(accsMatchConsolidated);
                duplicateAccountMap.putAll(accountsDuplicateSearch);
                List<Account> duplicateAccountList = duplicateAccountMap.Values();
                duplicateAccountList.Sort(new AccountComparator());
                return sortLocationAccounts(parentId,childIds,accountsDuplicateSearch);
            }
            else if(!accsMatchConsolidated.IsEmpty() && accountsDuplicateSearch.IsEmpty())
            {
                accsMatchConsolidated.Sort(new AccountComparator());
                return sortLocationAccounts(parentId,childIds,accsMatchConsolidated);
            }
            accountsDuplicateSearch.Sort(new AccountComparator());
            return sortLocationAccounts(parentId,childIds,accountsDuplicateSearch);
        }
        else {
            return getDuplicateAccounts(accWrapper);
        }
    }
	
    public List<Account> sortLocationAccounts(Id parentId,Set<id> childIds,List<Account> duplicateAccountList)
    {
        List<Account> sortedAccountList = new List<Account>();
        Map<Id,Account> duplicateAccountMap = new Map<Id, Account>(duplicateAccountList);
        //keep parent
        if(parentId != null && duplicateAccountMap.ContainsKey(parentId))
        {
            sortedAccountList.add(duplicateAccountMap.get(parentId));
            duplicateAccountMap.remove(parentId);
        }
        //add sorted childs
        if(!childIds.IsEmpty())
        {
            for(Account acc : duplicateAccountList)
            {
                if(childIds.Contains(acc.Id) && acc.AnnualRevenue > 95)
                {
                    sortedAccountList.add(duplicateAccountMap.get(acc.Id));
                    duplicateAccountMap.remove(acc.Id);
                }
            }
        }
        if(duplicateAccountMap !=null && !duplicateAccountMap.IsEmpty())
        {
            sortedAccountList.addAll(duplicateAccountMap.Values());
        }
        return sortedAccountList;
    }
    
    
    public List<Account> getDuplicateAccounts(AccountSetupWrappers.AccountWrapper accWrapper) {
        AccountSetupWrappers.CorporateAddressWrapper shippingAddress = accWrapper.CorporateAddress;
        AccountSetupWrappers.BillingAddressWrapper billingAddress = accWrapper.BillingAddress;
        List<Account> result = new List<Account>();
        accWrapper.CorporateAddress.ShippingPostalCode = accWrapper.CorporateAddress.ShippingPostalCode.Contains('-')  ? accWrapper.CorporateAddress.ShippingPostalCode.Split('-')[0] : accWrapper.CorporateAddress.ShippingPostalCode;
        List<Account> accsMatchConsolidated = new List<Account>();
		List<AccountTokenisation__c> accountTokensations=new List<AccountTokenisation__c>();
        Set<string> accTypes;
        if(accWrapper.recordTypeId == customerLocationAccountRecordType || accWrapper.recordTypeId == customerAccountRecordType)
        {
            accTypes = new Set<String>{'ShipTo/Gen','Customer'};
        }
        else if(accWrapper.recordTypeId == brokerLocationAccountRecordType || accWrapper.recordTypeId == brokerAccountRecordType)
        {
            accTypes = new Set<String>{'Brok/Gen','Broker'};
        }
        if(shippingAddress.ShippingPostalCode != null  && shippingAddress.ShippingPostalCode.contains('-') && shippingAddress.ShippingCountry == 'US'){
            shippingAddress.ShippingPostalCode=shippingAddress.ShippingPostalCode.split('-')[0];
        }
        
        string Name4;
        Integer MAX = 600;
        if(accWrapper.accountName.length()>=4){
            Name4 = accWrapper.accountName.substring(0, 4)+'%';
        }
        else{
            Name4 = accWrapper.accountName;
        }
        if(shippingAddress.ShippingCountry == 'US'){
            accountTokensations = [SELECT Account__R.Id, Account__R.Name,Account__R.WIN_ID_Type__c,Account__R.Primary_Service_Provider_New__c,Account__R.Primary_Business__c, Account__R.ShippingStreet, Account__R.ShippingPostalCode, Account__R.ShippingCity, Account__R.ShippingCountry,Account__R.ShippingState,Account__R.AI_Probability__c, Account__R.AnnualRevenue, Account__R.Type, Account__R.Status__c,TokenisedStreet__c, TokenisedShippingPostalCode__c 
                                     FROM AccountTokenisation__c
                                     WHERE Account__R.ShippingCountry = :shippingAddress.ShippingCountry AND 
                                     TokenisedShippingPostalCode__c  =:shippingAddress.ShippingPostalCode 
                                     /*AND
                                     ( 
                                         ShippingCity = :shippingAddress.ShippingCity  OR
                                         Name LIKE :Name4
                                     )*/
                                     AND Account__R.type in :accTypes  AND Account__R.Status__c in :accountStatusToCheck
                                     AND Account__R.ShippingStreet<>NULL
									 AND Account__R.ShippingPostalCode<> NULL
									 AND Account__R.WIN_Id__c<>NULL
                                     LIMIT :MAX];
        }
        else if(shippingAddress.ShippingCountry == 'CA') {
            accountTokensations =[SELECT Account__R.Id, Account__R.Name,Account__R.WIN_ID_Type__c,Account__R.Primary_Service_Provider_New__c,Account__R.Primary_Business__c, Account__R.ShippingStreet, Account__R.ShippingPostalCode, Account__R.ShippingCity, Account__R.ShippingCountry,Account__R.ShippingState,Account__R.AI_Probability__c, Account__R.AnnualRevenue, Account__R.Type, Account__R.Status__c,TokenisedStreet__c, TokenisedShippingPostalCode__c 
                                     FROM AccountTokenisation__c
                                     WHERE Account__r.ShippingCountry = :shippingAddress.ShippingCountry 
									 /*AND
                                     ( 
                                         ShippingCity = :shippingAddress.ShippingCity  OR
                                         Name LIKE :Name4
                                     )*/
									 AND TokenisedShippingPostalCode__c  =:shippingAddress.ShippingPostalCode 
                                     AND Account__r.Type in :accTypes AND Account__r.Status__c in :accountStatusToCheck
                                     AND Account__r.ShippingStreet<>NULL
									 AND Account__r.ShippingPostalCode<> NULL
									 AND Account__r.WIN_Id__c<>NULL
                                     LIMIT :MAX];
        }
        String Name10   = phonetic(accWrapper.accountName, 10);
        String Name3 = phonetic(accWrapper.accountName,3);
        String Street10 = phonetic(shippingAddress.ShippingStreet, 10);
        String City10   = phonetic(shippingAddress.ShippingCity, 10);
        String Street4 = phonetic(shippingAddress.ShippingStreet, 4);
        String City4   = phonetic(shippingAddress.ShippingCity, 4);
        shippingAddress.ShippingStreet=Accounts.tokeniseAccountFields(shippingAddress.ShippingStreet, abbrList);
        Integer inputStreetLength= shippingAddress.ShippingStreet.length();
		String enteredShippingStreetNumber= shippingAddress.ShippingStreet.ReplaceAll('[^0-9]', '');
        for (AccountTokenisation__c accTokenisation: accountTokensations) {
		     Account acc = accTokenisation.Account__r;
            string shippingStreet = acc.ShippingStreet;
           
            if(!String.isBlank(accTokenisation.TokenisedStreet__c)){
                shippingStreet = accTokenisation.TokenisedStreet__c;
            }
			String shippingStreetNumber= shippingStreet.ReplaceAll('[^0-9]', '');
            Integer stringLength=shippingStreet.length()>inputStreetLength?shippingStreet.length():inputStreetLength;
            Integer mismatchCharacters= shippingStreet.getLevenshteinDistance(shippingAddress.ShippingStreet);
           // acc.ShippingStreet= replaceAll(acc.ShippingStreet, abbrList);
            acc.AnnualRevenue =0;
            Boolean SameName     = (acc.Name == accWrapper.accountName || acc.Name.replaceAll('[^a-zA-Z0-9\\s+]', '')==accWrapper.accountName.replaceAll('[^a-zA-Z0-9\\s+]', '')|| acc.Name.indexOf(accWrapper.accountName)>=0);
            Boolean SameStreet   = shippingStreet == shippingAddress.ShippingStreet && shippingStreetNumber==enteredShippingStreetNumber;
			Boolean HighLike20Street= ((((stringLength-mismatchCharacters)*100/stringLength))>=65) && shippingStreetNumber==enteredShippingStreetNumber;
            Boolean HighLike10Street= ops(shippingStreet).indexOf(shippingAddress.ShippingStreet)>=0 || shippingAddress.ShippingStreet.indexOf(shippingStreet)>=0;
            Boolean SameCity     = (acc.ShippingCity == shippingAddress.ShippingCity);
            Boolean Like10Name   = (phonetic(acc.Name, 10) == Name10);
            Boolean Like10Street = (phonetic(shippingStreet, 10) == Street10);
            Boolean Like10City   = (phonetic(acc.ShippingCity, 10) == City10);
            Boolean Like4Name   = (phonetic(acc.Name, 3) == Name3);
            Boolean Like4Street = (phonetic(shippingStreet, 4) == Street4);
            Boolean Like4City   = (phonetic(acc.ShippingCity, 4) == City4);
            if (SameName && (SameStreet || HighLike10Street) && SameCity)
                acc.AnnualRevenue = 103;
            else if ((SameStreet || (SameName && HighLike10Street)) && SameCity) acc.AnnualRevenue = 100;
			else if ((HighLike20Street || (SameName && HighLike10Street)) && SameCity) acc.AnnualRevenue = 96;
            else if ( (SameStreet || HighLike20Street)) acc.AnnualRevenue = 92;
            else if (Like10Street && SameCity)   acc.AnnualRevenue = 90;
            else if (Like10Name && (SameStreet || HighLike10Street) && SameCity)            acc.AnnualRevenue = 89;
            else if (HighLike10Street && SameCity )            acc.AnnualRevenue = 87;
            else if (SameName && (SameStreet || HighLike10Street) && Like10City)            acc.AnnualRevenue = 85;
            else if (SameName && Like10Street && Like10City)          acc.AnnualRevenue = 83;
            else if (Like10Name && (SameStreet || HighLike10Street) && Like10City)          acc.AnnualRevenue = 81;
            else if (Like10Name && Like10Street && SameCity)          acc.AnnualRevenue = 79;
            else if (Like10Name && Like10Street && Like10City)        acc.AnnualRevenue = 77;
            else if (SameName && Like4Street && SameCity)             acc.AnnualRevenue = 75;
            else if (Like4Name && (SameStreet || HighLike10Street) && SameCity)             acc.AnnualRevenue = 73;
            else if (SameName && (SameStreet|| HighLike10Street) && Like4City)             acc.AnnualRevenue = 71;
            else if (SameName && Like4Street && Like4City)            acc.AnnualRevenue = 69;
            else if (Like4Name && (SameStreet||HighLike10Street) && Like4City)            acc.AnnualRevenue = 67;
            else if (Like4Name && Like4Street && SameCity)            acc.AnnualRevenue = 65;
            else if (Like4Name && Like4Street && Like4City)           acc.AnnualRevenue = 63;
            else if (Like4City && Like10Name )
                acc.AnnualRevenue = 61;
            else if (SameName && SameCity)
                acc.AnnualRevenue = 59;
            else if (SameCity && SameStreet)
                acc.AnnualRevenue = 57;
            else if (SameName && SameStreet)              acc.AnnualRevenue = 55;
            else if (Like4Name && Like4Street)            acc.AnnualRevenue = 53;
            else if (Like4Street && SameCity)             acc.AnnualRevenue = 51;
            else if (Like4Name && Like4City)              acc.AnnualRevenue = 49;
            else if (Like4Name)              acc.AnnualRevenue = 47;
            if(acc.Status__c=='Active'){
                if(acc.Type=='Customer' || acc.Type=='Broker'){
                 	acc.AnnualRevenue +=2;
                }
                else{
                    acc.AnnualRevenue +=1;
                }
            }
            else {
                 if(acc.Type=='Customer' || acc.Type=='Broker'){
                 	acc.AnnualRevenue +=0.5;
                }
            }
            result.add(acc);
        }
        result.Sort(new AccountComparator());
        return result;
    }
    /**
    * Encode a word phonetically
    * 'HeLLLL00 World!'
    *  -> 'HLWRLD'
    *    -> 'H40643'
    *       Which is the same code as 'Hello World!'
    */
    private string phonetic(string ip, integer max) {
        
        if (ip == null || ip == '') return '';
        
        string op = ip.toUpperCase();
        
        // Encode phonetically similar letters as same number
        op = op.replaceAll('[^BFPVCGJKQSXZDTLMNR]', '0');
        op = op.replaceAll('[BFPV]', '1');
        op = op.replaceAll('[CGJKQSXZ]', '2');
        op = op.replaceAll('[DT]', '3');
        op = op.replaceAll('[L]', '4');
        op = op.replaceAll('[MN]', '5');
        op = op.replaceAll('[R]', '6');
        
        // Remove double-letters
        string op2 = op.substring(0,1);
        for (integer i=1; i<op.length()-1; i++) {
            string c2 = op.substring(i,i+1);
            if (!op2.endsWith(c2)) op2 += c2;
        }
        
        // Limit length of code returned
        if (max > op2.length()) max = op2.length();
        
        // Keep first letter of original word
        op2 = ip.substring(0,1) + op2.substring(1, max);
        
        return op2;
    }
    // Convert nulls to empty strings
    private static string ops(string s) {
        return s == null?'':s;
    }
    public class AccountComparator implements Comparator<Account> {
        public Integer compare(Account a1, Account a2) {
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            
            if(a1 == null && a2 == null) {
                returnValue = 0;
            } else if(a1 == null) {
                // nulls-first implementation
                returnValue = -1; 
            } else if(a2 == null) {
                // nulls-first implementation
                returnValue = 1;
            } else if ((a1.AnnualRevenue == null) && (a2.AnnualRevenue == null)) {
                // both have null Amounts
                returnValue = 0;
            } else if (a1.AnnualRevenue == null){
                // nulls-first implementation
                returnValue = 1;
            } else if (a2.AnnualRevenue == null){
                // nulls-first implementation
                returnValue = -1;
            } else if (a1.AnnualRevenue > a2.AnnualRevenue) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if (a1.AnnualRevenue < a2.AnnualRevenue) {
                // Set return value to a positive value.
                returnValue = 1;
            }
            return returnValue;
        }
    }
}