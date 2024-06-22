import { LightningElement, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import GEN_STATUS from '@salesforce/schema/Account.Generator_Status__c';
import checkEPAIdIsValid from '@salesforce/apex/GuidedAccountCreateSetup.checkEPAIdIsValid';
import { ShowToastEvent } from "lightning/platformShowToastEvent"; 

const US_COUNTRY = 'US';
const USA_COUNTRY = 'USA';
const CANADA_COUNTRY = 'CA';
const GENERAEG_ID_ERROR = 'Genreg Id is required for CA.';
const REQUIRED_FIELD_VALIDATION = 'Please fill out all required fields';
const EPAID_VALIDATION_MESSAGE= 'Please enter a valid EPA/Gen Reg Id';
const ALL_REQUIRED_FIELDS = ['epaIdValue', 'genStatusValue'];

export default class childWasteInformationScreen extends LightningElement {
    @api accountData;
    genStatusOptions = [];
    epaIdValue = '';
    stateEpaIdValue = '';
    genRegIdValue = '';
    genStatusValue = '';
    isDisabledGenRegId = false;
    isDisabledEPAID = false;
    showSpinner = false;
    @api requireTransportofWaste;
    @api requireEpaGenregId;

    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: GEN_STATUS 
    })
    wiredGenStatusPicklistValues({ error, data }) {
        if (data) {
            this.genStatusOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
            const defaultVal = data.defaultValue;
            if(defaultVal){
                this.genStatusValue = defaultVal.value;
            }
        }
        else if (error) {
            console.error(error);
        }
    }

    connectedCallback(){
        this.getEPAIDandGenRegPopulated();   
        if (this.accountData && this.accountData.epaId) {
            this.epaIdValue = this.accountData.epaId;
            this.genStatusValue = this.accountData.generatorStatus;
            this.stateEpaIdValue = this.accountData.stateEpaId;
            this.genRegIdValue = this.accountData.genRegId;
          
        }           
    }

    getEPAIDandGenRegPopulated(){
        if( this.accountData.requireTransportofWaste === 'yes' &&
            this.accountData.requireEpaGenregId === 'no'){
                if(this.accountData.corporateAddress.shippingCountry.toUpperCase() === USA_COUNTRY || this.accountData.corporateAddress.shippingCountry.toUpperCase() ===  US_COUNTRY){
                    this.epaIdValue = 'Pending';
                }
                else if(this.accountData.corporateAddress.shippingCountry.toUpperCase() === CANADA_COUNTRY){
                    this.genRegIdValue = 'Pending';
                }
        }
        if(this.accountData.corporateAddress.shippingCountry.toUpperCase() === CANADA_COUNTRY){
            this.epaIdValue = 'FCCANADA';
            this.isDisabledEPAID = true;
        }
        if(this.accountData.corporateAddress.shippingCountry.toUpperCase() === USA_COUNTRY || this.accountData.corporateAddress.shippingCountry.toUpperCase() ===  US_COUNTRY){
            this.isDisabledGenRegId = true;
        }  
    }

    handleEPAIDChange(event){
        this.epaIdValue = event.target.value;
    }
    handleGenStatusChange(event){
        this.genStatusValue = event.target.value;        
    }
    handleStateEPAIDChange(event){
        this.stateEpaIdValue = event.target.value;
    }
    handleGenRegIdChange(event){
        this.genRegIdValue = event.target.value;
    }
    
   @api 
   async handleNextClick(){  
        let allFieldsFilled = true;
        ALL_REQUIRED_FIELDS.forEach(field => {
            if (!this[field]) {
                allFieldsFilled = false;
                this.showToastMethod(REQUIRED_FIELD_VALIDATION, 'error');
            }
        });

        if (allFieldsFilled) {
            this.showSpinner = true;
            const shippingCountry = this.accountData.corporateAddress.shippingCountry;
            if (shippingCountry === CANADA_COUNTRY && !this.genRegIdValue) {
                allFieldsFilled = false;
                this.showToastMethod(GENERAEG_ID_ERROR, 'error');
                this.showSpinner = false;
                return;
            }
            let result = await checkEPAIdIsValid({'accountDataWrapperObj':{
                    epaId: this.epaIdValue,
                    genRegId : this.genRegIdValue, 
                    country: this.accountData.corporateAddress.shippingCountry,
                    generatorStatus: this.genStatusValue,
                    stateEpaId: this.stateEpaIdValue,
                    shippingStreet: this.accountData.corporateAddress.shippingStreet,
                    shippingState: this.accountData.corporateAddress.shippingState,
                    primaryServiceProvider: this.accountData.primaryBusiness,
                    shippingCity: this.accountData.corporateAddress.shippingCity
            }});

            this.showSpinner = false;
            this.data = result;
            if(this.data.response && this.data.response.messageCode != 0 && (this.data.response.message || this.data.response.exceptionMessage)){
                this.message = this.data.response.message ? this.data.response.message : this.data.response.exceptionMessage ? this.data.response.exceptionMessage : '';
                this.showToastMethod(this.message,'error');
                return;
            }
            if(this.data.isEPAValid === true || this.data.response.validEpa){
                let accWasteInfoData =
                {
                    epaId: this.epaIdValue,
                    generatorStatus: this.genStatusValue,
                    stateEpaId: this.stateEpaIdValue,
                    genRegId: this.genRegIdValue
                    
                };
                if(this.data.response && this.data.response.messageCode == 0){
                    this.showToastMethod(this.data.response.message, 'success');
                }
                const selectedEvent = new CustomEvent("accountsvaluechange", {
                    detail: accWasteInfoData
                });

                this.dispatchEvent(selectedEvent);
            }else{
                this.showToastMethod(EPAID_VALIDATION_MESSAGE, 'error');
            }
        }
    }

    showToastMethod(message, variant)
    {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
          });
          this.dispatchEvent(evt);
    }   
}