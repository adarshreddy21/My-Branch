public without sharing class ZipMasterDAO {
    public static List<ZIP_Master__c> getZipMastersByPostalCodeCountryState(Set<String> postalCode, String country, String state) {
        return [
            SELECT Zip__c,Country__c,State__c FROM ZIP_Master__c WHERE 
            Zip__c IN :postalCode AND Country__c = :country AND State__c = :state];
    }
}