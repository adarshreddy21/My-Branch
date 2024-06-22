import { LightningElement, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';
import CONTACT_TYPE_FIELD from '@salesforce/schema/Contact.Contact_Type__c';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from 'lightning/confirm';
import checkManiAddressinZipMaster from '@salesforce/apex/GuidedAccountCreateSetup.checkManiAddressinZipMaster';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; 

const ERROR_MESSAGE_REQUIRED_FIELD_MISSING = 'Please fill out all required fields';
const ZIP_CODE_PATTERN = /^(\d{5}(-\d{4})?|\d{9}|\d{4}\d{4})$/;
const ALL_REQUIRED_FIELDS = ['salutationValue', 'contactTypeValue', 'firstNameValue', 'titleValue',
                            'lastNameValue', 'phoneValue', 'emailValue'];
const IS_EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MASTER_CONTACT_RECORD_TYPE_ID = '012j0000001DaVbAAK';
const CONFIRM_ACCOUNT_SAVE_AND_CLOSE = 'If you save and close now, your account will be saved but no WinID will be assigned. You will be able to resume setup through normal editing of an account. Are you sure you want to save and close?';
const ERROR_MESSAGE_CONTACT_TYPE_DUPLICATE = 'Duplicate department code already exists on related Account.';
const ERROR_MESSAGE_INVALID_CONTACT_MOBILE = 'Please enter a valid 10-digit mobile number or leave blank';
const ERROR_MESSAGE_INVALID_CONTACT_PHONE = 'Please enter a valid 10-digit phone number.';
const ERROR_MESSAGE_MOBILE_PHONE_LENGTH = 'Phone/Mobile number too long Or too Short.';
const ERROR_MESSAGE_INVALID_EMAIL = 'Email address must be valid and should not contain @cleanharbors.com, @email.com, @safety-kleen.com, refused, pending, noemail, unknown.';
const ERROR_MESSAGE_MANI_REQUIRED = 'MANI Contact should have address';
const ERROR_MESSAGE_INVALID_MANI_ZIPCODE = 'ZIP code can be only of 5 or 9 digits in the formats "xxxxx", "xxxxx-yyyy", or "xxxxxyyyy"';
const SPECIAL_EMAIL_REGEX = ['pending','refused','noemail','unknown','@safety-kleen.com','@email.com','@cleanharbors.com'];
const ERROR_MESSAGE_OPPORTUNITY_RT_REQUIRED = 'Opportuntiy Record Type must be selected when Auto Create Opportunity is checked';
const ERROR_MESSAGE_PARENT_WINID_REQUIRED = 'WinID on Parent must be available before you can submit for a WinID on this Gen account. To proceed, click the Save Prospect and Close button and request a WinID only after the parent account has a WinID assigned.';
const DUPLICATE_CONTACT_MESSAGE = 'The entered email address is associated with an existing contact. Please choose an existing contact or update the email address';

export default class ChildCustomerContactScreen extends LightningElement {
    @api contactData = {contacts: []};
    @api accountData;
    salutationOptions = [];
    contactTypeValue = [];
    contactTypeOptions = [];
    contactPhone = '';
    keyIndex = 0;
    error;
    message;
    isShowModal = false;
    isMANIContact = false;
    salutationValue = '';
    firstNameValue = '';
    titleValue = '';
    lastNameValue = '';
    phoneValue = '';
    emailValue = '';
    phoneExtensionValue = '';
    mobileValue = '';
    rltContactValue = false;
    maniStreetValue = '';
    maniAddress2Value = '';
    maniCityValue = '';
    maniStateValue = '';
    maniPostalCodeValue = '';
    maniCountryValue = '';
    maniSameAsCorpValue = false;
    isDisabled = false;
    isEdit = false;
    contactIndex = null;
    contactRecList = [];
    contactIndx = null;
    opportunityRecordTypeOptions = [];
    selectedOpportunityRecordTypeValue;
    autoCreateOpportunityValue = false;

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.opportunityRecordTypeOptions = Object.values(data.recordTypeInfos)
                .filter(recordType => recordType.name !== 'Master' && recordType.available)
                .map(recordType => ({ 
                    label: recordType.name, 
                    value: recordType.recordTypeId
                }));
                if(this.accountData.opportunityRecordTypeId){
                    this.selectedOpportunityRecordTypeValue = this.accountData.opportunityRecordTypeId;                    
                }
                else{
                    this.selectedOpportunityRecordTypeValue = data.defaultRecordTypeId;
                }                
            }
        else if (error) {
            console.error(error);
        }
    }

    //Salutation Picklist values
    @wire(getPicklistValues, {
        recordTypeId: MASTER_CONTACT_RECORD_TYPE_ID,
        fieldApiName: SALUTATION_FIELD
    })
    wiredSalutationPicklistValues({ error, data }) {
        if (data) {
            this.salutationOptions = data.values.map(option => {
                return { label: option.label, value: option.value };
            });
        }
        else if (error) {
            console.error(error);
        }
    }

    //Contact Type Picklist values
    @wire(getPicklistValues, {
        recordTypeId: MASTER_CONTACT_RECORD_TYPE_ID,
        fieldApiName: CONTACT_TYPE_FIELD
    })
    wiredContactTypePicklistValues({ error, data }) {
        if (data) {
            this.contactTypeOptions = data.values.map(option => {
                return { label: option.label, value: option.value };
            });
        }
        else if (error) {
            console.error(error);
        }
    }

    get contactSaveLabel(){
        return this.isEdit ? 'Save Contact' : 'Add Contact';
    }

    addContact() {
        let allFieldsFilled = true;
        ALL_REQUIRED_FIELDS.forEach(field => {
            if (!this[field]) {
                allFieldsFilled = false;
            }
        });

        if(!allFieldsFilled){
            this.showToastValidation(ERROR_MESSAGE_REQUIRED_FIELD_MISSING, 'error');
            return;
        }

        let isValid = this.validateContact();

        if(!isValid)
            return;

        if (allFieldsFilled) {
            if(!this.isEdit){
                this.contactRecList.push({
                    salutation: this.salutationValue,
                    contactType: this.contactTypeValue,
                    firstName: this.firstNameValue,
                    title: this.titleValue,
                    lastName: this.lastNameValue,
                    phone: this.phoneValue,
                    email: this.emailValue,
                    mobile: this.mobileValue,
                    rltContact: this.rltContactValue,
                    phoneExtension: this.phoneExtensionValue
                }); 
            }
            else{
                this.contactRecList[this.contactIndex].salutation =  this.salutationValue;
                this.contactRecList[this.contactIndex].contactType = this.contactTypeValue;
                this.contactRecList[this.contactIndex].firstName = this.firstNameValue;
                this.contactRecList[this.contactIndex].title = this.titleValue;
                this.contactRecList[this.contactIndex].lastName = this.lastNameValue;
                this.contactRecList[this.contactIndex].phone = this.phoneValue;
                this.contactRecList[this.contactIndex].email = this.emailValue;
                this.contactRecList[this.contactIndex].mobile = this.mobileValue;
                this.contactRecList[this.contactIndex].rltContact = this.rltContactValue;
                this.contactRecList[this.contactIndex].phoneExtension = this.phoneExtensionValue;               
            }
            this.handleContactChange(); 
            this.hasContactMANI();
        }
        this.hideModalBox(); 
    }

    validateContact() {
        let hasMANIContact = false;
        let hasAPContact = false;
        let hasMAINContact = false;
        let hasACCTContact = false;
        let hasCERTContact = false;
        let index = 0;
        const isMobilePhoneNotBlank = this.mobileValue.trim() !== '';
        const isPhoneNotBlank = this.phoneValue.trim() !== '';
        const isMobilePhoneLengthValid = this.mobileValue.length > 14 || this.mobileValue.length < 10;
        const isPhoneLengthValid = this.phoneValue.length > 14 || this.phoneValue.length < 10;
        const isValidMobile = !this.mobileValue || /^[0-9,()\s-]*$/.test(this.mobileValue);
        const isValidPhone = !this.phoneValue || /^[0-9,()\s-]*$/.test(this.phoneValue);
        const invalidEmailPattern = SPECIAL_EMAIL_REGEX.some(term => this.emailValue.includes(term));
        const checkDuplicateContact = this.contactRecList.some(contact => contact.email === this.emailValue);

        for (let contactObj of this.contactRecList) {
            if (this.contactIndex == null || index != this.contactIndex) {
                if(contactObj.contactType.indexOf('MANI') !== -1){
                    hasMANIContact = true;
                }
                if(contactObj.contactType.indexOf('MAIN') !== -1){
                    hasMAINContact = true;
                }
                if(contactObj.contactType.indexOf('AP') !== -1){
                    hasAPContact = true;
                }
                if(contactObj.contactType.indexOf('ACCT') !== -1){
                    hasACCTContact = true;
                }
                if(contactObj.contactType.indexOf('CERT') !== -1){
                    hasCERTContact = true;
                }
            }    
            index++;
        }
    
        switch (true) {
            case (hasMANIContact && this.contactTypeValue.indexOf('MANI') !== -1):
            case (hasMAINContact && this.contactTypeValue.indexOf('MAIN') !== -1):
            case (hasAPContact && this.contactTypeValue.indexOf('AP') !== -1):
            case (hasACCTContact && this.contactTypeValue.indexOf('ACCT') !== -1):
            case (hasCERTContact && this.contactTypeValue.indexOf('CERT') !== -1):
                this.showToastValidation(ERROR_MESSAGE_CONTACT_TYPE_DUPLICATE, 'error');
                return false;
            case !isValidMobile:
                this.showToastValidation(ERROR_MESSAGE_INVALID_CONTACT_MOBILE, 'error');
                return false;
            case !isValidPhone:
                this.showToastValidation(ERROR_MESSAGE_INVALID_CONTACT_PHONE, 'error');
                return false;
            case (isMobilePhoneNotBlank && isMobilePhoneLengthValid) || (isPhoneNotBlank && isPhoneLengthValid):
                this.showToastValidation(ERROR_MESSAGE_MOBILE_PHONE_LENGTH, 'error');
                return false;
            case (!IS_EMAIL_REGEX.test(this.emailValue) || invalidEmailPattern):
                this.showToastValidation(ERROR_MESSAGE_INVALID_EMAIL, 'error');
                return false;
            case checkDuplicateContact:
                this.showToastValidation(DUPLICATE_CONTACT_MESSAGE, 'error');
                return false;            
        }   
        return true;
    }

    hasContactMANI(){
        let hasMANIContact = false;
        for(let contactObj of this.contactRecList){
            if(contactObj.contactType.indexOf('MANI') != -1){
                hasMANIContact = true;
                break;
            }
        }   
        this.isMANIContact = hasMANIContact;
        return hasMANIContact;
    }

    connectedCallback(){
        if(this.accountData){
            if(this.accountData.contacts && this.accountData.contacts.length > 0){
                this.contactRecList = JSON.parse(JSON.stringify(this.accountData.contacts));
                this.hasContactMANI();
            }
            else
            this.contactRecList = [];
            this.maniStreetValue = this.accountData.manifestAddress1;
            this.maniAddress2Value = this.accountData.manifestAddress2;
            this.maniCityValue = this.accountData.manifestLocality1;
            this.maniStateValue = this.accountData.manifestRegionCode;
            this.maniPostalCodeValue = this.accountData.manifestPostalCode;
            this.maniCountryValue = this.accountData.manifestCountryCode;
            this.maniSameAsCorpValue = this.accountData.manifestAddressSameAsCorp;
            if (this.maniSameAsCorpValue) {
                this.isDisabled = true;             
            }
            this.autoCreateOpportunityValue = this.accountData.autoCreateOpportunity;
        }
    }

    handleAutoCreateOpportunityChange(event) {
        this.autoCreateOpportunityValue = event.target.checked;       
    }

    handleOpportunityRecordTypeChange(event){
        this.selectedOpportunityRecordTypeValue = event.detail.value;
    }

    handleSalutationChange(event){
        this.salutationValue = event.target.value;
    }

    handleContactTypeChange(event){
        this.contactTypeValue = event.target.value;
    }

    handleFirstNameChange(event){
        this.firstNameValue = event.target.value;
    }

    handleTitleChange(event){
        this.titleValue = event.target.value;
    }

    handleLastNameChange(event){
        this.lastNameValue = event.target.value;
    }

    handlePhoneChange(event){
        this.phoneValue = event.target.value;
    }

    handleEmailChange(event){
        this.emailValue = event.target.value;
    }

    handlePhoneExtChange(event){
        this.phoneExtensionValue = event.target.value;
    }

    handleMobileChange(event){
        this.mobileValue = event.target.value;
    }

    handleRLTContactChange(event){
        this.rltContactValue = event.target.checked;
    }

    handleManiStreetChange(event){
        this.maniStreetValue = event.target.value;
    }

    handlemaniAddress2Change(event){
        this.maniAddress2Value = event.target.value;
    }

    handleManiCityChange(event){
        this.maniCityValue = event.target.value;
    }

    handleManiStateChange(event){
        this.maniStateValue = event.target.value;
    }

    handleManiPostalCodeChange(event){
        this.maniPostalCodeValue = event.target.value;
    }

    handleManiCountryChange(event){
        this.maniCountryValue = event.target.value;
    }
    
    handleContactChange(){
        let hasMAINContact = false;
        let contactRec;
        for(let contactObj of this.contactRecList){
            if(contactObj.contactType.indexOf('MAIN') != -1){
                hasMAINContact = true;
                contactRec = contactObj;
                break;
            }
        }
        this.dispatchEvent(new CustomEvent('contactchange', {
            detail: {
                'isMainContact': hasMAINContact,
                'contactObj': contactRec
            }
        }))
    }

    handleManiAddressChange(event){
        this.isDisabled = event.target.checked;
        this.maniSameAsCorpValue = event.target.checked;
        if(this.isDisabled && this.accountData && this.accountData.corporateAddress){
            this.maniStreetValue = this.accountData.corporateAddress.shippingStreet;
            this.maniCityValue = this.accountData.corporateAddress.shippingCity;
            this.maniStateValue = this.accountData.corporateAddress.shippingState;
            this.maniPostalCodeValue = this.accountData.corporateAddress.shippingPostalCode;
            this.maniCountryValue = this.accountData.corporateAddress.shippingCountry;
        }
        else {
            this.maniStreetValue = '';
            this.maniCityValue = '';
            this.maniStateValue = '';
            this.maniPostalCodeValue = '';
            this.maniCountryValue = '';
        }
    }

    //Save Accounts
    async saveMultipleAccounts() {
        let result = await saveAccounts({ accountList: this.contactRecList })        
        this.message = result;
        this.error;
        this.contactRecList.forEach(function (item) {
            item.name = '';
            item.industry = '';
            item.phone = '';
        });

        if (this.message) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Accounts Created!',
                    variant: 'success',
                }),
            );
        }
    }

    editRow(event){
        let contactIdx = parseInt(event.target.id.split('-')[0]);
        this.salutationValue = this.contactRecList[contactIdx].salutation;
        this.contactTypeValue = this.contactRecList[contactIdx].contactType;
        this.firstNameValue = this.contactRecList[contactIdx].firstName;
        this.titleValue = this.contactRecList[contactIdx].title;
        this.lastNameValue = this.contactRecList[contactIdx].lastName;
        this.phoneValue = this.contactRecList[contactIdx].phone;
        this.emailValue = this.contactRecList[contactIdx].email;
        this.mobileValue = this.contactRecList[contactIdx].mobile;
        this.rltContactValue = this.contactRecList[contactIdx].rltContact;
        this.phoneExtensionValue = this.contactRecList[contactIdx].phoneExtension;
        this.isShowModal = true;
        this.isEdit = true;
        this.contactIndex = contactIdx;
    }

    removeRow(event){
        if (this.contactRecList.length >= 1) {
            let tempArray = [];
            let index = parseInt(event.target.id.split('-')[0])
            for(let  i = 0; i < this.contactRecList.length; i++){
                if(i != index){
                    tempArray.push(this.contactRecList[i]);
                }
            }
            this.contactRecList = tempArray;
            this.keyIndex - 1;
        }

        this.handleContactChange();
        if(!this.hasContactMANI()){
            this.maniStreetValue = '';
            this.maniAddress2Value = '';
            this.maniCityValue = '';
            this.maniStateValue = '';
            this.maniPostalCodeValue = '';
            this.maniCountryValue = '';
            this.maniSameAsCorpValue = false;
        }
    }

    @api handlePreviousClick(){
        const selectedEvent = new CustomEvent("contactvaluechangeonprevious", {
            detail: {
                'contacts':  this.contactRecList,
                manifestAddressSameAsCorp: this.maniSameAsCorpValue,
                manifestAddress1: this.maniStreetValue,
                manifestLocality1: this.maniCityValue,
                manifestRegionCode: this.maniStateValue,
                manifestPostalCode: this.maniPostalCodeValue,
                manifestCountryCode: this.maniCountryValue,
                manifestAddress2: this.maniAddress2Value,
                autoCreateOpportunity: this.autoCreateOpportunityValue,
                opportunityRecordTypeId: this.selectedOpportunityRecordTypeValue
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    @api 
    async handleNextClick(isCreateWinId){
		if(isCreateWinId){
        if((this.accountData.parentRecordTypeName == 'Customer' || this.accountData.parentRecordTypeName == 'Broker') && !this.accountData.parentWINId){
                this.showToastValidation(ERROR_MESSAGE_PARENT_WINID_REQUIRED, 'error');
                return;
            }
        }
        let hasMANITypeContact = false;
        if(this.contactRecList){
            for(let contactObj of this.contactRecList){
                if(contactObj.contactType.indexOf('MANI') != -1){
                    hasMANITypeContact = true;
                    break;
                }
            }
        }
      
        if(hasMANITypeContact){
            if(
                !(this.maniStreetValue
                && this.maniCityValue 
                && this.maniStateValue 
                && this.maniPostalCodeValue 
                && this.maniCountryValue) 
            ){
                this.showToastValidation(ERROR_MESSAGE_MANI_REQUIRED, 'error');
                return;
            }
            else if(this.maniCountryValue === 'US' && !ZIP_CODE_PATTERN.test(this.maniPostalCodeValue)){
                this.showToastValidation(ERROR_MESSAGE_INVALID_MANI_ZIPCODE,'error');
                return;
            }
                
            const results = await checkManiAddressinZipMaster({
                maniCountry: this.maniCountryValue,
                maniState: this.maniStateValue,
                maniCity: this.maniCityValue,
                maniPostalCode: this.maniPostalCodeValue
            });           
            if (results.status === 'Error') {
                this.showToastValidation(results.message, 'error');
                return;
            }
        } 

        if(this.autoCreateOpportunityValue && !this.selectedOpportunityRecordTypeValue){
            this.showToastValidation(ERROR_MESSAGE_OPPORTUNITY_RT_REQUIRED, 'error');
            return;
        }

        let result;
        if(!isCreateWinId){
            result = await LightningConfirm.open({
                label: CONFIRM_ACCOUNT_SAVE_AND_CLOSE,
                theme: 'warning',
            });
            
        }

        if (result || isCreateWinId) {
            this.contactData.contacts = this.contactRecList;
            let selectedEvent = new CustomEvent("contactvaluechange", {
                detail: {
                    'contacts':  this.contactRecList,
                    manifestAddressSameAsCorp: this.maniSameAsCorpValue,
                    manifestAddress1: this.maniStreetValue,
                    manifestLocality1: this.maniCityValue,
                    manifestRegionCode: this.maniStateValue,
                    manifestPostalCode: this.maniPostalCodeValue,
                    manifestCountryCode: this.maniCountryValue,
                    manifestAddress2: this.maniAddress2Value,
                    autoCreateOpportunity: this.autoCreateOpportunityValue,
                    opportunityRecordTypeId: this.selectedOpportunityRecordTypeValue
                }
            });
            this.dispatchEvent(selectedEvent);    
        }
    }

    showModalBox() {
        this.isShowModal = true;
        this.salutationValue = '';
        this.contactTypeValue = '';
        this.firstNameValue = '';
        this.titleValue = '';
        this.lastNameValue = '';
        this.phoneValue = '';
        this.emailValue = '';
        this.mobileValue = '';
        this.rltContactValue = false;
        this.phoneExtensionValue = '';

        let hasMAINContact=false;
        for (let contactObj of this.contactRecList) {
            if(contactObj.contactType.indexOf('MAIN') !== -1){
                hasMAINContact = true;
                break;
            }
        }
        if(!hasMAINContact){
            this.contactTypeValue = ['MAIN'];
        }
        
    }
    hideModalBox() {
        this.isShowModal = false;
        this.isEdit = false;
        this.contactIndex = null;
    }

    showToastValidation(message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                message: message,
                variant: variant,
            }),
        );
    }   
}