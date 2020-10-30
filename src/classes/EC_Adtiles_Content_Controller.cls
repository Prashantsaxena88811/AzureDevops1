/*********************************************************************************
Class Name      : EC_Adtiles_Content_Controller
Description     : This class is used as the handler for adtiles Home page lightning component
Created By      : EDC
Created Date    : 12-08-2019
Modification Log:
---------------------------------------------------------------------------------- 
Developer                 Date                   Description
----------------------------------------------------------------------------------            
EDC                  12-08-2019          		 Initial Version 
*********************************************************************************/
public without sharing class EC_Adtiles_Content_Controller {
	@AuraEnabled
    public static List<EC_Division_Marketing_Content__c> getAdTileContents() { 
        List<EC_Division_Marketing_Content__c> adTileContents= new List<EC_Division_Marketing_Content__c>(); 
        String usrDivision= '';
        User loggedInUser = [Select Id, contact.account.EC_Division__c, User_Type__c FROM User WHERE Id =:UserInfo.getUserId()];
        if(loggedInUser.User_Type__c==null || loggedInUser.User_Type__c.EqualsIgnoreCase('external')){
            usrDivision= loggedInUser.contact.account.EC_Division__c;
        } else {
            Contact currContact = [Select Id,account.EC_Division__c FROM Contact WHERE EC_SalesRep_User__c=:UserInfo.getUserId() limit 1];
            if(currContact != null && currContact.account.EC_Division__c != null) {
                usrDivision = currContact.account.EC_Division__c;
            }
        }
   		adTileContents=[Select Id ,EC_Content__c,Image_CTA_URL__c,Open_In_NewTab__c,Body_Text__c,Tile_CTA__c from EC_Division_Marketing_Content__c where EC_Division__c=: usrDivision and Active__c=TRUE order by Sequence__c];
        if(!adTileContents.isempty()){
            system.debug('adTileContents'+ adTileContents);
            return adTileContents;
        }
        return null;
    }
}