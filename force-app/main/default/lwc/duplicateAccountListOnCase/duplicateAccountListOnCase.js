import { LightningElement, api } from 'lwc';
import getDuplicateAccountsRecords from '@salesforce/apex/GuidedAccountCreateSetup.getDuplicateAccountsRecords';

export default class DuplicateAccountListOnCase extends LightningElement {
    @api recordId;
    duplicateAccountData = {};
    duplicateAccountDataTopMatch = [];
    duplicateAccountRecordsVisible = false;
    async connectedCallback() {
        this.duplicateAccountData  = await getDuplicateAccountsRecords({ caseId: this.recordId });
        const self = this;
        if (Array.isArray(this.duplicateAccountData) && this.duplicateAccountData.length) {
            this.duplicateAccountRecordsVisible = true;
            this.duplicateAccountData.forEach(function (element) {
                element.ConcatenatedAddress = element.ShippingCity + ' ' + element.ShippingState + ' ' + element.ShippingPostalCode + ' ' + element.ShippingCountry;
                if (parseInt(element.AnnualRevenue, 10) > 95) {
                    element.dynamicIcon = 'standard:answer_best';
                    element.dynamicIconLabel = 'Top Match';
                    self.duplicateAccountDataTopMatch.push(element);
                }
            })
        }
        
    }
}