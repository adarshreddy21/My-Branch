import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
export default class GenericRefreshDetailPage extends NavigationMixin(LightningElement) {
    @api recordId;
    disconnectedCallback() {
       console.log(this.recordId);
       this.navigateToRecordViewPage();
    }
    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}