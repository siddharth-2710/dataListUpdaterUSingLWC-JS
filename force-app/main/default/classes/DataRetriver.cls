public with sharing class DataRetriver {
    public class ContactRoleWrapper{
        public String recordid;
        public String role;
    }
    @AuraEnabled(cacheable = true)
    public static List<OpportunityContactRole> getContactRoles(String oppId){
        try {
            return [SELECT ID,Role,Contact.Name,OpportunityId From OpportunityContactRole Where OpportunityId=:oppId WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled 
    public static List<String> getDivisionPicklistValues()
    {
        List<string> picklist = new List<String>();
         Schema.DescribeFieldResult fieldResult = OpportunityContactRole.Role.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for(Schema.PicklistEntry s:ple){
             
             picklist.add(s.getLabel());
         }
        return picklist;
    }
    @AuraEnabled
    public static void saveContactRoles(String jSONData,Integer dataSize,String oppId){
        try {
            List<OpportunityContactRole> toUpdateContactRoles = new List<OpportunityContactRole>();
            Map<Id,OpportunityContactRole> contactRoleRecordsMap = new Map<Id,OpportunityContactRole>([SELECT ID,Role From OpportunityContactRole Where OpportunityId=:oppId WITH SECURITY_ENFORCED]);
            List<ContactRoleWrapper> conRoleList = new List<ContactRoleWrapper>();
            conRoleList = (List<ContactRoleWrapper>) JSON.deserialize(jSONData,List<ContactRoleWrapper>.class); 
            OpportunityContactRole oppContactRole = new OpportunityContactRole();
            for(Integer i=0;i<dataSize;i++){
                oppContactRole = contactRoleRecordsMap.get(conRoleList[i].recordid);
                if(!(oppContactRole.role==conRoleList[i].role)){
                    oppContactRole.role = conRoleList[i].role;
                    toUpdateContactRoles.add(oppContactRole);
                }
            }
            update as user toUpdateContactRoles;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}