/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 07-20-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-06-2022   Suresh Beniwal   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';

export default class CustomPagination extends LightningElement {
    currentPage =1
    totalRecords
    @api recordSize;
    totalPage = 0
    get records(){
        return this.visibleRecords
    }
    @api 
    set records(data){
        if(data){ 
            this.totalRecords = data;
            this.currentPage = 1;
            this.recordSize = Number(this.recordSize);
            this.totalPage = Math.ceil(data.length/this.recordSize);
            this.updateRecords();
        }
    }

    get disablePrevious(){ 
        return this.currentPage<=1;
    }
    get disableNext(){ 
        return this.currentPage>=this.totalPage;
    }
    previousHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1;
            this.updateRecords();
        }
    }
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1;
            this.updateRecords();
        }
    }
    updateRecords(){ 
        const start = (this.currentPage-1)*this.recordSize;
        const end = this.recordSize*this.currentPage
        this.visibleRecords = this.totalRecords.slice(start, end);
        this.dispatchEvent(new CustomEvent('update',{ 
            detail:{ 
                records:this.visibleRecords
            }
        }));
    }

    get showPagination() {
        return this.totalPage > 1;
    }
}