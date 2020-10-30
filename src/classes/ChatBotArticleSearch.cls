/* Class Name      :ChatBotArticleSearch
* Description      :class called from einstien bot
* Created By       :Graytitude Team
* Created On       :14.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          14.09.2020                                      searches articles based on category input and send to bot
*/
public without sharing class ChatBotArticleSearch {
       
    public class SearchInput {
        @InvocableVariable
        public String category;
        @InvocableVariable
        public String subCategory;
        @InvocableVariable(required=true)
        public String routableId;
    }
    
    public class SearchOutput {
        @InvocableVariable(required=true)
        public String sFAQSearchResult;
    } 
    
    @InvocableMethod(label='Search Articles')
    public static List<SearchOutput> searchFAQ(List<SearchInput> SearchInput) {
    
        String sArticleBaseUrl = getCommunityArticleBaseUrl();
        String sFAQSearchResult = '';
        
        String category = SearchInput[0].category;
                
        for(Knowledge__kav objKA : [SELECT Id,Title,UrlName,Walkme_Url__c FROM Knowledge__kav WHERE 
                                    /*Sub_Category__c IN :setSubCategory AND*/ PublishStatus='Online' AND IsVisibleInCsp = true 
                                    AND Category__c=:category AND Sub_Category__c =: SearchInput[0].subCategory]) {
            sFAQSearchResult += summarizeArticleForBot(sArticleBaseUrl, objKA);
        }
        sFAQSearchResult = sFAQSearchResult.removeEnd('\n\n');
        if(String.isBlank(sFAQSearchResult)) sFAQSearchResult = 'No article found';
        List<SearchOutput> faqSearchOutputs = new List<SearchOutput>();
        SearchOutput faqSearchOutput = new SearchOutput();
        faqSearchOutput.sFAQSearchResult = sFAQSearchResult;
        faqSearchOutputs.add(faqSearchOutput);
        return faqSearchOutputs;
    }

    public static String summarizeArticleForBot(String sArticleBaseUrl, Knowledge__kav article){
        String sSummary, sURL;
        sURL = article.Title + ' : ';
        if(String.isBlank(article.Walkme_Url__c)) sURL += sArticleBaseUrl + '/' + article.UrlName;
        else sURL += article.Walkme_Url__c;        
        //sURL = '<a href="' + sURL + '">' + article.Title + '</a>';
        sSummary = sURL + '\n\n'; 
        return sSummary;
    }
    
    public static string getCommunityArticleBaseUrl() {
        String sArticleBaseUrl = '';
        if(Schema.sObjectType.Network.isAccessible()) {            
            List<Network> communityNetworks = [SELECT Id FROM Network WHERE Name='Ecolab'];            
            if (!communityNetworks.isEmpty()) {
                Network communityNetwork = communityNetworks[0];
                String sLoginUrl = Network.getLoginUrl(communityNetwork.id);
                sArticleBaseUrl = sLoginUrl.replace('/login', '/article/');
            }
        }
        return sArticleBaseUrl;
    }
    
    @TestVisible private ChatBotArticleSearch(){} //added as per suggestion of codescan
}