/* Class Name       :EC_PunchoutUtility
* Description       :Utility for Encryption and Decryption
* Created By        :Ayusha Patnaik
* Created On        :06-10-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Ayusha Patnaik        06-10-2019                                  Util methods for Punchout
*
*/

global class EC_PunchoutUtility {

       /***************************************************************************************************************************************
Method Name : encryptUserCredentials
Description : to encrypt ukey and pkey
Parameter   : String, STring
Return type : Map<String,String>
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    global static Map<String,String> encryptUserCredentials(String username, String password){
        Blob encUser = Blob.valueOf(username);
        Blob encPass = Blob.valueOf(password);
        EC_PunchoutSecretKey__c settings = EC_PunchoutSecretKey__c.getOrgDefaults();
        String keyCustom;
        Blob key;
        if(String.isEmpty(settings.EC_EncryptionKey__c)){
            key = Crypto.generateAesKey(256);
            String cryptoKey = EncodingUtil.base64Encode(key);
            settings.EC_EncryptionKey__c = cryptoKey;
            upsert settings;
        }
        else{
            keyCustom = settings.EC_EncryptionKey__c;
            key =  EncodingUtil.base64Decode(keyCustom);

        }
        Blob encryptedUserName = Crypto.encryptWithManagedIV('AES256', key, encUser);
        String encryptedUserNameString = EncodingUtil.base64Encode(encryptedUserName);
        Blob encryptedPassword = Crypto.encryptWithManagedIV('AES256', key, encPass);
        String encryptedPasswordString = EncodingUtil.base64Encode(encryptedPassword);
        Map<String,String> encryptedCredsMap = new Map<String,String>();
        encryptedCredsMap.put('encryptedUserName', encryptedUserNameString);
        encryptedCredsMap.put('encryptedPassword', encryptedPasswordString);
        return encryptedCredsMap;
    }

    /***************************************************************************************************************************************
Method Name : decryptUserCredentials
Description : to decrypt ukey and pkey
Parameter   : String, STring
Return type : Map<String,String>
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    global static Map<String,String> decryptUserCredentials(String username, String password){
        Map<String,String> decryptedCredsMap = new Map<String,String>();
        try{
            Blob decUser = EncodingUtil.base64Decode(username.replaceAll(' ', '+'));
            Blob decPass =  EncodingUtil.base64Decode(password.replaceAll(' ', '+'));
            EC_PunchoutSecretKey__c settings = EC_PunchoutSecretKey__c.getOrgDefaults();
            String key = settings.EC_EncryptionKey__c;
            Blob cryptoKey = EncodingUtil.base64Decode(key);
            Blob decryptedUserName = Crypto.decryptWithManagedIV('AES256', cryptoKey, decUser);
            String decryptedUserNameString = decryptedUserName.toString();
            Blob decryptedPassword = Crypto.decryptWithManagedIV('AES256', cryptoKey, decPass);
            String decryptedPasswordString = decryptedPassword.toString();

            decryptedCredsMap.put('decryptedUserName', decryptedUserNameString);
            decryptedCredsMap.put('decryptedPassword', decryptedPasswordString);
            return decryptedCredsMap;
        }
        catch(Exception e)
        {
            decryptedCredsMap.put('decryptedUserName', '');
            decryptedCredsMap.put('decryptedPassword', '');
            return decryptedCredsMap;


        }

    }

}