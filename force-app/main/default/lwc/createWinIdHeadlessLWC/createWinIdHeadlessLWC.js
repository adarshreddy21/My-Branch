import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import validateAccount from '@salesforce/apex/AccountValidatorController.validateAccount'
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import customCss from '@salesforce/resourceUrl/css';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
const successMessage = 'Validation Passed Successfully!';

export default class CreateWinIdHeadlessLWC extends NavigationMixin(LightningElement) {
    _recordId;
    completedLoading;
    @api recordId;
    @track responseWrapper;
    loaded = true; 
     
    

    @api async invoke() {
        await loadStyle(this,customCss);
        if (!this.completedLoading && this.recordId) {
            this.loaded = !this.loaded;
            this.completedLoading = true;
            try {
				this.responseWrapper = await validateAccount({ accountId: this.recordId });
                    this.completedLoading = false;
					const successMessage = this.responseWrapper.message;
                    if (this.responseWrapper.isSuccess) {
                        this.loaded = !this.loaded;
                        getRecordNotifyChange([{recordId: this.recordId}]);
                        this.template.querySelector('c-custom-toast').showToast('success','<strong>Validation request submitted successfully: '+successMessage+'<strong/>','utility:success',15000);
                    }
                    else {
                        this.completedLoading = false;
                        const messageArray = this.responseWrapper.message.split('$$');
                        var errorMessage = '<ul>';
                        for (var i in messageArray) {
                            console.log(messageArray[i]);
                            errorMessage =  errorMessage+ '<li>'+messageArray[i]+'</li>'
                        }
                        errorMessage = errorMessage+'</ul>';
                        this.loaded = !this.loaded;
                        this.template.querySelector('c-custom-toast').showToast('warning','<strong>'+errorMessage+'<strong/>','utility:warning',15000);
                    }
            } catch (error) {
                this.loaded = !this.loaded;
                this.completedLoading = false;
                console.log('error ' + error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.replace(/@@@/g, "<br>"),
                        variant: 'error'
                    })
                );
            } finally {
            }
        }

    }

}