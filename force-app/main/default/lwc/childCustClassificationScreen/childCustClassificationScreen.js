import { LightningElement, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACC_SOURCE_FIELD from '@salesforce/schema/Account.AccountSource';
import RANK_FIELD from '@salesforce/schema/Account.Rank__c';
import VERTICAL_FIELD from '@salesforce/schema/Account.Industry_Segment__c';
import CLASS_FIELD from '@salesforce/schema/Account.Class__c';
import SKO_SALES_FIELD from '@salesforce/schema/Account.SKO_Sales_Segment__c';
import TAX_EXEMPTION_FIELD from '@salesforce/schema/Account.Tax_Exemption_Type__c';
import SIC_CODE_DESCRIPTION_FIELD from '@salesforce/schema/Account.SIC_Code_Description__c'; 
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BROKER_GROUP_FIELD from '@salesforce/schema/Account.Broker_Group__c';
import deleteCustomDocument from '@salesforce/apex/GuidedAccountCreateSetup.deleteCustomDocument';

const ACCOUNT_NAME_VALIDATION = 'Please fill out all required fields';
const TAX_FILE_UPLOAD_VALIDATION = 'Tax Document is Mandatory for Tax Exemption';
const ALL_REQUIRED_FIELDS = ['accountSourceValue','classValue','verticalValue','rankValue','taxExemptionValue', 'sicCodeDescriptionValue'];

export default class ChildCustClassificationScreen extends LightningElement {
    @api accountData; 
    showFileUpload = false;
    disableUpload = false;
    uploadedFileName='';
    documentIdValue ='';
    account = [];
    accountSourceOptions = [];
    rankOptions = [];
    taxExemptionOptions = [];
    verticalOptions = [];
    skoSalesSegmentOptions = [];
    classOptions = [];
    sicCodeDescriptionOptions = []; 
    taxExemptionValue;
    readClassOnlyBool = false;
    isSKOSalesFieldEnabled = false;
    showskoSalesSegment = true;
    showBrokerGroupSegment = true;
    isBrokerGroupEnabled = false;
    readSICCodeDescriptionOnlyBool = false;

    constructor() {
        super();
        this.readClassOnlyBool = true;
    }

    connectedCallback() {
        this.getSKOSalesFieldEnabled();
        this.getBrokerGroupFieldEnabled();   
 
        if(this.accountData) {
            this.accountSourceValue = this.accountData.accountSource;
            if(this.accountData.taxExemptionType){
                this.taxExemptionValue = this.accountData.taxExemptionType;
            }            
            this.verticalValue = this.accountData.industrySegment;
            this.skoSalesSegmentValue = this.accountData.skoSalesSegment;
            this.classValue = this.accountData.accountClass;
            this.sicCodeDescriptionValue = this.accountData.sicCodeDescription;
            this.readClassOnlyBool = false;
            this.rankValue = this.accountData.rank; 
            this.brokerGroupValue = this.accountData.brokerGroup;
        }
        if (this.accountData.documentId && this.accountData.documentId != {} && JSON.stringify(this.accountData.documentId) != '{}' && this.accountData.taxExemptionType && this.accountData.taxExemptionType=='Tax Exempt') {
            this.uploadedFileName = this.accountData.taxFileName;
            this.documentIdValue = this.accountData.documentId;
            this.showFileUpload = true;
            this.disableUpload = true;
        }
        else{
            this.showFileUpload = false;
            this.disableUpload = false;
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }
    
    getSKOSalesFieldEnabled() {
        this.isSKOSalesFieldEnabled = (this.accountData.primaryServiceProviderNew === 'SK KPP');
    }

    getBrokerGroupFieldEnabled() {
        this.isBrokerGroupEnabled = (this.accountData.recordTypeName === 'Broker' || this.accountData.recordTypeName === 'Broker Location');
    }

    // Broker Group Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: BROKER_GROUP_FIELD
    })
    wiredBrokerGroupPicklistValues({ error, data }) {
        if (data) {
            this.brokerGroupOptions = [{ label: "--None--", value: null }]; 
            this.brokerGroupOptions.push(...data.values.map(option => {
                return { label: option.label, value: option.value };
            }));
        }
        else if (error) {
            this.showBrokerGroupSegment = false;
            console.error(error);
        }
    }

    // Account Source Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: ACC_SOURCE_FIELD
    })
    wiredAccountSourcePicklistValues({ error, data }) {
        if (data) {
            this.accountSourceOptions = data.values.map(option => {
                return {label: option.label,value: option.value};
            });
        }
        else if (error) {
            console.error(error);
        }
    }

    // Rank Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: RANK_FIELD
    })
    wiredRankPicklistValues({ error, data }) {
        if (data) {
            this.rankOptions = data.values.map(option => {
                return {label: option.label,value: option.value};
            });
        }
        else if (error) {
            console.error(error);
        }
    }

    // Vertical Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: VERTICAL_FIELD
    })
    wiredVerticalPicklistValues({ error, data }) {
        if (data) {
            this.verticalOptions = data.values.map(option => {
                return {label: option.label,value: option.value};
            });
        }
        else if (error) {
            console.error(error);
        }
    }

    // Class Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: CLASS_FIELD 
    })
    wiredClassPicklistValues({ error, data }) {
        if (data) {
            this.classData = data;
            this.classOptions = data.values.map(option => {
                return {label: option.label,value: option.value};
            });
            if(this.accountData) {
                let key = this.classData.controllerValues[this.accountData.industrySegment];
                this.classOptions = this.classData.values.filter(opt => opt.validFor.includes(key));
            }
        }
        else if (error) {
            console.error(error);
        }
    }

    // SIC Code Description Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: SIC_CODE_DESCRIPTION_FIELD
    })
    wiredSICCodeDescriptionPicklistValues({ error, data }) {
        if (data) {
            this.sicCodeDescriptionData = data;
            this.sicCodeDescriptionOptions = data.values.map(option => {
                return {label: option.label, value: option.value};
            });
            if(this.accountData) {
                let key = this.sicCodeDescriptionData.controllerValues[this.accountData.accountClass];
                this.sicCodeDescriptionOptions = this.sicCodeDescriptionData.values.filter(opt => opt.validFor.includes(key));
            }
        }
        else if (error) {
            console.error(error);
        }
    }

    // SKO Sales Segment Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: SKO_SALES_FIELD
    })
    wiredSKOSalesSegmentPicklistValues({ error, data }) {
        if (data) {
            this.skoSalesSegmentOptions = data.values.map(option => {
                return {label: option.label,value: option.value};
            });
        }
        else if (error) {
            this.showskoSalesSegment = false;
            console.error(error);
        }
    }

    // Tax Exemption Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$accountData.recordTypeId', 
        fieldApiName: TAX_EXEMPTION_FIELD
    })
    wiredTaxExemptionPicklistValues({ error, data }) {
        if (data) {
            this.taxExemptionOptions = data.values.map(option => {
                return {label: option.label,value: option.value};
            });

            const taxDefaultValue = data.defaultValue;
            if(taxDefaultValue && !this.taxExemptionValue){
                this.taxExemptionValue = taxDefaultValue.value;
            }
        }
        else if (error) {
            console.error(error);
        }
    }    
    
    handleAccountSourceChange(event){
        this.accountSourceValue = event.target.value;
    }

    handleRankChange(event){
        this.rankValue = event.target.value;
    }

    handletaxExemptionChange(event){
        this.taxExemptionValue = event.target.value;
        if(this.taxExemptionValue== 'Tax Exempt')
        {
            this.showFileUpload = true;
            this.disableUpload = false;
            this.uploadedFileName='';

        }
        else{
            if (this.documentIdValue) {
                this.deleteContentDocumentId();
            }
            this.showFileUpload = false;
        }
    }
   
    async deleteContentDocumentId() {
        try {
            let docId = this.documentIdValue;
            this.documentIdValue='';
            await deleteCustomDocument({ documentId: docId });
            console.log('Deleted Document Sucessfully');
        }
        catch (error) {
            console.log('Error Deleting Document '+ this.documentIdValue);
            this.documentIdValue='';
        }
    }

    handleSKOSalesChange(event){
        this.skoSalesSegmentValue = event.target.value;
    }

    handleBrokerGroupChange(event){
        this.brokerGroupValue = event.target.value;
    }

    handleClassChange(event){
        this.classValue = event.target.value;
        this.bindSICValues();
    }
    bindSICValues(){
        let key = this.sicCodeDescriptionData.controllerValues[this.classValue];
        this.sicCodeDescriptionOptions = this.sicCodeDescriptionData.values.filter(opt => opt.validFor.includes(key));
        if(this.sicCodeDescriptionOptions.length === 1){
            this.sicCodeDescriptionValue = this.sicCodeDescriptionOptions[0].value;
            this.readSICCodeDescriptionOnlyBool = true;
        }
        else{
            this.sicCodeDescriptionValue = null;
            this.readSICCodeDescriptionOnlyBool = false;
        }
    }
    handleVerticalChange(event) {
        this.verticalValue = event.target.value;
        let key = this.classData.controllerValues[event.target.value];
        this.classOptions = this.classData.values.filter(opt => opt.validFor.includes(key));
        // Reset SIC Code Description options when Vertical changes
        this.sicCodeDescriptionOptions = [];
        this.sicCodeDescriptionValue = null;
        this.readSICCodeDescriptionOnlyBool = false;
        if(this.classOptions.length === 1){
            this.classValue = this.classOptions[0].value;
            this.readClassOnlyBool = true;
            this.bindSICValues();
        }
        else{
            this.classValue = null;
            this.readClassOnlyBool = false;
        }
    }

    handleSICCodeDescriptionChange(event) {
        this.sicCodeDescriptionValue = event.target.value;
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.disableUpload = true;
        this.uploadedFileName = uploadedFiles[0].name;
        this.documentIdValue = uploadedFiles[0].documentId;
        let accCustClassificationData =
        {
            documentId : this.documentIdValue
        };
        const selectedEvent = new CustomEvent("documentuploadevent", {
            detail: accCustClassificationData
        }); 
        this.dispatchEvent(selectedEvent);
        
    }

    @api handleNextClick(){
        let allFieldsFilled = true;
        ALL_REQUIRED_FIELDS.forEach(field => {
            if(!this[field]) {
                allFieldsFilled = false;
                this.showToastMethod(ACCOUNT_NAME_VALIDATION,'error');
            }
        });
        if(allFieldsFilled && this.taxExemptionValue === 'Tax Exempt' && !this.documentIdValue)
        {            
            allFieldsFilled = false;
            this.showToastMethod(TAX_FILE_UPLOAD_VALIDATION,'error');                
        }
        if(allFieldsFilled){     
            let accCustClassificationData =
            {
                accountSource: this.accountSourceValue,
                rank: this.rankValue,
                taxExemptionType: this.taxExemptionValue,
                industrySegment: this.verticalValue,
                skoSalesSegment: this.skoSalesSegmentValue,
                accountClass: this.classValue,
                sicCodeDescription: this.sicCodeDescriptionValue,
                taxFileName : this.uploadedFileName,
                documentId : this.documentIdValue,
                brokerGroup: this.brokerGroupValue
            };
            const selectedEvent = new CustomEvent("accountsvaluechange", {
                detail: accCustClassificationData
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    handleDeleteTaxDocClick(event) {
        this.disableUpload = false;
        this.uploadedFileName = '';
        if (this.documentIdValue) {
            this.deleteContentDocumentId();
        }
    }

    get showDelete() {
        return this.uploadedFileName !== '';
    }

    showToastMethod(message,variant) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}