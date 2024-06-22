import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const ERROR_MESSAGE_REQUIRED_FIELD_MISSING = 'Please select the required Options'; 
const USA_COUNTRY = 'US';
const CANADA_COUNTRY = 'CA';
const YES_OPTION = {label: 'Yes', value: 'yes'};
const NO_OPTION = {label: 'No', value: 'no'};
const PENDING = 'PENDING';
const UNDETERMINED = 'Undetermined';

export default class ChildWasteInformationScreen extends LightningElement{
    showQuestionTwo = false;
    @api accountData;
    selectedTransportOfWasteRequireValue;
    selectedEpaGenregIdRequireValue;

    get transportofWasteRequireOptions(){
        return [YES_OPTION, NO_OPTION];           
    }

    get epaGenregIdRequireOptions(){
        return [YES_OPTION, NO_OPTION];
    }

    connectedCallback() {
        if(this.accountData){
            this.selectedTransportOfWasteRequireValue = this.accountData.requireTransportofWaste;
            this.selectedEpaGenregIdRequireValue = this.accountData.requireEpaGenregId;
            if(this.selectedTransportOfWasteRequireValue === YES_OPTION.value){
                this.showQuestionTwo = true;
            }          
        }
    }

    handleQuestionOne(event){
        this.selectedTransportOfWasteRequireValue = event.target.value;
        if(this.selectedTransportOfWasteRequireValue === YES_OPTION.value){
            this.showQuestionTwo = true;
        } else {
            this.showQuestionTwo = false;
        }       
    } 

    handleQuestionTwo(event){
        this.selectedEpaGenregIdRequireValue = event.target.value;
    }   

    @api handleNextClick() {
        let allFieldsFilled = true;
        if((this.selectedTransportOfWasteRequireValue === YES_OPTION.value && !this.selectedEpaGenregIdRequireValue) || !this.selectedTransportOfWasteRequireValue){
            allFieldsFilled = false;
            this.showToastMethod(ERROR_MESSAGE_REQUIRED_FIELD_MISSING,'error');
        }       
        if(allFieldsFilled){
            if(this.selectedTransportOfWasteRequireValue === NO_OPTION.value){
                if(this.accountData.corporateAddress.shippingCountry === USA_COUNTRY){
                    this.epaIdValue = PENDING;
                    this.genStatusValue = UNDETERMINED;
                }
                else if(this.accountData.corporateAddress.shippingCountry === CANADA_COUNTRY){
                    this.genRegIdValue = PENDING;
                    this.genStatusValue = UNDETERMINED;
                }
            }       
            let accWinInfoQueriesData = {};
            if (!this.accountData.epaId && this.accountData.epaId!='') {
                accWinInfoQueriesData =
                {
                    requireTransportofWaste: this.selectedTransportOfWasteRequireValue,
                    requireEpaGenregId: this.selectedEpaGenregIdRequireValue,
                    epaId: this.epaIdValue,
                    genRegId: this.genRegIdValue,
                    generatorStatus: this.genStatusValue

                };
            }
            else {
                accWinInfoQueriesData =
                {
                    requireTransportofWaste: this.selectedTransportOfWasteRequireValue,
                    requireEpaGenregId: this.selectedEpaGenregIdRequireValue
                };
            }
            const selectedEvent = new CustomEvent("accountsvaluechange", {
                detail: accWinInfoQueriesData
            });
            this.dispatchEvent(selectedEvent);
        }        
    }  
    
    showToastMethod(message,variant)
    {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
          });
          this.dispatchEvent(evt);
    }
}