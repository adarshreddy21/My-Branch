public class CorpAccountRevenueCtrl {

    private final Account acct;
    public String corpCode{get;set;}
    
    public CorpAccountRevenueCtrl(ApexPages.StandardController stdController) {
        System.debug('CorpAccountRevenueCtrl');
         if (!Test.isRunningTest()) stdController.addFields(new List<String>{'Name', 'RecordTypeId'});
        this.acct = (Account)stdController.getRecord();        
        corpCode = '';
        Id corpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        System.debug('acct.Name:'+acct.Name);
        System.debug('acct.RecordTypeId:'+acct.RecordTypeId);
        System.debug('corpRecTypeId:'+corpRecTypeId);
        
        if(acct.RecordTypeId != corpRecTypeId){return;}
        
        try{
            System.debug('acct.Name:'+acct.Name);
            String[] accNameArr = acct.Name.split('-');
            Integer accArrLen = accNameArr.size();
            if(accArrLen > 1){
                String code = accNameArr[accArrLen-1].trim();
                corpCode = code.isNumeric() ? code : null;
                System.debug('corpCode:'+corpCode+':');
            }
        }catch(Exception ex){}
    }
    }