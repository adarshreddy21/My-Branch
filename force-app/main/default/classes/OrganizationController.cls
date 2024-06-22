/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-21-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-01-2022   Suresh Beniwal   Initial Version
**/
public with sharing class OrganizationController {

    static Id hrTalentPoolsAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();

    /**
    * @description 
    * @author Suresh Beniwal | 06-06-2022 
    * @param String recordId 
    * @return MultiExcelWrapper 
    **/
    @AuraEnabled 
    public static MultiExcelWrapper getMultiExcelImport(String recordId, String statusValue, String categoryValue, String dateValue, String ownerId, String organizationName, 
        String selectedManagerOptions, String selectedJobCategorryOptions, String activeInactiveValue) {
        try {
            MultiExcelWrapper multiExcelWrapperRecord = new MultiExcelWrapper();
            OrganizationWrapper organizationData = new OrganizationWrapper();
            OrganizationOwnersWrapper organizationOwnersData = new OrganizationOwnersWrapper();
            OrganizationDepartmentWrapper organizationDepartmentData = new OrganizationDepartmentWrapper();
            OrganizationLocationWrapper organizationLocationData = new OrganizationLocationWrapper();
            OrganizationJobCodeWrapper organizationJobCodeData = new OrganizationJobCodeWrapper();
            OrganizationCustomerContactWrapper organizationContactData = new OrganizationCustomerContactWrapper();
            RecentContactActivityWrapper recentActivityData = new RecentContactActivityWrapper();

            Map<Id, Account> mapOfOrganization = new Map<Id, Account>();

            //Actual Code
            Criteria c1 = new Criteria('Id', '=', recordId, new List<String>());
            Criteria c2 = new Criteria('Organization_Status__c', '=', statusValue, new List<String>());
            Criteria c3 = new Criteria('Organization_Category__c', '=', categoryValue, new List<String>());
            Criteria c4 = new Criteria('CreatedDate', '=', dateValue, new List<String>());
            Criteria c5 = new Criteria('OwnerId', '=', ownerId, new List<String>());
            Criteria c6 = new Criteria('Name', 'LIKE', organizationName, new List<String>());
            Criteria c8 = new Criteria('RecordTypeId', '=', hrTalentPoolsAccountRecordType, new List<String>());
            Criteria c9 = new Criteria('Status__c', '=', activeInactiveValue, new List<String>());

            String organizationId = ' ';
            Set<Id> s1 = new Set<Id>();
            Set<Id> s2 = new Set<Id>();
            List<String> selectedManagerOptionValue = new List<String>();
            List<String> selectedJobCategoryOptionValue = new List<String>();

            if (String.isNotBlank(selectedManagerOptions)) {
                selectedManagerOptionValue = convertDynamicInSupportedQueryString(selectedManagerOptions);
               
                for (Organization_Department__c department: DepartmentsDAO.dynamicQueryGetListOfDepartmentByOrganizationIds(selectedManagerOptionValue)) {
                    
                    organizationId += department.Organization__c + ',';
                    s1.add(department.Organization__c);
                }
            }

            if (String.isNotBlank(selectedJobCategorryOptions)) {
                selectedJobCategoryOptionValue = convertDynamicInSupportedQueryString(selectedJobCategorryOptions);

                for (Organization_Job_Code__c jobCode: JobCodeDAO.dynamicQueryGetListOfJobCodeByOrganizationIds(selectedJobCategoryOptionValue)) {
                    
                    organizationId += jobCode.Organization__c + ',';
                    s2.add(jobCode.Organization__c);
                }
            }

            if (String.isNotBlank(selectedJobCategorryOptions) && String.isNotBlank(selectedManagerOptions)) {
                organizationId = '';
                System.debug('s1 ' + s1);
                System.debug('s2 ' + s2);
                List<Account> listOfAccount = AccountDAO.getListOfAccountByIdSets(s1, s2);
                for (Account accountRecord : listOfAccount) {
                    organizationId += accountRecord.Id + ',';
                }

                if (listOfAccount.isEmpty()) {
                    organizationId = '0018L0000071SYiQAL';
                }
            }

            List<String> listOfOption = new List<String>();
            organizationId = organizationId.removeEnd(',');
            organizationId = organizationId.replaceAll( '\\s+', '');
            listOfOption = organizationId.split(',');
            
            String where_cond = generateWhereQuery(new List<Criteria>{c1, c2, c3, c4, c5, c6, c8, c9});
            
            if (String.isNotBlank(selectedManagerOptions) || String.isNotBlank(selectedJobCategorryOptions)) {
                Criteria c7 = new Criteria('Id', 'IN', organizationId, listOfOption);
                where_cond = generateWhereQuery(new List<Criteria>{c1, c2, c3, c4, c5, c6, c7, c8, c9});
            } 

            List<Account> listOfOrganization = AccountDAO.dynamicQueryGetListOfAccounts(where_cond, listOfOption);
            mapOfOrganization = new Map<Id, Account>(listOfOrganization);

            if (!mapOfOrganization.isEmpty()) {
                organizationData.listOfOrganization = AccountService.getListOfAccounts(mapOfOrganization.values());
                organizationOwnersData.listOfOrganizationOwners = OwnershipService.getListOfOwnerships(OwnershipDAO.getListOfOwnershipByOrganizationIds(mapOfOrganization.keySet()));
                organizationDepartmentData.listOfOrganizationDepartments = DepartmentsService.getListOfDepartments(DepartmentsDAO.getDynamicListOfDepartmentByOrganizationIds(mapOfOrganization.keySet(), selectedManagerOptionValue));
                organizationLocationData.listOfOrganizationLocations = LocationService.getListOfLocations(LocationDAO.getLocationsByOrganizationIds(mapOfOrganization.keySet()));
                organizationJobCodeData.listOfOrganizationJobCodes = JobCodeService.getListOfJobCodes(JobCodeDAO.getDynamicListOfJobCodeByOrganizationIds(mapOfOrganization.keySet(), selectedJobCategoryOptionValue));
                organizationContactData.listOfOrganizationCustomerContact = ContactService.getListOfContacts(ContactDAO.getListOfContactByOrganizationIds(mapOfOrganization.keySet()));
                recentActivityData.listOfTasks = TaskService.getTaskDetails(mapOfOrganization.keySet()); 
            }

            multiExcelWrapperRecord.organization = organizationData;
            multiExcelWrapperRecord.organizationDepartment = organizationDepartmentData;
            multiExcelWrapperRecord.organizationJobCode = organizationJobCodeData;
            multiExcelWrapperRecord.organizationLocation = organizationLocationData;
            multiExcelWrapperRecord.organizationOwners = organizationOwnersData;
            multiExcelWrapperRecord.organizationContact = organizationContactData;
            multiExcelWrapperRecord.recentActivity = recentActivityData;
            return multiExcelWrapperRecord;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            return null;
            // throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Suresh Beniwal | 06-08-2022 
    * @return OptionsWrapper 
    **/
    @AuraEnabled
    public static OptionsWrapper getFilterOptions() {
        try {
            OptionsWrapper optionsWrapperRecord = new OptionsWrapper();
            List<Options> listOfManager = new List<Options>();
            List<Options> listOfJobCategory = new List<Options>();
            Map<String, String> mapOfUniqueValues = new Map<String, String>();

            for (Organization_Department_Mgr__c departmentMgr: DeparmentManagerDAO.getListOfDepartmentManagers()) {
                
                if (departmentMgr.MGR_LVL_3_DESCR__c != null && !mapOfUniqueValues.containsKey(departmentMgr.MGR_LVL_3_DESCR__c)) {
                    mapOfUniqueValues.put(departmentMgr.MGR_LVL_3_DESCR__c, '');
                    listOfManager.add(new Options(departmentMgr.MGR_LVL_3_DESCR__c, departmentMgr.MGR_LVL_3_DESCR__c));
                }
            }

            mapOfUniqueValues = new Map<String, String>();
            for (Organization_Job_Code_Mapping__c jobCodeMapping: JobCodeMappingDAO.getListOfJobCodeMappings()) {
                
                if (jobCodeMapping.Job_Category_Group__c != null && !mapOfUniqueValues.containsKey(jobCodeMapping.Job_Category_Group__c)) {
                    mapOfUniqueValues.put(jobCodeMapping.Job_Category_Group__c, '');
                    listOfJobCategory.add(new Options(jobCodeMapping.Job_Category_Group__c, jobCodeMapping.Job_Category_Group__c));
                }
            }


            optionsWrapperRecord.listOfManager = listOfManager;
            optionsWrapperRecord.listOfJobCategory = listOfJobCategory;
            return optionsWrapperRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class OptionsWrapper {
        @AuraEnabled public List<Options> listOfManager = new List<Options>();
        @AuraEnabled public List<Options> listOfJobCategory = new List<Options>();
    }

    public class Options {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        /**
        * @description 
        * @author Suresh Beniwal | 06-09-2022 
        * @param String f_label 
        * @param String f_value 
        **/
        public Options(String f_label, String f_value) {
            this.label = f_label;
            this.value = f_value;
        }
    }

    public static List<String> convertDynamicInSupportedQueryString(String options) {

        //options = options.replaceAll( '\\s+', '');
        System.debug(options.split(','));
        return options.split(',');
    }

    //Helper Class
    public class Criteria {
        public String FieldName;
        public String Operator;
        public String FieldValue;
        public List<String> listOfOption;


        /**
        * @description 
        * @author Suresh Beniwal | 06-09-2022 
        * @param String f_name 
        * @param String f_operator 
        * @param String f_value 
        * @param List<String> f_lvalue 
        **/
        public Criteria(String f_name, String f_operator, String f_value, List<String> f_lvalue) {
            FieldName = f_name;
            FieldValue = f_value;
            Operator = f_operator;
            listOfOption = f_lvalue;
        }


        /**
        * @description 
        * @author Suresh Beniwal | 06-09-2022 
        * @return String 
        **/
        public String getSOQLCriteria() {
            if (fieldName == 'CreatedDate') {
                return fieldName + ' '  + Operator + ' ' + FieldValue ;
            } else {
                if (Operator == 'LIKE') {
                    return fieldName + ' '  + Operator + ' \'' + FieldValue + '%\'';
                } else if ((Operator == 'IN' && fieldName == 'Id')) {
                    return fieldName + ' '  + Operator + ': listOfOption';
                } else {
                    return fieldName + ' '  + Operator + ' \'' + FieldValue + '\'';
                }
            }
        }
    
        /**
        * @description 
        * @author Suresh Beniwal | 06-09-2022 
        * @return Boolean 
        **/
        public Boolean IsFieldValueGiven() {
            return FieldValue != null && FieldValue != '';
        }
    }
 
    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @param List<Criteria> criterias 
    * @return String 
    **/
    public static String generateWhereQuery(List<Criteria> criterias) {
        List<String> and_conditions = new List<String>();
        for(Criteria single_criteria : criterias) {
            if (single_criteria.IsFieldValueGiven()) {
                and_conditions.add(single_criteria.getSOQLCriteria());
            }
        }
        return String.join(and_conditions, ' AND ');
    }
   
    public class MultiExcelWrapper {
        @AuraEnabled public OrganizationWrapper organization;
        @AuraEnabled public OrganizationOwnersWrapper organizationOwners;
        @AuraEnabled public OrganizationDepartmentWrapper organizationDepartment;
        @AuraEnabled public OrganizationLocationWrapper organizationLocation;
        @AuraEnabled public OrganizationJobCodeWrapper organizationJobCode;
        @AuraEnabled public OrganizationCustomerContactWrapper organizationContact;
        @AuraEnabled public RecentContactActivityWrapper recentActivity;
    }

    public class OrganizationWrapper {
        @AuraEnabled public List<Options> columns = new List<Options>{
            new Options('Organization Id', 'organizationCode'), 
            new Options('Organization Name', 'organizationName'), 
            new Options('Parent Account', 'parentAccount'),
            new Options('Organization Status', 'organizationStatus'), 
            new Options('Organization Category', 'organizationCategory'),
            new Options('Organization Category Detail', 'organizationCategoryDetail'), 
            new Options('Diversity Organization Detail', 'diversityOrganizationDetail'), 
            new Options('Size of Candidate Pool', 'sizeofCandidatePool'), 
            new Options('Number of Hires', 'numberofHires'),
            new Options('Status', 'status'), 
            new Options('Street', 'street'),
            new Options('City', 'city'),
            new Options('State', 'state'),
            new Options('Country', 'country'),
            new Options('Zip Code', 'zipcode')
        };
        @AuraEnabled public List<AccountService.AccountWrapper> listOfOrganization = new List<AccountService.AccountWrapper>();
    }

    public class OrganizationOwnersWrapper {
        @AuraEnabled public List<Options> columns = new List<Options> {
            new Options('Organization Id', 'organizationId'),
            new Options('Organization Name', 'organizationName'),
            new Options('Executive Id', 'executiveId'), 
            new Options('Executive Sponsor', 'executive'), 
            new Options('Partnership Id', 'partnershipId'), 
            new Options('Partnership Owner', 'partnership'), 
            new Options('Contributor Id', 'contributerId'), 
            new Options('Contributor', 'contributer')
        };
        @AuraEnabled public List<OwnershipService.OwnershipWrapper> listOfOrganizationOwners = new List<OwnershipService.OwnershipWrapper>();
    }

    public class OrganizationDepartmentWrapper {
        @AuraEnabled public List<Options> columns = new List<Options> {
            new Options('Department Id', 'departmentCode'),
            new Options('Location Id', 'locationCode'),
            new Options('Organization Id', 'organizationCode'),
            new Options('Dept Id', 'deptId'),
            new Options('MGR LVL 1 DESCR', 'mgr_level_1'),
            new Options('MGR LVL 2 DESCR', 'mgr_level_2'),
            new Options('MGR LVL 3 DESCR', 'mgr_level_3'),
            new Options('MGR LVL 4 DESCR', 'mgr_level_4'),
            new Options('MGR LVL 5 DESCR', 'mgr_level_5'),
            new Options('MGR LVL 6 DESCR', 'mgr_level_6'),
            new Options('MGR LVL 7 DESCR', 'mgr_level_7'),
            new Options('Location', 'location'),
            new Options('Organization Name', 'organizationName') 
        };
        @AuraEnabled public List<DepartmentsService.DepartmentsWrapper> listOfOrganizationDepartments = new List<DepartmentsService.DepartmentsWrapper>();
    }

    public class OrganizationLocationWrapper {
        @AuraEnabled public List<Options> columns = new List<Options> {
            new Options('Location Id', 'locationCode'), 
            new Options('Organization Id', 'organizationCode'),
            new Options('Name', 'locationName'), 
            new Options('Location Phone Number', 'locationPhoneNumber'), 
            new Options('Status', 'status'), 
            new Options('Size Of Candidate Pool', 'sizeOfCandidatePool'), 
            new Options('Number Of Hires', 'numberOfHires'), 
            new Options('Organization Name', 'organizationName'),
            new Options('Street', 'street'),
            new Options('City', 'city'),
            new Options('State', 'state'),
            new Options('Country', 'country'),
            new Options('Zip Code', 'zipcode')
        };
        @AuraEnabled public List<LocationService.LocationWrapper> listOfOrganizationLocations = new List<LocationService.LocationWrapper>();
    }

    public class OrganizationJobCodeWrapper {
        @AuraEnabled public List<Options> columns = new List<Options> {
            new Options('Job Category Id', 'jobCategoryCode'), 
            new Options('Location Id', 'locationCode'),
            new Options('Organization Id', 'organizationCode'),
            new Options('Job Category', 'jobCategories'), 
            new Options('Job Sub Category', 'jobCodeTitles'), 
            new Options('Location', 'location'),
            new Options('Organization Name', 'organizationName')
        };
        @AuraEnabled public List<JobCodeService.JobCodeWrapper> listOfOrganizationJobCodes = new List<JobCodeService.JobCodeWrapper>();
    }

    public class OrganizationCustomerContactWrapper {
        @AuraEnabled public List<Options> columns = new List<Options> {
            new Options('Contact Id', 'contactId'),
            new Options('Location Id', 'locationCode'),
            new Options('Organization Id', 'organizationCode'),
            new Options('Name', 'name'), 
            new Options('First Name', 'firstName'), 
            new Options('Last Name', 'lastName'), 
            new Options('Email', 'email'), 
            new Options('Phone1', 'phone1'), 
            new Options('Phone2', 'phone2'), 
            new Options('Type1', 'type1'), 
            new Options('Type2', 'type2'),
            new Options('Contact Type', 'contactType'),
            new Options('Contact Status', 'contactStatus'), 
            new Options('Executive Sponsor', 'executiveSponsor'), 
            new Options('Contributor', 'contributor'), 
            new Options('Partnership Owner', 'partnershipOwner'),
            new Options('Status', 'status'),
            new Options('Location', 'location'),
            new Options('Organization Name', 'organizationName')
        };
        @AuraEnabled public List<ContactService.ContactWrapper> listOfOrganizationCustomerContact = new List<ContactService.ContactWrapper>();
    }

    public class RecentContactActivityWrapper {
        @AuraEnabled public List<Options> columns = new List<Options> {
            new Options('Location Id', 'locationCode'),
            new Options('Location Name', 'locationName'),
            new Options('Organization Id', 'organizationId'),
            new Options('Organization Name', 'relatedName'), 
            new Options('Contact Id', 'contactId'),
            new Options('Contact Name', 'relatedContactName'),
            new Options('Subject', 'subject'), 
            new Options('Type', 'type'), 
            new Options('Sub Type', 'subtype'), 
            new Options('Status', 'status'),
            new Options('Created Date', 'createdDate'),
            new Options('Description', 'description'),
			new Options('DepartmentId', 'Department__r.Name'),
            new options('Job Category ','Job_Categories__r.Job_Category_Group__c')
        };
        @AuraEnabled public List<TaskService.TaskWrapper> listOfTasks = new List<TaskService.TaskWrapper>();
    }

}