import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import DUPLICATE_REASON from '@salesforce/schema/Account.Duplicate_Reason__c';
const columns = [
    { label: '', fieldName: '',  cellAttributes: { iconName: { fieldName: 'dynamicIcon' }, iconLabel: { fieldName: 'dynamicIconLabel' } }},
    { label: 'Account Name', fieldName: 'Name'},
    { label: 'WIN ID - Type', fieldName: 'WIN_ID_Type__c'},
    { label: 'Primary Service Provider', fieldName: 'Primary_Business__c'},
    { label: 'Corporate Street', fieldName: 'ShippingStreet'},   
    { label: 'Corporate City State Zip Country', fieldName: 'ConcatenatedAddress', initialWidth: 400 },
    { label: 'Status', fieldName: 'Status__c'}
];

const Hidecoulmns = [
    { label: '', fieldName: '',  cellAttributes: { iconName: { fieldName: 'dynamicIcon' }, iconLabel: { fieldName: 'dynamicIconLabel' } }},
    { label: 'Account Name', fieldName: 'Name'},
    { label: 'Corporate Street', fieldName: 'ShippingStreet'},   
    { label: 'Corporate City State Zip Country', fieldName: 'ConcatenatedAddress', initialWidth: 400 }
];
export default class ChildAccountSearchScreen extends NavigationMixin(LightningElement) {
    @api accountData;
    @api showDuplicateAccountOnCase = false;
    concatenatedCorpAddress;
    hideCheckBoxColumn =false;
    data = [];
    selectedRowId = '';
    columns = columns;
	Hidecoulmns = Hidecoulmns;
    @api duplicateAccountData = {};
    totalRecordCount = 0; 
    pageSize = 10; 
    totalPages; 
    pageNumber = 1; 
    recordsToDisplay = [];  
    duplicateReasonValue = '';
    duplicateJustificationValue = '';
    drOptions = [];
    isShowAccountReason = false;
    
    get hideShowColumns() { 
        return this.accountData && this.accountData.isCorpAddressUpdate ? Hidecoulmns : columns;
    }

    get disableFirst() {
        return this.pageNumber == 1;
    }
    get disableLast() {
        return this.pageNumber == this.totalPages;
    }
    
    get displayAccountName() {
        return (this.accountData.recordTypeName === 'Customer' || this.accountData.recordTypeName === 'Customer Location') ? 'Customer/ShipToGen' 
                : (this.accountData.recordTypeName === 'Broker' || this.accountData.recordTypeName === 'Broker Location') ? 'Broker/Broker Location'
                : this.accountData.recordTypeName;
    }
     
    connectedCallback() {
        this.getAccountsRecords();
        if (this.accountData && this.accountData.accountName) {
            this.concatenatedCorpAddress = this.accountData.corporateAddress.shippingStreet +' '+ 
            this.accountData.corporateAddress.shippingCity + ' ' +
        this.accountData.corporateAddress.shippingState + ' '+
        this.accountData.corporateAddress.shippingPostalCode +' '+
        this.accountData.corporateAddress.shippingCountry ;
          
        }
        if(this.showDuplicateAccountOnCase)
        {
            this.hideCheckBoxColumn = true;
        }
    }
    getAccountsRecords() {
        if (Array.isArray(this.duplicateAccountData) && this.duplicateAccountData.length) {
            this.data = this.duplicateAccountData; 
            this.totalRecordCount = this.duplicateAccountData.length; 
            this.paginationHelper();
        }
       
    }
    @api handleNextClick() {
        

        if(this.duplicateAccountData){
            this.duplicateAccountData.forEach((element) => {
                if(element.dynamicIconLabel == 'Top Match' ){
                    console.log('Top Match');
                    this.isShowAccountReason = true;
                    return;
                }
            });
        }
        
        if(!this.isShowAccountReason){
            this.dispatchEvent(
                new CustomEvent(
                    'accountsvaluechange'
                )
            )
        }
    }
    getSelectedAccount(event) {
        const selectedRows = event.detail.selectedRows;
        if(selectedRows && Array.isArray(selectedRows) && selectedRows.length > 0){
            this.selectedRowId = selectedRows[0].Id;
        }
    }
    @api redirectToAccount() {
        if (this.selectedRowId) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.selectedRowId,
                    actionName: 'view',
                    objectApiName: 'Account',
                },
            }).then((url) => {
                window.location.replace(url);
            });
        }
        else{
            this.showError('Please select an account to continue with existing account.');
        }
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    paginationHelper() {
        this.recordsToDisplay = [];
        this.totalPages = Math.ceil(this.totalRecordCount / this.pageSize);
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        let begin = (this.pageNumber - 1) * parseInt(this.pageSize);
        let end = parseInt(begin) + parseInt(this.pageSize);
        this.recordsToDisplay = this.data.slice(begin, end);
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

    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId',
        fieldApiName: DUPLICATE_REASON 
    })
    wiredOSPicklistValues({ error, data }) {
        if (data) {
            this.drOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }
        else if (error) {
            console.error(error);
        }
    }

    handleDuplicateAccountSelection(event) {
        this.duplicateReasonValue = event.target.value;
    }

    handleReasonChange(event){
        this.duplicateJustificationValue = event.target.value;
    }

    handleNext(){
        const allValid = [
            ...this.template.querySelectorAll('[data-id="duplicateAccRecId"]'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (!allValid) {
            return;
        }

        this.dispatchEvent(
            new CustomEvent(
                'accountsvaluechange',
                {
                    detail: {
                        'duplicateReason': this.duplicateReasonValue,
                        'duplicateJustification': this.duplicateJustificationValue
                    }
                }
            )
        )
    }

    hanldeCancel(){
        this.isShowAccountReason = false;
    }
   
}