/*******************************************************************************************************************
* Apex Class Name     : EC_RoleMuleSoftWrapper
* Created Date        : 24 July 2019
* Description         : wrapper constitues the request body for cdm callout
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan                  24/07/2019              Original Version
*************************************************************************************************************************/
public class EC_RoleMuleSoftWrapper {
    public List<String> roleToAdd{get;set;}
    public String sourceSystemCode{get;set;}
    public Integer userKey{get; set;}
    public List<String> roleToRemove{get;set;}

    /***************************************************************************************************************************************
Method Name : EC_RoleMuleSoftWrapper
Description : to assign values in variables to form request JSON
Parameter   : List<String>,List<String>,Integer,String
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public EC_RoleMuleSoftWrapper( List<String> prviousRole,List<String> usrRole,Integer ukey,String sSystemCode){
        roleToAdd = usrRole;
        sourceSystemCode = sSystemCode;
        userKey = ukey;
        roleToRemove = prviousRole;
    }
}