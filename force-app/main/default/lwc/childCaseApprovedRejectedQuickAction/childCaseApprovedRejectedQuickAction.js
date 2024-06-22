import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getChildCaseRecords from '@salesforce/apex/CaseApprovalRelatedListController.getChildCaseRecords';
import approveRejectCaseRecords from '@salesforce/apex/CaseApprovalRelatedListController.approveRejectCaseRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
const columns = [
    {
        label: 'Case Number', fieldName: 'caseNumberUrl', type: 'url', wrapText: true, typeAttributes: {
            label: { fieldName: 'caseNumber' },
            target: "_blank",
            tooltip: { fieldName: 'caseNumber' }
        }
    },
    { label: 'Status', fieldName: 'status' },
    { label: 'Account Field Changed', fieldName: 'accountFieldChanged' },
    { label: 'Old Value', fieldName: 'oldValue', wrapText: true },
    { label: 'New Value', fieldName: 'newValue', wrapText: true },
    { label: 'Subject', fieldName: 'subject', wrapText: true }
];
const PLEASE_SELECT_CASE = 'Please select atlease one case for Approve/Reject.';

export default class ChildCaseApprovedRejectedQuickAction extends NavigationMixin(LightningElement) {

    @api recordId;
    selectedIds;
    state;
    error;
    areApproveRejectVisible = true;
    caseRecordsData;
    count = 0;
    showSpinner = false;
    columns = columns;
    retrievedRecordId = false;
    noAccessMessage = '';
    noRecordsToDisplay = false;
    connectedCallback() {
        let modal = document.querySelectorAll(".slds-modal__container");
        modal[0].style.minWidth = "110rem";
    }

    async renderedCallback() {
        if (!this.retrievedRecordId && this.recordId) {
            try {
                let ChildCasesDataWrapper = await getChildCaseRecords({ parentId: this.recordId });
                this.areApproveRejectVisible = ChildCasesDataWrapper.hasUserAccess;
                this.caseRecordsData = ChildCasesDataWrapper.childCasesData;
                if (this.caseRecordsData && this.caseRecordsData.length > 0) {
                    this.count = this.caseRecordsData.length;
                }
                else if(this.areApproveRejectVisible){
                    this.areApproveRejectVisible =false;
                    this.noRecordsToDisplay = true;
                }
                this.noAccessMessage = ChildCasesDataWrapper.message;

            }
            catch (error) {
                this.areApproveRejectVisible = false;
                console.log(error);
            }
            this.retrievedRecordId = true;
        }
    }

    handleApproveRecord(event) {
        this.state = 'Approve';
        this.approveRejectCases();
    }

    get getCaseApprovalHeadlineCount() {
        return 'Approve/Reject Cases (' + this.count + ')';
    }

    get getNoRecordsToDisplay() {
        return this.noRecordsToDisplay;
    }

    handleRejectRecord(event) {
        this.state = 'Reject';
        this.approveRejectCases();
    }
    async approveRejectCases() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        if (selectedRecords.length > 0) {
            let ids = '';
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.id;
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.showSpinner = true;
            this.caseRecordsData = await approveRejectCaseRecords({ selectedChildRecordIds: this.selectedIds, parentId: this.recordId, status: this.state });
            this.closeQuickAction();
            this.showSpinner = false;
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.ShowToastEvent('Case records got Approved/Rejected sucessfully', 'success');
        }
        else {
            this.showToastMethod(PLEASE_SELECT_CASE, 'error');
        }
    }
    showToastMethod(message, variant) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}