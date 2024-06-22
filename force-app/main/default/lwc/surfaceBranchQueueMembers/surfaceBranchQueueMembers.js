import { LightningElement, api } from 'lwc';
import getSurfaceBranchList from '@salesforce/apex/SurfaceBranchListOnBranchAccount.getSurfaceBranchListOnBranchAccount';
const columns = [
    {
        label: 'Name',
        fieldName: 'Id',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_blank'
        }
    },
    { label: 'Email', fieldName: 'Email' },
    { label: 'Phone', fieldName: 'Phone' },
    
];
export default class SurfaceBranchQueueMembers extends LightningElement {
    @api recordId;
    surfaceBranchList = {};
    columns = columns;
    async connectedCallback() {
        try {
            this.surfaceBranchList  = await getSurfaceBranchList({ accountId: this.recordId });
            this.surfaceBranchList.forEach(function(record) {
                record.Id = '/' + record.Id;
             
            });
        }
        catch (error) {
            console.log(error);
        }
    }
    get isSurfaceBranchListEmpty()
    {
        return  Object.keys(this.surfaceBranchList).length != 0;
        
    }
}