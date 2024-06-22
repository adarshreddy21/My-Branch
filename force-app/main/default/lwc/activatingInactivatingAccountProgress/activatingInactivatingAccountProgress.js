import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import INACTIVATE_REACTIVATE_FIELD from '@salesforce/schema/Account.Inactivate_Reactivate_In_Progress__c';
import STATUS_FIELD from '@salesforce/schema/Account.Status__c';
const fields = [INACTIVATE_REACTIVATE_FIELD, STATUS_FIELD];
export default class ActivatingInactivatingAccountProgress extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    account;

    get reactivate() {
        return getFieldValue(this.account.data, INACTIVATE_REACTIVATE_FIELD);
    }

    get status() {
        if(getFieldValue(this.account.data, STATUS_FIELD) === 'Inactive'){
            return true;
        }
        else{
            return false;
        }
    }
}