import { LightningElement, wire } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import HideLightningHeader from '@salesforce/resourceUrl/HideLightningHeader';
import { loadStyle } from 'lightning/platformResourceLoader';
import createAccountAndRelatedInfoRecords from '@salesforce/apex/GuidedAccountCreateSetup.createAccountAndRelatedInfoRecords';
import deleteCustomDocument from '@salesforce/apex/GuidedAccountCreateSetup.deleteCustomDocument';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import validateAccountAndCreateWinId from '@salesforce/apex/AccountValidatorController.validateAccount';
import getAccounts from '@salesforce/apex/GuidedAccountCreateSetup.getAccounts';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import INDUSTRY_SEGMENT_FIELD from "@salesforce/schema/Account.Industry_Segment__c";
import RECORDTYPE_NAME_FIELD from "@salesforce/schema/Account.RecordType.Name";
import CLASS_FIELD from "@salesforce/schema/Account.Class__c";
import RANK_FIELD from "@salesforce/schema/Account.Rank__c";
import ACCOUNT_SOURCE_FIELD from "@salesforce/schema/Account.AccountSource";
import PARENT_WINID_FIELD from "@salesforce/schema/Account.WIN_ID__c";
import ACCOUNT_NAME from "@salesforce/schema/Account.Name";
import ACCOUNT_CURRENCY from "@salesforce/schema/Account.CurrencyIsoCode";

const CUSTOMER_LOCATION_RECORD_TYPE_ID = '012j0000001DaVUAA0';
const BROKER_LOCATION_RECORD_TYPE_ID = '012j0000001DaVPAA0';

const FIELDS = [
    INDUSTRY_SEGMENT_FIELD,
    RECORDTYPE_NAME_FIELD,
    CLASS_FIELD,
    RANK_FIELD,
    ACCOUNT_SOURCE_FIELD,
    PARENT_WINID_FIELD,
    ACCOUNT_NAME,
	ACCOUNT_CURRENCY
];

const ChildComponentVisibility = Object.freeze({
    AccountRecordTypeScreenVisible: 0,
    CustomerScreen: 1,
    SearchScreen: 2,
    WasteInfoQueriesScreen: 3,
    WasteInformationScreen: 4,
    CustClassificationScreen: 5,
    CustContactScreen: 6
})

const CREATE_ACCOUNT_ERROR_MESSAGE = 'Below error received while Creating Account/Contact';
const EXIT_CONFIRM_MESSAGE = 'Are you sure you want to exit before creating an account?';

export default class ParentAccountSetup extends NavigationMixin(LightningElement) {
    currentVisibleComponent;
    accountData;
    recordId;
    recordTypeId;
    winIdCreation = false;
    showSpinner = false;
    skipSearchScreen = false;
    isCreateWINIDBtnDisabled = true;
    duplicateAccountData = {};
    corporateAddressChanged = false;
    duplicateAccountRecordsVisible = false;
    showSelectAccountRecordTypes = false;
    parentAccountId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state && currentPageReference.state.c__parentid) {
            this.parentAccountId = currentPageReference.state.c__parentid;
        }
        else {
            this.resetValues();
        }
    }

    resetValues() {
        this.currentVisibleComponent = ChildComponentVisibility.AccountRecordTypeScreenVisible;
        this.accountData = null;
        this.recordId = null;
        this.recordTypeId = null;
        this.winIdCreation = false;
        this.showSpinner = false;
        this.skipSearchScreen = false;
        this.isCreateWINIDBtnDisabled = true;
        this.duplicateAccountData = {};
        this.corporateAddressChanged = false;
        this.duplicateAccountRecordsVisible = false;
        this.showSelectAccountRecordTypes = false;
        this.parentAccountId = null;
    }   

    @wire(getRecord, { recordId: "$parentAccountId", fields: FIELDS })
    wiredRecord({ error, data }) {

        if (data) {           
            if (data.fields.RecordType.displayValue && (data.fields.RecordType.displayValue == 'Customer' || data.fields.RecordType.displayValue == 'Broker')) {
                this.accountData = {};
                this.accountData.parentId = this.parentAccountId;
                this.accountData.parentRecordTypeName = data.fields.RecordType.displayValue;
                this.accountData.industrySegment = data.fields.Industry_Segment__c.value;
                this.accountData.accountClass = data.fields.Class__c.value;
                this.accountData.rank = data.fields.Rank__c.value;
                this.accountData.accountSource = data.fields.AccountSource.value;
                this.accountData.parentWINId = data.fields.WIN_ID__c.value;
                this.accountData.accountName = data.fields.Name.value;
				this.accountData.currencyCode = data.fields.CurrencyIsoCode.value;
                if (data.fields.RecordType.displayValue == 'Customer') {
                    this.accountData.recordTypeId = CUSTOMER_LOCATION_RECORD_TYPE_ID;
                    this.accountData.recordTypeName = 'Customer Location'
                } else if (data.fields.RecordType.displayValue == 'Broker') {
                    this.accountData.recordTypeId = BROKER_LOCATION_RECORD_TYPE_ID
                    this.accountData.recordTypeName = 'Broker Location'

                }
                this.currentVisibleComponent = ChildComponentVisibility.CustomerScreen;
                this.accountData.hasCustomerOrBrokerParentAccount= this.accountData && this.accountData.parentId && (this.accountData.parentRecordTypeName === 'Customer' || this.accountData.parentRecordTypeName === 'Broker');
            }
        }
    }
    
    connectedCallback() {
        loadStyle(this, HideLightningHeader)
    }

    get accountRecordTypeScreenVisible() {
        return this.currentVisibleComponent === ChildComponentVisibility.AccountRecordTypeScreenVisible;
    }
    get customerScreenVisible() {
        return this.currentVisibleComponent === ChildComponentVisibility.CustomerScreen;
    }
    get customerSearchScreenVisible() {
        return this.currentVisibleComponent === ChildComponentVisibility.SearchScreen;
    }
    get customerWasteInfoQueriesScreenVisible() {
        return this.currentVisibleComponent === ChildComponentVisibility.WasteInfoQueriesScreen;
    }
    get customerWasteInfoScreenVisible() {
        return this.currentVisibleComponent === ChildComponentVisibility.WasteInformationScreen;
    }
    get customerClassificationScreenVisible() {
        return this.currentVisibleComponent === ChildComponentVisibility.CustClassificationScreen;
    }
    get customerContactScreenVisible() {
        return this.currentVisibleComponent === ChildComponentVisibility.CustContactScreen;
    }

    constructor() {
        super();
    }

    handleNextClick(event) {
        switch (this.currentVisibleComponent) {
            case ChildComponentVisibility.CustomerScreen:
                this.template.querySelector("c-child-customer-details-screen").handleNextClick();
                break;
            case ChildComponentVisibility.SearchScreen:
                this.template.querySelector("c-child-account-search-screen").handleNextClick();
                break;
            case ChildComponentVisibility.WasteInfoQueriesScreen:
                this.template.querySelector("c-child-waste-info-queries-screen").handleNextClick();
                break;
            case ChildComponentVisibility.WasteInformationScreen:
                this.template.querySelector("c-child-waste-information-screen").handleNextClick();
                break;
            case ChildComponentVisibility.CustClassificationScreen:
                this.template.querySelector("c-child-cust-classification-screen").handleNextClick();
                break;
            case ChildComponentVisibility.CustContactScreen:
                this.template.querySelector("c-child-customer-contact-screen").handleNextClick();
                break;
            default: break;
        }
    }

    handlePreviousClick(event) {
        switch (this.currentVisibleComponent) {
            case ChildComponentVisibility.SearchScreen:
                this.currentVisibleComponent = ChildComponentVisibility.CustomerScreen;
                break;
            case ChildComponentVisibility.WasteInfoQueriesScreen:
                this.currentVisibleComponent = this.skipSearchScreen == true ? ChildComponentVisibility.CustomerScreen : ChildComponentVisibility.SearchScreen;
                break;
            case ChildComponentVisibility.WasteInformationScreen:
                this.currentVisibleComponent = ChildComponentVisibility.WasteInfoQueriesScreen;
                break;
            case ChildComponentVisibility.CustClassificationScreen:
                this.currentVisibleComponent = this.accountData.requireTransportofWaste === 'no' ? ChildComponentVisibility.WasteInfoQueriesScreen : ChildComponentVisibility.WasteInformationScreen;
                break;
            case ChildComponentVisibility.CustContactScreen:
                this.template.querySelector("c-child-customer-contact-screen").handlePreviousClick();
                this.currentVisibleComponent = ChildComponentVisibility.CustClassificationScreen;
                break;
            default: break;
        }
    }

    populateDataFromChildOnPreviousClick(event) {
        this.appendAccountInputData(event.detail);
    }

    handleSingleRecordTypeAccess(event) {
        let recordTypeId = event.detail.recordTypeId;
        let recordTypeName = event.detail.recordTypeName;
        this.accountData = {};
        this.accountData.recordTypeName = recordTypeName;
        this.accountData.recordTypeId = recordTypeId;
        recordTypeName === 'Customer' || recordTypeName === 'Broker' ?
            this.currentVisibleComponent = ChildComponentVisibility.CustomerScreen
            : window.location.href = '/lightning/o/Account/new?recordTypeId=' + recordTypeId;
    }

    handleShowMultipleAccountRecordTypes(event) {
        this.showSelectAccountRecordTypes = event.detail;
    }

    async populateDataFromChildAndShowNextScreen(event) {
        this.appendAccountInputData(event.detail);
        //get data and skip search screeen if no data
        switch (this.currentVisibleComponent) {
            case ChildComponentVisibility.AccountRecordTypeScreenVisible: {
                let recordTypeId = event.detail.recordTypeId;
                if (this.accountData.recordTypeName === 'Customer' || this.accountData.recordTypeName === 'Broker') {
                    this.currentVisibleComponent = ChildComponentVisibility.CustomerScreen
                }
                else {
                    window.location.href = '/lightning/o/Account/new?recordTypeId=' + recordTypeId;
                }
                break;
            }
            case ChildComponentVisibility.CustomerScreen: {
                try {
                    this.showSpinner = true;
                    this.accountData['duplicateReason'] = null;
                    this.accountData['duplicateJustification'] = null;
                    this.duplicateAccountData = await getAccounts({ strAccountData: JSON.stringify(this.accountData) });
                    if (Array.isArray(this.duplicateAccountData) && this.duplicateAccountData.length) {
                        this.duplicateAccountData.forEach(function (element) {
                            element.ConcatenatedAddress = element.ShippingCity + ' ' + element.ShippingState + ' ' + element.ShippingPostalCode + ' ' + element.ShippingCountry;
                            if (parseInt(element.AnnualRevenue, 10) > 95) {
                                element.dynamicIcon = 'standard:answer_best';
                                element.dynamicIconLabel = 'Top Match';
                            }
                        })
                        this.skipSearchScreen = false;
                        this.currentVisibleComponent = ChildComponentVisibility.SearchScreen;
                    }
                    else {
                        this.skipSearchScreen = true;
                        this.currentVisibleComponent = ChildComponentVisibility.WasteInfoQueriesScreen;
                    }
                }
                catch (error) {
                    console.log(error);
                    this.currentVisibleComponent = ChildComponentVisibility.WasteInfoQueriesScreen;
                }
                this.showSpinner = false;

                if (this.corporateAddressChanged) {
                    this.corporateAddressChanged = false;
                    if (this.accountData && this.accountData.epaId) {
                        this.accountData.epaId = '';
                    }
                }
            }
                break;
            case ChildComponentVisibility.SearchScreen:
                this.currentVisibleComponent = ChildComponentVisibility.WasteInfoQueriesScreen;
                break;
            case ChildComponentVisibility.WasteInfoQueriesScreen: {
                let requireTransportofWaste = event.detail.requireTransportofWaste;
                this.accountwasteInfoQueries = event.detail;
                this.currentVisibleComponent = requireTransportofWaste === 'no' ? ChildComponentVisibility.CustClassificationScreen : ChildComponentVisibility.WasteInformationScreen;
                break;
            }
            case ChildComponentVisibility.WasteInformationScreen:
                this.currentVisibleComponent = ChildComponentVisibility.CustClassificationScreen;
                break;
            case ChildComponentVisibility.CustClassificationScreen:
                this.currentVisibleComponent = ChildComponentVisibility.CustContactScreen;
                break;
            case ChildComponentVisibility.CustContactScreen:
                this.currentVisibleComponent = ChildComponentVisibility.CustClassificationScreen;
                break;
            default: break;
        }
    }

    appendAccountInputData(input) {
        if (!this.accountData && input) {
            this.accountData = input;
        }
        else {
            if (input) {
                for (let key in input) {
                    if (input.hasOwnProperty(key)) {
                        this.accountData[key] = input[key];
                    }
                }
            }
        }
    }

    corporateValueChangedEvent(event) {
        this.corporateAddressChanged = true;
    }

    handleExistingAccount() {
        this.template.querySelector("c-child-account-search-screen").redirectToAccount();
    }

    handleDoumentUploadEvent(event) {
        var data = event.detail;
        this.accountData.documentId = data.documentId;
    }

    async handleCancel() {

        const result = await LightningConfirm.open({
            label: EXIT_CONFIRM_MESSAGE,
            theme: 'warning',
        });
        if (result) {
            if (this.accountData && this.accountData.documentId) {
                try {
                    await deleteCustomDocument({ documentId: this.accountData.documentId });
                    location.replace('/lightning/o/Account/list?filterName=Recent');
                }
                catch (error) {
                    console.log('Error Deleting Document ' + this.documentIdValue);
                    location.replace('/lightning/o/Account/list?filterName=Recent');
                }
            }
            else {
                location.replace('/lightning/o/Account/list?filterName=Recent');
            }
        }
    }

    handleSaveAndCloseClick(event) {
        this.template.querySelector("c-child-customer-contact-screen").handleNextClick(false);
    }

    handleWINIdCreation(event) {
        this.winIdCreation = true;
        this.template.querySelector("c-child-customer-contact-screen").handleNextClick(true);
    }

    handleSkipSearchScreen(event) {
        this.skipSearchScreen = true;
        this.currentVisibleComponent = ChildComponentVisibility.WasteInfoQueriesScreen;
    }

    handleDontSkipSearchScreen(event) {
        this.skipSearchScreen = false;
    }

    async saveAccountAndContactRecord(event) {
        this.appendAccountInputData(event.detail);
        if (this.accountData) {
            this.showSpinner = true;
            try {
                let accountResult = await createAccountAndRelatedInfoRecords({ accWrapper: this.accountData });
                if (accountResult) {
                    if (this.winIdCreation) {
                        try {
                            await validateAccountAndCreateWinId({ accountId: accountResult });
                        }
                        catch (error) {
                            this.showSpinner = false;
                            if (error.body)
                                this.showToastMessage(CREATE_ACCOUNT_ERROR_MESSAGE, error.body.message, 'error');
                        }
                    }
                    this.navigateToAccountPage(accountResult);
                }
                else {
                    this.showSpinner = false;
                }
            }
            catch (error) {
                this.showSpinner = false;
                if (error.body)
                    this.showToastMessage(CREATE_ACCOUNT_ERROR_MESSAGE, error.body.message, 'error');
            }
        } else {
            this.showSpinner = false;
            console.log('No account data available');
        }
    }

    navigateToAccountPage(accountId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    handleContactChange(event) {
        if (event.detail && event.detail.isMainContact) {
            this.isCreateWINIDBtnDisabled = false;
        } else {
            this.isCreateWINIDBtnDisabled = true;
        }
    }

    get isBtnDisabled() {
        return this.isCreateWINIDBtnDisabled;
    }

    showError(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                message: message,
                variant: 'error',
                mode: 'dismissable'
            })
        );

    }
    
    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}