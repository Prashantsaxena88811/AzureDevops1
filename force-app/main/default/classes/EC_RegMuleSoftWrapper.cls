/*******************************************************************************************************************
* Apex Class Name     : EC_RegMuleSoftWrapper
* Created Date        : 18 July 2019
* Description         : Generic Class to make an api call to external system.
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Ayusha Patnaik                  10/06/2019              Original Version
*************************************************************************************************************************/
public class EC_RegMuleSoftWrapper {

    public String accountNo{get;set;}
    public String salesRepEmail{get;set;}
    public String userEmail{get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String sourceSystemCode{get;set;}
    public String userKey{get; set;}
    public String federationId{get;set;}
    public String redemptionUrl{get;set;}
    public String isValid{get;set;}
    public String responseCode{get;set;}
    public String accountKey{get;set;}

    /***************************************************************************************************************************************
Method Name : EC_RegMuleSoftWrapper
Description : to assign values in variables to form request JSON
Parameter   : String
Return type : void
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    public EC_RegMuleSoftWrapper(String accNumber, String salesRepMail, String uEmail, String fname, String lname, String sSystemCode, String uKey, String fedId, String redURL)
    {
        accountNo = accNumber;
        salesRepEmail = salesRepMail;
        userEmail = uEmail;
        firstName = fname;
        lastName = lname;
        sourceSystemCode = sSystemCode;
        userKey = ukey;
        federationId = fedId;
        redemptionUrl = redURL;
    }
    /***************************************************************************************************************************************
Method Name : EC_RegMuleSoftWrapper
Description : to assign values in variables to form request JSON
Parameter   : List<Id>
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public EC_RegMuleSoftWrapper(String accNumber, String salesRepMail, String uEmail, String fname, String lname, String sSystemCode)
    {
        accountNo = accNumber;
        salesRepEmail = salesRepMail;
        userEmail = uEmail;
        firstName = fname;
        lastName = lname;
        sourceSystemCode = sSystemCode;
    }

    /***************************************************************************************************************************************
Method Name : EC_RegMuleSoftWrapper
Description : to assign values in variables to form request JSON
Parameter   : List<Id>
Return type : void
Author      : Raghav Sharma
*************************************************************************************************************************************/

    public EC_RegMuleSoftWrapper(String accNumber, String salesRepMail, String ukey)
    {
        accountNo = accNumber;
        salesRepEmail = salesRepMail;
        userKey = ukey;
    }

}