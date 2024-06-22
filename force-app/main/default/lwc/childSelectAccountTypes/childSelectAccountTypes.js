import { LightningElement, api, wire} from 'lwc';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

const RECORD_TYPES_TOBE_HIDDEN = ['Master', 'Broker Location', 'Corporate - Retired','Customer Location',
                                    'Distributor Location','Prospect Gen'];
                                    
const RECORD_TYPE_DESCRIPTIONS = {
    'Branch':'All Clean Harbors Branches',
    'Broker':'All Clean Harbors Brokers',
    'Chain':'All Clean Harbors Chains',
    'CLH Competitor':'All Clean Harbors CLH Competitors',
    'Corporate':'All Clean Harbor Corporate Accounts',
    'Customer':'All Clean Harbors Customers',
    'Customer Chain':'Customer Chain',
    'Distributor':'All Clean Harbors Distributors',
    'Facility':'',
    'Growth Budget':'Record type is leveraged to report off sales reps growth budgets',
    'HR Recruiting Partners':'HR Partnership organizations used to recruit from their talent pools',
    'Key Account':'All Clean Harbor Key Accounts',
    'RFOO':'All RFO Outlets',
    'UMO Competitor':'All Clean Harbors UMO Competitors',
    'Prospect' : ''
}
const RECORD_TYPE_ICONS = {
    'Branch': 'custom:custom98',
    'Broker': 'standard:your_account',
    'Chain': 'standard:custody_chain_entry',
    'CLH Competitor': 'standard:incident',
    'Customer Chain': 'standard:customer_workspace',
    'Corporate': 'standard:delegated_account',
    'Customer': 'standard:customer',
    'Distributor': 'standard:outcome',
    'Facility': 'standard:recycle_bin',
    'Growth Budget': 'standard:budget_allocation',
    'HR Recruiting Partners': 'action:new_group',
    'Key Account': 'custom:custom76',
    'RFOO': 'standard:filter_criteria',
    'UMO Competitor': 'standard:incident',
    'Prospect':'standard:lead'
}

export default class ChildSelectAccountTypes extends LightningElement {
    @api accountData;
    accountRecordTypes = [];
   
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.accountRecordTypes = Object.values(data.recordTypeInfos)
                .filter(recordType => recordType.name !== 'Master' && recordType.available && !RECORD_TYPES_TOBE_HIDDEN.includes(recordType.name))
                .map(recordType => ({ 
                    id: recordType.recordTypeId,
                    name: recordType.name,
                    iconName : RECORD_TYPE_ICONS[recordType.name],
                    description: RECORD_TYPE_DESCRIPTIONS[recordType.name]
                })).sort((a, b) => a.name.localeCompare(b.name));
            if(this.accountRecordTypes.length === 1){
                const singleAccountRecordTypeDetail = {
                    recordTypeId: this.accountRecordTypes[0].id,
                    recordTypeName: this.accountRecordTypes[0].name
                };        
                const selectedEvent = new CustomEvent("singlerecordtypeaccess", {
                    detail: singleAccountRecordTypeDetail
                });
                this.dispatchEvent(selectedEvent);
               
            } 
            const selectedEventForVisibility = new CustomEvent("showmultipleaccounttypesaction", {
                detail: this.accountRecordTypes.length > 1
            });
            this.dispatchEvent(selectedEventForVisibility);                     
        }
        else if (error) {
            console.error(error);
        }
    }
    
    @api
    get showAccountRecordTypeSelection(){
        return this.accountRecordTypes.length > 1;
    }
    handleAccountRecordTypeClickIcon(event){
        event.preventDefault();
        const recordId = event.currentTarget.dataset.value;
        const selectedAccountRecordType = this.accountRecordTypes.find(recordType => recordType.id === recordId);
        
        let selectedAccountRecordTypeDetail = {
            recordTypeId: selectedAccountRecordType.id,
            recordTypeName: selectedAccountRecordType.name,
        };        
        const selectedEvent = new CustomEvent("accountsvaluechange", {
            detail: selectedAccountRecordTypeDetail
        });
        this.dispatchEvent(selectedEvent);
    }

    handleAccountRecordTypeClick(event){
        const selectedAccountRecordType = this.accountRecordTypes.find(recordType => recordType.name === event.target.textContent);
        const selectedAccountRecordTypeId = selectedAccountRecordType.id;
        
        let selectedAccountRecordTypeDetail = {
            recordTypeId: selectedAccountRecordTypeId,
            recordTypeName: selectedAccountRecordType.name,
        };        
        const selectedEvent = new CustomEvent("accountsvaluechange", {
            detail: selectedAccountRecordTypeDetail
        });
        this.dispatchEvent(selectedEvent);
    }
}