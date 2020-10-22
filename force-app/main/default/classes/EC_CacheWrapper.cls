/* Class Name       :EC_CacheWrapper
 * Description      :wrapper class used in EC_CacheController
 * Created By       :Shivam Vats
 * Created On       :07-05-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Shivam Vats         07-05-2019                                   wrapper class used in EC_CacheController
 * 
 */
global class EC_CacheWrapper {
    
    @auraEnabled
    public string userFirstName;
    @auraEnabled
    public string userLastName;
    @auraEnabled
    public string userLocaleStr;
    @auraEnabled
    public List<PermissionSet> lstPermisssionSet;
     @auraEnabled
    public string userProfile;
    @auraEnabled
    public string userRole;
    @auraEnabled
    public Map<String, boolean> usrPermissionMap;
    @auraEnabled
    public List<string> contactAccList;
    @auraEnabled
    public Map<String, List<String>> accGrpPriceListMap;
    @auraEnabled
    public string portalConId;
    @auraEnabled
    public string portalConPhone;
     @auraEnabled
    public string portalConEmail;
    public EC_CacheWrapper(){}
    
}