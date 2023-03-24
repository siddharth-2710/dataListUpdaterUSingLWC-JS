import { LightningElement,api } from 'lwc';
import getContactRoles from '@salesforce/apex/DataRetriver.getContactRoles';
import getDivisionPicklistValues from '@salesforce/apex/DataRetriver.getDivisionPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveContactRoles from '@salesforce/apex/DataRetriver.saveContactRoles';
export default class DataChanger extends LightningElement {
    @api recordId;
    showButton = true;
    contactRolesData;
    errors;
    options;
    toUpdateContactRoles=[];

    showContactRoleData(){
        getContactRoles({oppId:this.recordId})
        .then((result)=>{
            this.contactRolesData = result;
            this.errors = undefined;
            this.showButton = false;
        })
        .catch((error)=>{
            this.errors = error;
            this.contactRolesData = undefined;
            console.error(error);
        });
        getDivisionPicklistValues()
        .then((result)=>{
            var items = [];
            for (var i = 0; i < result.length; i++) {
            var item = {
                "label": result[i],
                "value": result[i]
            };
            items.push(item);
        }
            this.options = items;
            this.errors = undefined;
        })
        .catch((error)=>{
            this.errors = error;
            this.options = undefined;
            console.error(error);
        });
    }

    handleChange(event){
        let contactRole = {};
        contactRole.recordid = event.target.dataset.recordid;
        contactRole.role = event.target.value;
        this.toUpdateContactRoles.push(contactRole);
        console.log(this.toUpdateContactRoles[0]);
    }

    handleSave(){
        saveContactRoles({jSONData:(JSON.stringify(this.toUpdateContactRoles)),dataSize:this.toUpdateContactRoles.length,oppId:this.recordId})
        .then((result)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Role Updated Succesfully',
                message: `The contact roles for Opportunity ${this.recordId} has been updated successfully`,
                variant: 'success'
            }));
            this.showButton = true;
        })
        .catch((error)=>{
            console.error(error);
        })
    }
}