/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-20-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-01-2022   Suresh Beniwal   Initial Version
**/
import { LightningElement, track, api, wire } from "lwc";
import getMultiExcelData from "@salesforce/apex/OrganizationController.getMultiExcelImport";
import getFilterOptions from "@salesforce/apex/OrganizationController.getFilterOptions";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ORGANIZATION_STATUS_FIELD from '@salesforce/schema/Account.Organization_Status__c';
import ORGANIZATION_CATEGORY_FIELD from '@salesforce/schema/Account.Organization_Category__c';
import ACCOUNT_HR_TALENT_POOLS_RECORDTYPEID from '@salesforce/label/c.Account_HR_TalentRecordTypeId';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class MultiExcelExport extends LightningElement {
    @api recordId;
    @track showLoadingSpinner = false;

    @track xlsHeader = []; // store all the headers of the the tables
    @track workSheetNameList = []; // store all the sheets name of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "Organization_Export.xlsx"; // Name of the file
    @track multiExcelData = [];
    @track multiExcelData1 = [];
    @track multiExcelData2 = [];
    @track multiExcelData3 = [];
    @track multiExcelData4 = [];
    @track multiExcelData5 = [];
    @track multiExcelData6 = [];

    @track visibleMultiExcelData = [];
    @track visibleMultiExcelData1 = [];
    @track visibleMultiExcelData2 = [];
    @track visibleMultiExcelData3 = [];
    @track visibleMultiExcelData4 = [];
    @track visibleMultiExcelData5 = [];
    @track visibleMultiExcelData6 = [];

    @track accountColumns = [];
    @track accountColumns1 = [];
    @track accountColumns2 = [];
    @track accountColumns3 = [];
    @track accountColumns4 = [];
    @track accountColumns5 = [];
    @track accountColumns6 = [];

    @track defaultSize = 10;
    @track statusValue = '';
    @track activeInactiveValue = '';
    @track categoryValue = '';
    @track dateValue = '';
    @track ownerId = '';
    @track organizationName = '';
    @track statusOptions = [{"attributes":null,"label":"-- None --","validFor":[],"value":""}];
    @track activeInactiveOptions = [
        {"attributes":null,"label":"-- None --","validFor":[],"value":""}, 
        {"attributes":null,"label":"Active","validFor":[],"value":"Active"},
        {"attributes":null,"label":"Inactive","validFor":[],"value":"Inactive"}
    ];
    @track categoryOptions = [{"attributes":null,"label":"-- None --","validFor":[],"value":""}];
    @track managerSelectedList = [];
    @track jobcategorySelectedList = [];
    @track managerOptions = [];
    @track jobcategoryOptions = [];

    @track filterClass = '';
    @track tableClass = 'slds-size_12-of-12 slds-box';

    @track channelName = '/data/AccountChangeEvent';

    subscription = {}; //subscription information
    responseMessage; //message to be shown at UI
    isDisplayMsg; //indicator for message to be displayed

    get showFilter() {
        if (this.recordId == undefined) {
            this.filterClass = 'slds-size_3-of-12 slds-box';
            this.tableClass = 'slds-size_9-of-12 slds-box';
        } 
        return this.recordId == undefined ? true : false;
    }

    @wire(getPicklistValues, { recordTypeId: ACCOUNT_HR_TALENT_POOLS_RECORDTYPEID, fieldApiName: ORGANIZATION_STATUS_FIELD })
    statusOptions({error, data}){
        if(data){
            let dataValues = data.values;
            this.statusOptions = this.statusOptions.concat(dataValues); 
            console.log(JSON.stringify(this.statusOptions));
        }else if(error){
            console.log(error);
        }
    };

    @wire(getPicklistValues, { recordTypeId: ACCOUNT_HR_TALENT_POOLS_RECORDTYPEID, fieldApiName: ORGANIZATION_CATEGORY_FIELD })
    categoryOptions({error, data}){
        if(data){
            let dataValues = data.values;
            this.categoryOptions = this.categoryOptions.concat(dataValues); 
        }else if(error){
            console.log(error);
        }
    };

    get createdDateOptions() {
        return [
            { label: 'This Year', value: 'This_Year' },
            { label: 'Today', value: 'Today' },
            { label: 'Yesterday', value: 'Yesterday' },
            { label: 'Last Week', value: 'Last_Week' },
            { label: 'Last Month', value: 'Last_Month' },
            { label: 'Last Quarter', value: 'Last_Quarter' },
            { label: 'Last Year', value: 'Last_Year' },
        ];
    }

    connectedCallback() {
        this.handleSubscribe();
        // Register error listener       
        this.registerErrorListener();   
        this.fetchFilterOptions();
        //apex call for bringing the account data  
        if (!this.showFilter) {
            this.fetchData();
        }
    }

    // Handles subscribing
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received
            this.handleNotification(response);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
            this.handleNotification(response);
        });
    }

    // Handles unsubscribing
    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }


    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    //this method checks if current record got updated and shows message on UI
    handleNotification(response){
        if(response.hasOwnProperty('data')){
            let jsonObj = response.data;
            
            if(jsonObj.hasOwnProperty('payload')){
                let payload = response.data.payload;
                let recordIds = payload.ChangeEventHeader.recordIds;

                //find the current recordId in the array and if found then display message
                const recId = recordIds.find(element=> element == this.recordId);
                // if(recId !=undefined){
                //     this.fetchData();
                // }
                this.fetchData();
            }
        }
    }

    
    async fetchFilterOptions() {
        this.showLoadingSpinner = true;
        await getFilterOptions().then(result => {
            this.managerOptions = result.listOfManager;
            this.jobcategoryOptions = result.listOfJobCategory;
            this.showLoadingSpinner = false;
        }).catch(error => {
            console.error(error);
            this.showLoadingSpinner = false;
        });
    }

    async fetchData() {
        this.showLoadingSpinner = true;
        await getMultiExcelData({
            recordId: this.recordId,
            statusValue: this.statusValue,
            categoryValue: this.categoryValue,
            dateValue: this.dateValue,
            ownerId: this.ownerId,
            organizationName: this.organizationName,
            selectedManagerOptions: this.managerSelectedList.toString(),
            selectedJobCategorryOptions: this.jobcategorySelectedList.toString(),
            activeInactiveValue: this.activeInactiveValue
        })
            .then(result => {
                this.clearXlsData();
                this.accountColumns = result.organization.columns;
                this.accountColumns1 = result.organizationOwners.columns;
                this.accountColumns2 = result.organizationDepartment.columns;
                this.accountColumns3 = result.organizationLocation.columns;
                this.accountColumns4 = result.organizationJobCode.columns;
                this.accountColumns5 = result.organizationContact.columns;
                this.accountColumns6 = result.recentActivity.columns;

                this.multiExcelData = result.organization.listOfOrganization;
                this.multiExcelData1 = result.organizationOwners.listOfOrganizationOwners;
                this.multiExcelData2 = result.organizationDepartment.listOfOrganizationDepartments;
                this.multiExcelData3 = result.organizationLocation.listOfOrganizationLocations;
                this.multiExcelData4 = result.organizationJobCode.listOfOrganizationJobCodes;
                this.multiExcelData5 = result.organizationContact.listOfOrganizationCustomerContact;
                this.multiExcelData6 = result.recentActivity.listOfTasks;
                
                this.xlsFormatter(this.accountColumns, this.multiExcelData, "Organizations");
                this.xlsFormatter(this.accountColumns3, this.multiExcelData3, "Locations");
                this.xlsFormatter(this.accountColumns5, this.multiExcelData5, "Contacts");
                this.xlsFormatter(this.accountColumns1, this.multiExcelData1, "Owners");
                this.xlsFormatter(this.accountColumns2, this.multiExcelData2, "Departments");
                this.xlsFormatter(this.accountColumns4, this.multiExcelData4, "Job Categories");
                this.xlsFormatter(this.accountColumns6, this.multiExcelData6, "Recent Activity");

                this.showLoadingSpinner = false;
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                console.error(error);
            });

    }

    // formating the data to send as input to  xlsxMain component
    xlsFormatter(header, data, sheetName) {
        // let Header = Object.keys(data[0]);
        this.xlsHeader.push(header);
        this.workSheetNameList.push(sheetName);
        this.xlsData.push(data);
    }

    clearXlsData() {
        this.xlsHeader = [];
        this.workSheetNameList = [];
        this.xlsData = [];
    }

    // calling the download function from xlsxMain.js 
    download() {
        this.template.querySelector("c-xlsx-main").download();
    }

    updateOranizationHandler(event) {
        this.visibleMultiExcelData = [...event.detail.records];
    }

    updateOrganizationOwnersHandler(event) {
        this.visibleMultiExcelData1 = [...event.detail.records];
    }

    updateOrganizationDeparmentsHandler(event) {
        this.visibleMultiExcelData2 = [...event.detail.records];
    }

    updateOrganizationLocationsHandler(event) {
        this.visibleMultiExcelData3 = [...event.detail.records];
    }

    updateOrganizationJobCodesHandler(event) {
        this.visibleMultiExcelData4 = [...event.detail.records];
    }

    updateOrganizationContactHandler(event) {
        this.visibleMultiExcelData5 = [...event.detail.records];
    }

    updateRecentActivityHandler(event) {
        this.visibleMultiExcelData6 = [...event.detail.records];
    }

    handleChange(event) {
        if (event.target.name == 'organizationStatus') {
            this.statusValue = event.target.value;
        } else if (event.target.name == 'organizationCategory') {
            this.categoryValue = event.target.value;
        } else if (event.target.name == 'createdDate') {
            this.dateValue = event.target.value;
        } else if (event.target.name == 'ownerid') {
            this.ownerId = event.target.value;
        } else if (event.target.name == 'organizaitonName') {
            this.organizationName = event.target.value;
        } else if (event.target.name == 'organizationActiveInactive') {
            this.activeInactiveValue = event.target.value;
        }

        // this.fetchData();
    }

    handleResetFilter(event) {
        this.statusValue = '';
        this.activeInactiveValue = '';
        this.categoryValue = '';
        this.dateValue = '';
        this.ownerId = '';
        this.organizationName = '';
        this.managerSelectedList = [];
        this.jobcategorySelectedList = [];
        this.template.querySelectorAll("c-multi-select-pick-list")[0].clearPillOptions();
        this.template.querySelectorAll("c-multi-select-pick-list")[1].clearPillOptions();

        const lwcInputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (lwcInputFields) {
            lwcInputFields.forEach(field => {
                field.reset();
            });
        }

        this.fetchData();
    }

    handleSearchFilter() {
        this.fetchData();
    }

    handleMgrSelectOptionList(event){
        this.managerSelectedList = event.detail;
        console.log(JSON.stringify(this.managerSelectedList));
        // this.fetchData();
    }

    handleJobCategorySelectOptionList(event){
        this.jobcategorySelectedList = event.detail;
        console.log(JSON.stringify(this.jobcategorySelectedList));
        // this.fetchData();
    }
}