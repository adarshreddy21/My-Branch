/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-23-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-04-2022   Suresh Beniwal   Initial Version
**/
public without sharing class ProcessOrganizationDataBatch implements Database.Batchable<sObject>, Database.Stateful {
    String dataUploadRecordId;

    public ProcessOrganizationDataBatch(String recordId) {
        dataUploadRecordId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('dataUploadRecordId : '+ dataUploadRecordId);
        String completedStatus = 'Completed';
        Id recordId = [SELECT Id, Name FROM Data_Upload__c WHERE Status__c != 'Completed' AND Id =: dataUploadRecordId ORDER BY CreatedDate Desc LIMIT 1].Id;
        Update new Data_Upload__c(Id = recordId, Status__c = 'In Progress', Submission_Date__c = System.now());
        String query = 'SELECT Id, Name, Status__c, Error_Message__c, Type__c, Organization__c, Location__c, Contact_FirstName__c, Contact_LastName__c, MailAddress__Street__s, MailAddress__City__s, ' + 
        ' MailAddress__PostalCode__s, MailAddress__StateCode__s, MailAddress__CountryCode__s, MailAddress__Latitude__s, MailAddress__Longitude__s, MailAddress__c, MailAddress__GeocodeAccuracy__s, ' + 
        ' Contact_Status__c, Contact_Title__c, Contact_Type__c, Contributor__c, Diversity_Organization_Detail__c, Executive_Sponsor__c, Partnership_Owner__c, ' + 
        ' Number_of_Hires__c, Phone1__c, Phone2__c, Size_of_Candidate_Pool__c, Type1__c, Type_2__c, Organization_Status__c, Location_Description__c, Organization_Category_Detail__c, ' +
        ' Loc_Number_of_Hires__c, Loc_Size_of_Candidate_Pool__c, Salutation__c, Location_Phone__c, Contact_Email_Address__c, Parent_Account__c, Organization_Category__c, Data_Upload__c FROM Data_Upload_Line_Item__c WHERE Organization__c != null AND Type__c != null AND Status__c != : completedStatus ' + 
        ' AND Data_Upload__c =: recordId  ORDER BY Organization__c ASC, Type__c DESC';
        System.debug(Database.Query(query));
        return Database.getQueryLocator(query);
    }
      
    public void execute(Database.BatchableContext BC, List<Data_Upload_Line_Item__c> listOfLineItemRecords) {
        processRecords(listOfLineItemRecords);
    }
   
    public void finish(Database.BatchableContext BC) {
        List<Data_Upload__c> listOfDataUpload = [SELECT Id, Name, Of_Draft_Records__c, Of_Failed_Records__c, Of_Completed_Records__c, Of_Records__c FROM Data_Upload__c WHERE Id =: dataUploadRecordId ORDER BY CreatedDate Desc LIMIT 1];
        if (!listOfDataUpload.isEmpty() && listOfDataUpload.get(0).Of_Failed_Records__c == 0 
            && listOfDataUpload.get(0).Of_Completed_Records__c == listOfDataUpload.get(0).Of_Records__c) {
            
            Update new Data_Upload__c(Id = listOfDataUpload.get(0).Id, Status__c = 'Completed');
        }
    }

    /**
    * @description 
    * @author Suresh Beniwal | 07-07-2022 
    * @param List<Data_Upload_Line_Item__c> listOfLineItemRecords 
    **/
    public static void processRecords(List<Data_Upload_Line_Item__c> listOfLineItemRecords) {
		Id hrTalentPoolsAccountRecordType = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
        Id hrTalentPoolsContactRecordType = Schema.Sobjecttype.Contact.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
		Map<String, Id> mapOfKeyValue = new Map<String, Id>(); 
        Set<String> setOfUserName = new Set<String>(); 
        Set<String> setOfParentAccount = new Set<String>(); 
        Set<String> setOfLocationName = new Set<String>(); 
        Set<String> setOfOrganizationLocationName = new Set<String>(); 
		List<Data_Upload_Line_Item__c> listOfContactLineItemRecords = new List<Data_Upload_Line_Item__c>(); 
            
        for (Data_Upload_Line_Item__c dataUploadLineItem : listOfLineItemRecords) {
            
            if (String.isNotBlank(dataUploadLineItem.Contact_LastName__c) 
                && String.isNotBlank(dataUploadLineItem.Contact_FirstName__c)
                && String.isNotBlank(dataUploadLineItem.Contact_Email_Address__c)) {
                    
            	listOfContactLineItemRecords.add(dataUploadLineItem);    
            }
            
            if (String.isNotBlank(dataUploadLineItem.Parent_Account__c)) {
                setOfParentAccount.add(dataUploadLineItem.Parent_Account__c);
            }
			setOfParentAccount.add(dataUploadLineItem.Organization__c);
			
            setOfUserName.add(dataUploadLineItem.Contributor__c);
            setOfUserName.add(dataUploadLineItem.Partnership_Owner__c);
            setOfUserName.add(dataUploadLineItem.Executive_Sponsor__c);

			if (dataUploadLineItem.Type__c == 'Branch' && String.isNotBlank(dataUploadLineItem.MailAddress__StateCode__s) 
				&& String.isNotBlank(dataUploadLineItem.MailAddress__City__s)) {
					
				String key = dataUploadLineItem.MailAddress__StateCode__s + ' ' + dataUploadLineItem.MailAddress__City__s;
                setOfLocationName.add(key);
                setOfOrganizationLocationName.add(dataUploadLineItem.Organization__c);
			}
        }
		
		// Get User from system
		if (!setOfUserName.isEmpty()) {
			for (User userRecord : [SELECT Id, Name FROM User WHERE IsActive = true AND Name IN: setOfUserName]) {
				mapOfKeyValue.put(userRecord.Name, userRecord.Id);
			}
		}

		// Get existing accounts from the system
		if (!setOfParentAccount.isEmpty()) {
			for (Account accountRecord : [SELECT Id, Name FROM Account WHERE RecordTypeId =: hrTalentPoolsAccountRecordType AND Name IN: setOfParentAccount]) {
				mapOfKeyValue.put(accountRecord.Name, accountRecord.Id);
			}
		}

		// Get existing Organization Location from the system
		if (!setOfLocationName.isEmpty()) {

			for (Schema.Location organizationLocationRecord : [
                SELECT Id, Name__c, Organization__c, Organization__r.Name 
                FROM Location 
                WHERE Organization__c != null AND Organization__r.RecordTypeId =: hrTalentPoolsAccountRecordType 
                AND Name__c IN: setOfLocationName AND Organization__r.Name IN: setOfOrganizationLocationName]) {
				
                String key = organizationLocationRecord.Name__c + '_' + organizationLocationRecord.Organization__r.Name;
                mapOfKeyValue.put(key, organizationLocationRecord.Id);
                
            }
		}

		List<Data_Upload_Line_Item__c> listOfOrganizationToInsertedLines = new List<Data_Upload_Line_Item__c>();
		List<Data_Upload_Line_Item__c> listOfLocationToInsertedLines = new List<Data_Upload_Line_Item__c>();
		
		for (Data_Upload_Line_Item__c dataUploadLineItem : listOfLineItemRecords) {
			String key = dataUploadLineItem.MailAddress__StateCode__s + ' ' + dataUploadLineItem.MailAddress__City__s + '_' + dataUploadLineItem.Organization__c;
			
			if (dataUploadLineItem.Type__c == 'Corporate' && !mapOfKeyValue.containsKey(dataUploadLineItem.Organization__c)) { 
				listOfOrganizationToInsertedLines.add(dataUploadLineItem);
			}
			
			if (dataUploadLineItem.Type__c == 'Branch' && !mapOfKeyValue.containsKey(key)) {
				listOfLocationToInsertedLines.add(dataUploadLineItem);
			}
		}
		
		// Insert the Organizations
		if (!listOfOrganizationToInsertedLines.isEmpty()) {
			Map<String, Account> mapOfAccountInstance = createOrganizations(listOfOrganizationToInsertedLines, hrTalentPoolsAccountRecordType, mapOfKeyValue);
			Database.SaveResult[] listOfOrganization = Database.insert(mapOfAccountInstance.values(), false);
			updateProcessedLogs(listOfOrganization, listOfOrganizationToInsertedLines, 'Account'); 
			
			for (Account accountRecord : mapOfAccountInstance.Values()) {
                if (accountRecord.Id != null) {
				    mapOfKeyValue.put(accountRecord.Name, accountRecord.Id);
                }
			}
		}
		
		// Insert the Locations
		if (!listOfLocationToInsertedLines.isEmpty()) {
			List<Schema.Location> listOfLocationInstance = createOrganizationLocations(listOfLocationToInsertedLines, mapOfKeyValue);
			Database.SaveResult[] listOfInsertedLocation = Database.insert(listOfLocationInstance, false);
            updateProcessedLogs(listOfInsertedLocation, listOfLocationToInsertedLines, 'Location');
			
			for (Schema.Location locationRecord : [SELECT Id, Name__c, Organization__r.Name FROM Location WHERE Id IN: listOfLocationInstance]) {
                String key = locationRecord.Name__c + '_' + locationRecord.Organization__r.Name;
                if (locationRecord.Id != null) {
				    mapOfKeyValue.put(key, locationRecord.Id);
                }
			}
		}
		
		// Insert the Contacts
		if (!listOfContactLineItemRecords.isEmpty()) {
			List<Data_Upload_Line_Item__c> listOfToProcessedLineItemRecords = new List<Data_Upload_Line_Item__c>();
			List<Contact> listOfContactInstance = createContacts(listOfContactLineItemRecords, hrTalentPoolsContactRecordType, mapOfKeyValue, listOfToProcessedLineItemRecords);
			Database.SaveResult[] listOfInsertedContact = Database.insert(listOfContactInstance, false);
            updateProcessedLogs(listOfInsertedContact, listOfToProcessedLineItemRecords, 'Contact');
		}
    }

    
    /**
    * @description 
    * @author Suresh Beniwal | 07-08-2022 
    * @param List<Data_Upload_Line_Item__c> listOfdataUploadLineItems 
    * @param String hrTalentPoolsAccountRecordType 
    * @param  Map<String, Id> mapOfKeyValue
    * @return Map<String, Account> 
    **/
    public static Map<String, Account> createOrganizations(List<Data_Upload_Line_Item__c> listOfdataUploadLineItems, Id hrTalentPoolsAccountRecordType, Map<String, Id> mapOfKeyValue) {
        Map<String, Account> mapOfAccount = new Map<String, Account>();

        for (Data_Upload_Line_Item__c dataUploadLineItem : listOfDataUploadLineItems) {
            
			Account accountRecord = new Account();
			accountRecord.Name = dataUploadLineItem.Organization__c;
			accountRecord.RecordTypeId = hrTalentPoolsAccountRecordType;
			accountRecord.Organization_Category__c = dataUploadLineItem.Organization_Category__c; 
			accountRecord.ParentId = mapOfKeyValue.containsKey(dataUploadLineItem.Parent_Account__c) ?  mapOfKeyValue.get(dataUploadLineItem.Parent_Account__c) : null; // dataUploadLineItem.Parent_Account__c
			accountRecord.Organization_Status__c = 'Draft'; //dataUploadLineItem.Organization_Status__c;
			accountRecord.Organization_Category_Detail__c = dataUploadLineItem.Organization_Category_Detail__c;
			accountRecord.Diversity_Organization_Detail__c = dataUploadLineItem.Diversity_Organization_Detail__c;
			accountRecord.Number_of_Hires__c = dataUploadLineItem.Number_of_Hires__c;
			accountRecord.Size_of_Candidate_Pool__c = dataUploadLineItem.Size_of_Candidate_Pool__c;
			accountRecord.ShippingStreet = dataUploadLineItem.MailAddress__Street__s;
			accountRecord.ShippingCity = dataUploadLineItem.MailAddress__City__s;
			accountRecord.ShippingState = dataUploadLineItem.MailAddress__StateCode__s;
			accountRecord.ShippingCountry = dataUploadLineItem.MailAddress__CountryCode__s; // Needs from Excel sheet
			accountRecord.ShippingPostalCode = dataUploadLineItem.MailAddress__PostalCode__s;

			mapOfAccount.put(accountRecord.Name, accountRecord);
        }
        return mapOfAccount;
    }

    
    /**
    * @description 
    * @author Suresh Beniwal | 07-08-2022 
    * @param List<Data_Upload_Line_Item__c> listOfdataUploadLineItems 
    * @param Map<String String> mapOfKeyValue 
    * @return List<Schema.Location> 
    **/
    public static List<Schema.Location> createOrganizationLocations(List<Data_Upload_Line_Item__c> listOfdataUploadLineItems, Map<String, String> mapOfKeyValue) {
        List<Schema.Location> listOfLocation = new List<Schema.Location>();

        for (Data_Upload_Line_Item__c dataUploadLineItem : listOfDataUploadLineItems) {

            String key = dataUploadLineItem.Organization__c; 
            if (!mapOfKeyValue.isEmpty() && mapOfKeyValue.containsKey(key)) {
                Schema.Location locationRecord = new Schema.Location();
                locationRecord.Name = dataUploadLineItem.MailAddress__StateCode__s + ' ' + dataUploadLineItem.MailAddress__City__s; //dataUploadLineItem.Location__c;
                locationRecord.Organization__c = mapOfKeyValue?.get(key);
                locationRecord.Description = dataUploadLineItem.Location_Description__c;
                locationRecord.Number_of_Hires__c = dataUploadLineItem.Loc_Number_of_Hires__c;
                locationRecord.Size_of_Candidate_Pool__c = dataUploadLineItem.Loc_Size_of_Candidate_Pool__c;
                locationRecord.Address__Street__s = dataUploadLineItem.MailAddress__Street__s;
                locationRecord.Address__City__s = dataUploadLineItem.MailAddress__City__s;
                locationRecord.Address__StateCode__s = dataUploadLineItem.MailAddress__StateCode__s;
                locationRecord.Address__CountryCode__s = dataUploadLineItem.MailAddress__CountryCode__s; // Needs from Excel sheet
                locationRecord.Address__PostalCode__s = dataUploadLineItem.MailAddress__PostalCode__s;
                locationRecord.Location_Phone_Number__c = dataUploadLineItem.Location_Phone__c?.replaceAll('\\D', ''); // Location_Phone_Number__c should have 10 digit validation error

                listOfLocation.add(locationRecord);
            }
        }
        return listOfLocation;
    }

   
    /**
    * @description 
    * @author Suresh Beniwal | 07-08-2022 
    * @param List<Data_Upload_Line_Item__c> listOfDataUploadLineItems 
    * @param String hrTalentPoolsContactRecordType 
    * @param Map<String, Id> mapOfKeyValue
	* @param List<Data_Upload_Line_Item__c> listOfToProcessedLineItemRecords
    * @return List<Contact> 
    **/
    public static List<Contact> createContacts(List<Data_Upload_Line_Item__c> listOfDataUploadLineItems, Id hrTalentPoolsContactRecordType, Map<String, Id> mapOfKeyValue, List<Data_Upload_Line_Item__c> listOfToProcessedLineItemRecords) {
        
        List<Contact> listOfContact = new List<Contact>();

        for (Data_Upload_Line_Item__c dataUploadLineItemRecord : listOfDataUploadLineItems) {
            String key = dataUploadLineItemRecord.MailAddress__StateCode__s + ' ' + dataUploadLineItemRecord.MailAddress__City__s + '_' + dataUploadLineItemRecord.Organization__c;
            String key1 = dataUploadLineItemRecord.Organization__c;

            System.debug('mapOfKeyValue  :: ' + mapOfKeyValue);
            if (!mapOfKeyValue.isEmpty() && mapOfKeyValue.containsKey(key1)) {
                Contact contactRecord = new Contact();
                contactRecord.Salutation = 'Mr'; //dataUploadLineItemRecord.Salutation__c; // Needs from Excel sheet
                contactRecord.FirstName = dataUploadLineItemRecord.Contact_FirstName__c;
                contactRecord.LastName = dataUploadLineItemRecord.Contact_LastName__c;
                contactRecord.Email = dataUploadLineItemRecord.Contact_Email_Address__c;
                contactRecord.AccountId = mapOfKeyValue.containsKey(key1) ? mapOfKeyValue?.get(key1) : null;
                contactRecord.Locations__c = dataUploadLineItemRecord.Type__c == 'Branch' ? (mapOfKeyValue.containsKey(key) ? mapOfKeyValue?.get(key) : null) : null;
                contactRecord.Phone1__c = dataUploadLineItemRecord.Phone1__c?.replaceAll('\\D', '');
                contactRecord.Phone2__c = dataUploadLineItemRecord.Phone2__c?.replaceAll('\\D', '');
                contactRecord.Type1__c = dataUploadLineItemRecord.Type1__c;
                contactRecord.Type2__c = dataUploadLineItemRecord.Type_2__c;
                contactRecord.RecordTypeId = hrTalentPoolsContactRecordType;
                contactRecord.Org_Contact_Type__c = dataUploadLineItemRecord.Contact_Type__c;
                contactRecord.Contact_Title__c = dataUploadLineItemRecord.Contact_Title__c;
                contactRecord.Contact_Status__c = dataUploadLineItemRecord.Contact_Status__c;
                contactRecord.Contributor__c = mapOfKeyValue.containsKey(dataUploadLineItemRecord.Contributor__c) ? mapOfKeyValue.get(dataUploadLineItemRecord.Contributor__c) : null; // Needs to get from the excel file
                contactRecord.Partnership_Owner__c = mapOfKeyValue.containsKey(dataUploadLineItemRecord.Partnership_Owner__c) ? mapOfKeyValue.get(dataUploadLineItemRecord.Partnership_Owner__c) :  null; // Needs to get from the excel file
                contactRecord.Executive_Sponsor__c = mapOfKeyValue.containsKey(dataUploadLineItemRecord.Executive_Sponsor__c) ? mapOfKeyValue.get(dataUploadLineItemRecord.Executive_Sponsor__c) : null;

                listOfContact.add(contactRecord);
                listOfToProcessedLineItemRecords.add(dataUploadLineItemRecord);
            }
        }

        return listOfContact;
    }

    /**
    * @description 
    * @author Suresh Beniwal | 07-08-2022 
    * @param Database.SaveResult[] insertResults 
    * @param List<Data_Upload_Line_Item__c> listOfDataUploadLineItems 
    * @param String objectName
    **/
    public static void updateProcessedLogs(Database.SaveResult[] insertResults, List<Data_Upload_Line_Item__c> listOfDataUploadLineItems, String objectName) {

        for (Integer i = 0; i < insertResults.size(); i++) {
            if (insertResults.get(i).isSuccess()) { 
                listOfDataUploadLineItems.get(i).Status__c = 'Completed';
                listOfDataUploadLineItems.get(i).Error_Message__c = listOfDataUploadLineItems.get(i).Error_Message__c + ' | '  + objectName + ' => ' + ' ' + insertResults.get(i).getId();
            } else if (!insertResults.get(i).isSuccess()) {
                // there is no contact as its not created
                //    Error_Message__c=insertResults.get(i).getErrors().get(0).getMessage()
                listOfDataUploadLineItems.get(i).Status__c = 'Failed';
                if (String.isNotBlank(listOfDataUploadLineItems.get(i).Error_Message__c) && !listOfDataUploadLineItems.get(i).Error_Message__c.contains(insertResults.get(i).getErrors().get(0).getMessage())) {
                    // ' Field = ' +  insertResults.get(i).getErrors()?.get(0)?.getFields()?.get(0) + ' , '  +
                    listOfDataUploadLineItems.get(i).Error_Message__c = listOfDataUploadLineItems.get(i).Error_Message__c + ' | '  + objectName + ' => ' + insertResults.get(i).getErrors().get(0).getMessage();
                } else {
                    // + ' Field = ' +  insertResults.get(i).getErrors()?.get(0)?.getFields()?.get(0) + ' , '
                    listOfDataUploadLineItems.get(i).Error_Message__c = objectName + ' => ' + insertResults.get(i).getErrors()?.get(0).getMessage();
                }
                
            }                
        }

        if (!listOfDataUploadLineItems.isEmpty()) {
            Database.update(listOfDataUploadLineItems, false);
        }
    }

    @AuraEnabled
    public static void invokeBatch(String recordId){
        try {
            System.debug('recordId :: ' + recordId);
            Database.executeBatch(new ProcessOrganizationDataBatch(recordId));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}