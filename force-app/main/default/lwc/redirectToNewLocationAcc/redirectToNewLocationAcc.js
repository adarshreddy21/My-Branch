import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class RedirectToNewLocationAcc extends NavigationMixin(LightningElement) {
    @api recordId;

    @api invoke() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'New_Account_Setup'
            },
            state: {
                'c__parentid': this.recordId
            }
          });

    }
}