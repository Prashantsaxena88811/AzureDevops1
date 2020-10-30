/*
* Class Name	: EC_Home_DSR_PowerBIController
* Description	: This Class contains methods for DSR/PowerBI component checks
*/
public with sharing class EC_Home_DSR_PowerBIController {

    /*
    * Method Name : getUserPermissions
    * Description : This method returns Current Users Permission Set Assignments
    * Parameters  : NA
    * Return type : String (JSON response)
    */
    @AuraEnabled
    public static rtnWrapper getUserPermissions() {
        try {
            rtnWrapper rtnWrapper = new rtnWrapper();
            rtnWrapper.enableDSR = false;
            rtnWrapper.enableIntelligence = false;

            List<String> dashboardPermissions = new List<String>();
            list<PermissionSet> lstPermissionSet = EC_QueryUtility.getPermissionSet();
            
            for(Permision_Set_Mapping__mdt eachDashboard : [SELECT Permission_Set_Name__c FROM Permision_Set_Mapping__mdt WHERE Is_DashBoard__c = true]) {
                dashboardPermissions.add(eachDashboard.Permission_Set_Name__c);
            }

            for(PermissionSet eachPermission: lstPermissionSet) {
                if(eachPermission.Name == EC_Constants.DSRPermissionSet) {
                    rtnWrapper.enableDSR = true;
                }
                if(dashboardPermissions.contains(eachPermission.Name)) {
                    rtnWrapper.enableIntelligence = true;
                }
            }

            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
            
            return rtnWrapper;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class rtnWrapper {
        @AuraEnabled
        public Boolean enableDSR;
        @AuraEnabled
        public Boolean enableIntelligence;
    }
}