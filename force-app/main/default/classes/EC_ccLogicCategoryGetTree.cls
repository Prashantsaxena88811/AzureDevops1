/* Class Name    : EC_ccLogicCategoryGetTree 
 * Description      :Class to extend the Cloudcraze Logic Class ccLogicCategoryGetTree
 * Created By       :Ashish
 * Created On       :2019-Jun-10
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish                     2019-Jun-10        BC-74102     Created the class   
 *
 */
global virtual with sharing class EC_ccLogicCategoryGetTree extends ccrz.ccLogicCategoryGetTree{
    
    /***************************************************************************************************************************************
    Method Name : getTree
    Description : Returns the category tree by removing the empty categories
    Return type : Returns Map<String,Object>
    **************************************************************************************************************************************/
    global virtual override Map<String, Object> getTree(Map<String, Object> inputData) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_ccLogicCategoryGetTree:getTree:inputData', inputData);
        
        Map<String,Object> superRet = new Map<String,Object>();
        if(!Test.isRunningTest()) {
            superRet = super.getTree(inputData);
        }else{
            superRet = inputData;
        }    
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_ccLogicCategoryGetTree:getTree:superRet', superRet);
        List<Object> theTree = (List<Object>)superRet.get(ccrz.ccApiCategory.CATEGORYTREE);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'eComm_ccLogicCat:theTree', theTree);
       
        List<Object> theTreeDup = new List<Object>();        
        
        Set<String> catIdString = new Set<String>();
        

        
        ccrz.cclog.log('catIdStringViraj'+catIdString);
        
        Set<String> priceIdsIdsSet = new Set<String>();
        Set<String> prodIdsSet = new Set<String>();
        String accGroupId;
        
        /* 
        if(!Test.IsRunningTest()){
            ccrz__E_AccountGroup__c accGroupOb = ccrz.cc_CallContext.currAccountGroup;
            accGroupId=accGroupOb.id;
        }else{
            accGroupId = ccrz.cc_CallContext.effAccountId;
        }

       
        List<ccrz__E_AccountGroupPriceList__c> accGroupPriceList = [SELECT ccrz__AccountGroup__c,ccrz__Pricelist__c,ccrz__Pricelist__r.ccrz__CurrencyISOCode__c from ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__c = :accGroupId and ccrz__Pricelist__r.ccrz__CurrencyISOCode__c=:ccrz.cc_CallContext.userCurrency];
        
        for(ccrz__E_AccountGroupPriceList__c accGroup : accGroupPriceList){
            
            priceIdsIdsSet.add(accGroup.ccrz__Pricelist__c);
            
        }
        */
        
        String prodStatus = Label.EC_ProductStatusFilter;
        String[] prodSts = prodStatus.split(';');
        Set<String> setProdStatus = new Set<String>(prodSts);
		Date today = Date.today();        
        for(ccrz__E_AccountGroupPriceList__c accGroup : [SELECT ccrz__AccountGroup__c,ccrz__Pricelist__c,ccrz__Pricelist__r.ccrz__CurrencyISOCode__c 
                                                         from ccrz__E_AccountGroupPriceList__c 
                                                         where ccrz__AccountGroup__c IN (Select ccrz__E_AccountGroup__c from Account Where Id=:ccrz.cc_CallContext.effAccountId)
                                                         AND ccrz__Pricelist__r.ccrz__CurrencyISOCode__c=:ccrz.cc_CallContext.userCurrency
                                                         AND ccrz__Pricelist__r.ccrz__StartDate__c <= :today
                                                         AND ccrz__Pricelist__r.ccrz__EndDate__c >= : today
                                                         AND ccrz__StartDate__c <= :today
                                                         AND ccrz__EndDate__c >= : today]){            
                                                             priceIdsIdsSet.add(accGroup.ccrz__Pricelist__c);            
                                                         }
        
        List<ccrz__E_PriceListItem__c> entPriceListItems = [SELECT ccrz__Product__c,ccrz__Pricelist__c from ccrz__E_PriceListItem__c 
                                                            where ccrz__Pricelist__c in :priceIdsIdsSet 
                                                            AND ccrz__StartDate__c <= :today
                                      						AND ccrz__EndDate__c >= : today
                                                            AND ccrz__Product__r.ccrz__StartDate__c <= :today 
                                                            AND ccrz__Product__r.ccrz__EndDate__c >= :today 
                                                            AND ccrz__Product__r.ccrz__ProductStatus__c in :setProdStatus
                                                            AND ccrz__Product__r.ccrz__ProductIndexStatus__c != :Label.EC_ProductIndexPending Limit 50000];
        
        for(ccrz__E_PriceListItem__c PIOb : entPriceListItems){
            
            prodIdsSet.add(PIOb.ccrz__Product__c);
            
        }
        
        List<AggregateResult> prodCatList = [SELECT ccrz__Category__c cat from ccrz__E_ProductCategory__c where ccrz__Product__c in :prodIdsSet group by ccrz__Category__c];
        
        Set<String> catIdsSet = new Set<String>();
        
        for(AggregateResult prodCatOb : prodCatList){
            
            catIdsSet.add(String.valueOf(prodCatOb.get('cat')));
            
        }
        
        List<Object> childTree = new List<Object>();
        List<Object> subChildTree = new List<Object>();
        
        Map<String,Object> parentcatElem = new Map<String,Object>();
        Map<String,Object> childCatElem = new Map<String,Object>();
        Map<String,Object> finalChildCatElem = new Map<String,Object>();
        
        theTreeDup = getChildRecordId(theTree,catIdsSet);
       
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'eComm_ccLogicCat:theTreeDup', theTreeDup);
        superRet.put(ccrz.ccApiCategory.CATEGORYTREE,(Object)theTreeDup);
        
        return superRet;
        
    }
    /***************************************************************************************************************************************
    Method Name : getChildRecordId
    Description : Recursive function to remove the empty categories
    Return type : List<Object>
    **************************************************************************************************************************************/
    global List<Object> getChildRecordId(List<Object> theTree,Set<String> catIdsSet){
        try{
            Map<String,Object> parentcatElem; 
            parentcatElem = new Map<String,Object>();            
            List<Integer> indexToRemove = new List<Integer>();
            if(theTree != null && theTree.size()>0){
                Integer index = 0;
                for(Object treeVal:theTree){                    
                    parentcatElem = (Map<String,Object>)treeVal;
                    if(parentcatElem.containsKey('children') && parentcatElem.get('children') != null && ((List<Object>)parentcatElem.get('children')).size()>0 ){              
                        List<Object> catElem = (List<Object>)parentcatElem.get('children');          
                        getChildRecordId(catElem,catIdsSet);
                        if(catElem.size()==0 && !catIdsSet.contains((String)parentcatElem.get('sfid'))){
                            indexToRemove.add(index);
                        }
                    }else{
                        Map<String,Object> finalChildCatElem = new Map<String,Object>();
                        finalChildCatElem = (Map<String,Object>)parentcatElem;     
                        if(!catIdsSet.contains((String)finalChildCatElem.get('sfid'))){
                            indexToRemove.add(index);
                        }                         
                    }
                    index++;                    
                }
                if(!indexToRemove.isEmpty()){
                    for(integer i=indexToRemove.size()-1;i>=0;i--){
                        theTree.remove(indexToRemove.get(i));
                    }           
                }
                indexToRemove.clear();
            }          
            
        }catch(Exception ex){
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'exception eComm_ccLogicCat:theTreeDup', ex.getMessage());
        }
        
        
        return theTree;
    }
  
}