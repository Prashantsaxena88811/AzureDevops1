/* Class Name       :EC_PunchoutUtilityTest
* Description       :Test Class for EC_PunchoutUtilityTest
* Created By        :Ayusha Patnaik
* Created On        :06-10-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Ayusha Patnaik        06-10-2019                                  Test Class for EC_PunchoutUtilityTest
*
*/

@isTest
public class EC_PunchoutUtilityTest {
@isTest
public static void encryptUserCredentialsTest(){
EC_PunchoutSecretKey__c secretKeySettings = new EC_PunchoutSecretKey__c();
secretKeySettings.EC_EncryptionKey__c = 'uC4JcjLhNwSIHNhG987SXNJd2gY9E2BQ1xlpZ0u5NJ1=';
secretKeySettings.EC_Secret_Key__c = 'Secret';
secretKeySettings.Name = 'Secret';

insert secretKeySettings;
Map<String,String> encryptedMap = new Map<String,String>();
encryptedMap = EC_PunchoutUtility.encryptUserCredentials('user@test.com', 'testpassword');
EC_PunchoutUtility.decryptUserCredentials(encryptedMap.get('encryptedUserName'), encryptedMap.get('encryptedPassword'));

}

/***************************************************************************************************************************************
Method Name : encryptUserCredentialsWithoutCSTest
Description : to encrypt ukey and pkey
Parameter   : Void
Return type : Void
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

@isTest
public static void encryptUserCredentialsWithoutCSTest(){
EC_PunchoutSecretKey__c secretKeySettings = new EC_PunchoutSecretKey__c();
secretKeySettings.EC_Secret_Key__c = 'Secret';
secretKeySettings.Name = 'Secret';
insert secretKeySettings;
Map<String,String> encryptedMap = new Map<String,String>();
encryptedMap = EC_PunchoutUtility.encryptUserCredentials('user@test.com', 'testpassword');
EC_PunchoutUtility.decryptUserCredentials(encryptedMap.get('encryptedUserName'), encryptedMap.get('encryptedPassword'));

}

/***************************************************************************************************************************************
Method Name : encryptUserCredentialsExceptionest
Description : to decrypt ukey and pkey
Parameter   : Void
Return type : Void
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

@isTest
public static void encryptUserCredentialsExceptionest(){
EC_PunchoutSecretKey__c secretKeySettings = new EC_PunchoutSecretKey__c();
secretKeySettings.EC_Secret_Key__c = 'Secret';
secretKeySettings.Name = 'Secret';
insert secretKeySettings;
EC_PunchoutUtility.decryptUserCredentials('', '');

}
}