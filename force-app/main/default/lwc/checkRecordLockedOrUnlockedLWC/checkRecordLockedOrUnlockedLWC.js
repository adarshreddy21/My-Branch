import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import {subscribe,unsubscribe} from 'lightning/empApi';
import IS_RECORD_LOCKED_FIELD from "@salesforce/schema/Account.Is_Record_Locked__c";
import WINID from "@salesforce/schema/Account.WIN_ID__c";
import STATUS from "@salesforce/schema/Account.Status__c";
import Inactivate_Reactivate_In_Progress__c from "@salesforce/schema/Account.Inactivate_Reactivate_In_Progress__c";
export default class CheckRecordLockedOrUnlockedLWC extends LightningElement {
    @api recordId;
    channelName = '/event/AccountSyncNotification__e';
    winId;
    isSubscribed=false;
    isRecordLocked;
    subscription = {};
    @wire(getRecord, { recordId: '$recordId', fields: [IS_RECORD_LOCKED_FIELD, WINID, STATUS, Inactivate_Reactivate_In_Progress__c] })
    wiredRecord({ error, data }) {
        if(data && data.fields){
            this.winId= data.fields.WIN_ID__c.value
            if(data.fields.Is_Record_Locked__c){
               this.isRecordLocked = data.fields.Is_Record_Locked__c.value;
               if(!this.isSubscribed && this.isRecordLocked && this.winId && data.fields.Status__c.value==='Active' && !data.fields.Inactivate_Reactivate_In_Progress__c.value){
                    this.handleSubscribe();
               }
            }
        }
    }

    handleSubscribe() {
        const self = this;
        self.isSubscribed = true;
        const messageCallback = function (response) {
            let obj = JSON.parse(JSON.stringify(response));
           // console.log('subscriber hit');
            if(obj.data.payload.WinId__c===self.winId){
                self.isRecordLocked = false;
            }
            if(!self.isRecordLocked){
                self.handleUnsubscribe();
            }
        };
       subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        });
        setTimeout(function(){self.handleUnsubscribe();},10000);
    }

    // Handles unsubscribe button click

    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        //console.log('Entering unsubscription-->'+this.subscription);
        if(this.subscription && this.isSubscribed){
            unsubscribe(this.subscription, (response) => {
                 //console.log('unsubscription response-->'+response);
            });
        }
        this.isSubscribed = false;
    }
}