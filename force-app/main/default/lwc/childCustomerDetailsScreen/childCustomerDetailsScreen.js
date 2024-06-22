import { LightningElement, api, wire,track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import OS_FIELD from '@salesforce/schema/Account.Primary_Service_Provider_New__c';
import PSP_FIELD from '@salesforce/schema/Account.Primary_Business__c';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAddressinZipMaster from '@salesforce/apex/GuidedAccountCreateSetup.checkAddressinZipMaster';

const ALLOWED_RECORD_TYPES = ['Corporate', 'Key_Account'];
const ALLOWED_CHAIN_RECORD_TYPE = ['Chain'];
const ERROR_MESSAGE_REQUIRED_FIELD_MISSING = 'Please fill out all required fields';
const ERROR_MESSAGE_ACCOUNT_NAME_VALIDATION = 'Account Name must be at least three characters (excluding & character), it must be less than 256 characters, and it may not contain the | special character.';
const ERROR_MESSAGE_STATE_LENGTH = 'Please use only 2 chars State abbreviation';
const ERROR_MESSAGE_STREET_LENGTH = 'Corporate and Billing Street field cannot have more than 60 characters.';
const ERROR_MESSAGE_ZIPCODE_VALIDATION = 'ZIP code can be only of 5 or 9 digits in the formats "xxxxx", "xxxxx-yyyy", or "xxxxxyyyy"';
const SPECIAL_CHAR_REGEX = /[|]/;
const EXCLUDED_CHAR_REGEX = /[&()\s]/;
const ZIP_CODE_PATTERN = /^\d{5}(-\d{4})?$/;
const ALL_REQUIRED_FIELDS = ['accountNameValue', 'accountPhoneValue', 'primaryServiceProviderNewValue', 'primaryBusinessValue',
                            'billingAddress', 'corporateAddress'];
const ERROR_MESSAGE_ACCOUNT_PHONE_LENGTH = 'Phone number must be 10 digits and You may not submit a number that is repeating digits or 1234567890.	';

export default class ChildCustomerDetailsScreen extends LightningElement {
    
    _accountData;
    get accountData(){
        return this._accountData;
    }
    @api set accountData(value){
        this._accountData = value;
        if(this._accountData){
            this.hasCustomerOrBrokerParentAccount= this._accountData.hasCustomerOrBrokerParentAccount;
            if (this.hasCustomerOrBrokerParentAccount) {
                this.disableParentAccountLookup = true;
                this.filter = {
                    criteria: [
                        {
                            fieldPath: 'Status__c',
                            operator: 'eq',
                            value: 'Active',
                        }
                    ]
                };
                this.parentId = this._accountData.parentId;
            }else{
                this.hasCustomerOrBrokerParentAccount = false;
            }
            this.accountNameValue = this._accountData.accountName;
            this.accountPhoneValue = this._accountData.accountPhone;
            this.sameAsCorpAddressValue = this._accountData.sameAsCorpAddress;
            this.parentId = this._accountData.parentId;
			this.chainAccountValue= this._accountData.chainId;
            this.primaryServiceProviderNewValue = this._accountData.primaryServiceProviderNew;
            this.primaryBusinessValue = this._accountData.primaryBusiness;
            this.readPSPOnlyBool = false;
            if(this._accountData.corporateAddress){
                this.corporateAddress =
                {
                    shippingStreet: this._accountData.corporateAddress.shippingStreet,
                    shippingCity: this._accountData.corporateAddress.shippingCity,
                    shippingState: this._accountData.corporateAddress.shippingState,
                    shippingPostalCode: this._accountData.corporateAddress.shippingPostalCode,
                    shippingCountry: this._accountData.corporateAddress.shippingCountry,
                    corporateAddress2: this._accountData.corporateAddress.corporateAddress2
                }
                if(this._accountData.billingAddress){
                    this.billingAddress =
                    {
                        billingStreet: this._accountData.billingAddress.billingStreet,
                        billingCity: this._accountData.billingAddress.billingCity,
                        billingState: this._accountData.billingAddress.billingState,
                        billingPostalCode: this._accountData.billingAddress.billingPostalCode,
                        billingCountry: this._accountData.billingAddress.billingCountry,
                        billingAddress2: this._accountData.billingAddress.billingAddress2
                    };
                }            
                if (this.sameAsCorpAddressValue) {
                    this.disableAddress = true;             
                }
            }
        }
    }
	hasCustomerOrBrokerParentAccount = false;
    disableParentAccountLookup = false;
    filter = {};
    osOptions = [];
    pspOptions = [];
    pspData = [];
    
    @track billingAddress=
    {
        billingStreet: null,
        billingCity: null,
        billingState: null,
        billingPostalCode: null,
        billingCountry: null,
        billingAddress2: null
    };
    @track corporateAddress=
    {
        shippingStreet: null,
        shippingCity: null,
        shippingState: null,
        shippingPostalCode: null,
        shippingCountry: null,
        corporateAddress2: null

    };
    accountNameValue = '';
    accountPhoneValue = '';
    sameAsCorpAddressValue = false;
    primaryServiceProviderNewValue = '';
    primaryBusinessValue = '';
    parentId = '';
	chainId ='';
    billingAddress2Value = '';
    corporateAddress2Value = '';
    disableAddress = false;
    readPSPOnlyBool = false;
    showSpinner = false;
    parentId = '';
	chainAccountValue = '';
    shippingAddress;
    
	displayAccountWINAndType = {
        additionalFields: ['WIN_ID_Type__c']
    }
	
    filter = {
        criteria: [
        {
            fieldPath: 'RecordType.DeveloperName',
            operator: 'in',
            value: ALLOWED_RECORD_TYPES
        },
        {
            fieldPath: 'Status__c',
            operator: 'eq',
            value: 'Active',
            filterLogic: '1 AND 2'
        }
        ],
    };
    
	chainAccountFilter = {
        criteria: [
            {
                fieldPath: 'RecordType.DeveloperName',
                operator: 'in',
                value: ALLOWED_CHAIN_RECORD_TYPE
            },
            {
                fieldPath: 'Expired__c',
                operator: 'eq',
                value: false
            }
        ],
        filterLogic: '1 AND 2'
    };
	
    constructor() {
        super();
        this.readPSPOnlyBool = true;
    }

  
    //Operating Segment Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$_accountData.recordTypeId',
        fieldApiName: OS_FIELD 
    })
    wiredOSPicklistValues({ error, data }) {
        if (data) {
            this.osOptions = data.values.map(option => {
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

    //PSP Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$_accountData.recordTypeId',
        fieldApiName: PSP_FIELD 
    })

    wiredPSPPicklistValues({ error, data }) {
        if (data) {
            this.pspData = data;
            this.pspOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
            if(this._accountData){
                let key = this.pspData.controllerValues[this._accountData.primaryServiceProviderNew];
                this.pspOptions = this.pspData.values.filter(opt => opt.validFor.includes(key));
            }
        }
        else if (error) {
            console.error(error);
        }
    }

    handleOSChange(event) {
        this.primaryServiceProviderNewValue = event.target.value;
        let key = this.pspData.controllerValues[event.target.value];
        this.pspOptions = this.pspData.values.filter(opt => opt.validFor.includes(key));
        if(this.pspOptions.length === 1){
            this.primaryBusinessValue = this.pspOptions[0].value;
            this.readPSPOnlyBool = true;
        }
        else{
            this.primaryBusinessValue = null;
            this.readPSPOnlyBool = false;
        }
    }

    handlePSPChange(event) {
        this.primaryBusinessValue = event.target.value;
    }

    handleNameChange(event) {
        this.accountNameValue = event.target.value;
    }

    handleCorporateAddress2Change(event) {
        this.corporateAddress.corporateAddress2 = event.target.value;
    }

    handleAccountPhoneChange(event){
        this.accountPhoneValue = event.target.value;
    }

    handleBillingAddress2Change(event) {
        this.billingAddress.billingAddress2 = event.target.value;
    }

    handleAccountSelection(event){
        this.parentId = event.detail.recordId;
    }
	
	handleChainAccountSelection(event){
        this.chainAccountValue = event.detail.recordId;
    }

    handleSameAsCorpChange(event) {
        this.sameAsCorpAddressValue = event.target.checked;
        if (this.sameAsCorpAddressValue) {
            this.disableAddress = true;
            this.mapShippingToBilling();
        }
        else {
            this.disableAddress = false;
        }
    }   

    handleShippingAddressInputChange(event) {
        this.corporateAddress.shippingStreet= event.target.street;
        this.corporateAddress.shippingCity=event.target.city;
        this.corporateAddress.shippingState=event.target.province;
        this.corporateAddress.shippingPostalCode=event.target.postalCode;
        this.corporateAddress.shippingCountry=event.target.country; 
        if (this.sameAsCorpAddressValue) {
            this.mapShippingToBilling();         
        }
        if(this._accountData && Object.keys(this._accountData).length!=0){
        const selectedEvent = new CustomEvent("corporatevaluechanged", {
            detail: ''
        });
        this.dispatchEvent(selectedEvent);
    }
    }

    mapShippingToBilling(){
        this.billingAddress.billingStreet = this.corporateAddress.shippingStreet;
        this.billingAddress.billingCity = this.corporateAddress.shippingCity;
        this.billingAddress.billingState=  this.corporateAddress.shippingState;
        this.billingAddress.billingPostalCode= this.corporateAddress.shippingPostalCode;
        this.billingAddress.billingCountry= this.corporateAddress.shippingCountry;
    }
    handleBillingAddressInputChange(event) {
        this.billingAddress.billingStreet= event.target.street;
        this.billingAddress.billingCity=event.target.city;
        this.billingAddress.billingState=event.target.province;
        this.billingAddress.billingPostalCode=event.target.postalCode;
        this.billingAddress.billingCountry=event.target.country;   
    }

    @api async handleNextClick(){ 
      
        let allFieldsFilled = true;
        ALL_REQUIRED_FIELDS.forEach(field => {
            if(field ==='corporateAddress' || (field ==='billingAddress' && !this.hasCustomerOrBrokerParentAccount)){
                for (let key in this[field]) {
                    if (!this[field][key] && key !== 'billingAddress2' && key !== 'corporateAddress2') {
                        allFieldsFilled = false;
                    }
                }
            }
            else if (!this[field]) {
                allFieldsFilled = false;
            }
        });
        if (allFieldsFilled) {
            this.showSpinner = true;
			if(!this.hasCustomerOrBrokerParentAccount){
                this.billingAddress.billingCountry = (this.billingAddress.billingCountry.toLowerCase() === 'united states' || this.billingAddress.billingCountry.toLowerCase() === 'usa') ? 'US' :
                                    (this.billingAddress.billingCountry.toLowerCase() === 'canada' ? 'CA' : this.billingAddress.billingCountry);
                                    this.hasCustomerOrBrokerParentAccount = false;
                                }
            this.corporateAddress.shippingCountry = (this.corporateAddress.shippingCountry.toLowerCase() === 'united states' || this.corporateAddress.shippingCountry.toLowerCase() === 'usa') ? 'US' :
                                    (this.corporateAddress.shippingCountry.toLowerCase() === 'canada' ? 'CA' : this.corporateAddress.shippingCountry);
           
            if(this.validateAccountDetailsInputs()){              
                let results = await checkAddressinZipMaster({corpCountry: this.corporateAddress.shippingCountry,
                    corpState: this.corporateAddress.shippingState,
                    corpCity: this.corporateAddress.shippingCity,
                    corpPostalCode: this.corporateAddress.shippingPostalCode,
                    billCountry: this.billingAddress.billingCountry,
                    billState: this.billingAddress.billingState,
                    billCity: this.billingAddress.billingCity,  
                    billPostalCode: this.billingAddress.billingPostalCode, 
					hasCustomerOrBrokerParentAccount: this.hasCustomerOrBrokerParentAccount
                });
                this.showSpinner = false; 
                this.data = results;
                if (results.status === 'Error') {            
                    this.showToastMethod(results.message,'error');
                }                
                else{ 
                    let localAccountData =
                    {                          
                        accountName: this.accountNameValue,
                        accountPhone: this.accountPhoneValue,
                        parentId: this.parentId,
						chainId: this.chainAccountValue,
                        corporateAddress: this.corporateAddress,
                        primaryServiceProviderNew: this.primaryServiceProviderNewValue,
                        sameAsCorpAddress: this.sameAsCorpAddressValue,
                        billingAddress: this.billingAddress,
                        primaryBusiness: this.primaryBusinessValue
                    };
                    const selectedEvent = new CustomEvent("accountsvaluechange", {
                        detail: localAccountData
                    });
                    this.dispatchEvent(selectedEvent);
                }               
            }
        }
        else{
            this.showToastMethod(ERROR_MESSAGE_REQUIRED_FIELD_MISSING,'error');
        }
    }
   
    validateAccountDetailsInputs(){
        let isValid = true;  
        const nameLength = this.accountNameValue.split('').filter(char => !EXCLUDED_CHAR_REGEX.test(char)).length;
        const isValidAccountPhone = /^[0-9]{10}$/.test(this.accountPhoneValue.replace(/[\-\(\)]/g, '')) && 
                                    !/(.)\1{9,}/.test(this.accountPhoneValue) && 
                                    !/(0123456789|1234567890)/.test(this.accountPhoneValue);
        
        if(!isValidAccountPhone){
            this.showToastMethod(ERROR_MESSAGE_ACCOUNT_PHONE_LENGTH,'error');	
            isValid = false;
        }
        else if(nameLength < 3 || SPECIAL_CHAR_REGEX.test(this.accountNameValue)){
            this.showToastMethod(ERROR_MESSAGE_ACCOUNT_NAME_VALIDATION,'error');
            isValid = false;
        }
        if(this.hasCustomerOrBrokerParentAccount){
            if(this.corporateAddress.shippingState.length > 2){
                this.showToastMethod(ERROR_MESSAGE_STATE_LENGTH,'error');
                isValid = false;
            }
            else if(this.corporateAddress.shippingStreet.length > 60){
                this.showToastMethod(ERROR_MESSAGE_STREET_LENGTH,'error');
                isValid = false;
            }
            else if( (!ZIP_CODE_PATTERN.test(this.corporateAddress.shippingPostalCode) && this.corporateAddress.shippingCountry === 'US')){
                this.showToastMethod(ERROR_MESSAGE_ZIPCODE_VALIDATION,'error');	
                isValid = false;
            }
        }else{
            if(this.billingAddress.billingState.length > 2 || this.corporateAddress.shippingState.length > 2){
                this.showToastMethod(ERROR_MESSAGE_STATE_LENGTH,'error');
                isValid = false;
            }
            else if(this.billingAddress.billingStreet.length > 60 || this.corporateAddress.shippingStreet.length > 60){
                this.showToastMethod(ERROR_MESSAGE_STREET_LENGTH,'error');
                isValid = false;
            }
            else if((this.billingAddress.billingCountry === 'US' && !ZIP_CODE_PATTERN.test(this.billingAddress.billingPostalCode)) || (!ZIP_CODE_PATTERN.test(this.corporateAddress.shippingPostalCode) && this.corporateAddress.shippingCountry === 'US')){
                this.showToastMethod(ERROR_MESSAGE_ZIPCODE_VALIDATION,'error');	
                isValid = false;
            }            
        }                                    
        return isValid;
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