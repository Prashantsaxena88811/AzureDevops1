/* Class Name    : EC_CreateCacheTreeHelper
 * Description      :Helper class of EC_CreateCacheTreeBatch Creating and Refresh the cache tree of all categories
 * Created By       :Jitan Goyal 
 * Created On       :07-30-2019

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Jitan Goyal                    07-30-2019       BC-74102       Created the class   
 *
 */
global with sharing class EC_CreateCacheTreeHelper {
    
    /***************************************************************************************************************************************
  Constructor Name : EC_CreateCacheTreeHelper
  Description : N/A
  Return type : N/A
 *************************************************************************************************************************************/
    global EC_CreateCacheTreeHelper() {
    }
    
    /***************************************************************************************************************************************
  Method Name : createAccountGroupAllowedCategories
  Description : method to create mapping of account and allowed categories values
  Return type : Map<Id,List<EC_AccountGroup_Category__c>> 
 *************************************************************************************************************************************/
    global static Map<Id,List<EC_AccountGroup_Category__c>> createAccountGroupAllowedCategories(List<ccrz__E_AccountGroup__c> acctGrps, List<String> plCurrencies, String storefront){
        EC_CategoryTreeBatchStartEndTimeLine__c batchTime = EC_CategoryTreeBatchStartEndTimeLine__c.getOrgDefaults();
        DateTime batchStartTime = batchTime.EC_Batch_Start_Time__c;

        system.debug('Debug 1---->'+acctGrps+''+plCurrencies+''+storefront);
        Date today = Date.today();
        Map<Id,List<EC_AccountGroup_Category__c>> accGroupMap = new Map<Id,List<EC_AccountGroup_Category__c>>();
        Map<Id,List<Id>> accGroupPricelistMap = new Map<Id,List<Id>>(); 
        
        Set<Id> priceListSet = new Set<Id>();
        List<Id> exisitngAccountGroupList = new List<Id>();
        List<EC_CategoryTreeCache__c> existingCategoryTreeCache = [Select Id, EC_AccountGroup__c from EC_CategoryTreeCache__c Where EC_AccountGroup__c in :(acctGrps)];
        if(!existingCategoryTreeCache.isEmpty()){
            for(EC_CategoryTreeCache__c cacheTree : existingCategoryTreeCache){
                exisitngAccountGroupList.add(cacheTree.EC_AccountGroup__c);
            }    
        }
        
        
        for(ccrz__E_AccountGroupPriceList__c agpl : [SELECT ccrz__AccountGroup__c,ccrz__Pricelist__r.id FROM ccrz__E_AccountGroupPriceList__c WHERE
                                                     ccrz__StartDate__c <= :today AND
                                                     ccrz__EndDate__c >= :today AND 
                                                     ccrz__AccountGroup__c IN: acctGrps 
                                                    ])
        {
            if(accGroupPricelistMap.containsKey(agpl.ccrz__AccountGroup__c)){
                List<Id> priceList = accGroupPricelistMap.get(agpl.ccrz__AccountGroup__c);
                priceList.add(agpl.ccrz__Pricelist__r.id);
                accGroupPricelistMap.put(agpl.ccrz__AccountGroup__c,priceList);
            }else{
                accGroupPricelistMap.put(agpl.ccrz__AccountGroup__c, new List<Id>{agpl.ccrz__Pricelist__r.id});
            }
            priceListSet.add(agpl.ccrz__Pricelist__r.id);
        }
        
        Map<Id,EC_PriceList_Category_Mapping__c> priceListCatMap = new Map<Id,EC_PriceList_Category_Mapping__c>();
        List<Id> modifiedTodayPriceList = new List<Id>();

        for(EC_PriceList_Category_Mapping__c pc : [Select Name,EC_PriceList__c,EC_Category__c,LastModifiedDate from EC_PriceList_Category_Mapping__c Where EC_PriceList__c in :priceListSet 
                                                   and EC_Currency__c in :(plCurrencies) ]){
                                                       priceListCatMap.put(pc.EC_PriceList__c, pc);
                                                       
                                                       if(pc.LastModifiedDate >= batchStartTime ){
                                                            modifiedTodayPriceList.add(pc.EC_PriceList__c);
                                                       }
                                                   }

                                                           
        String plCurrency = plCurrencies[0];
        
        if(!accGroupPricelistMap.isEmpty()){
            Set<String> catSet = new Set<String>();
            Map<Id,Set<Id>> agCatMap = new Map<Id,Set<Id>>();
            
            for(Id ag: accGroupPricelistMap.keySet()){
                Boolean isModifiedAndRecreate = false;
                List<Id> pricelistIds = accGroupPricelistMap.get(ag);
                if(!modifiedTodayPriceList.isEmpty() && !pricelistIds.isEmpty()){
                    for(Id priceList : priceListIds){
                        if(modifiedTodayPriceList.contains(priceList)){
                            isModifiedAndRecreate = true;
                            system.debug('priceList ' + priceList + ' with ag ' + ag +' is modified');
                            break;
                        }
                    }
                }
                if((!existingCategoryTreeCache.isEmpty() && !exisitngAccountGroupList.contains(ag)) || isModifiedAndRecreate){
                    String catStr = '';
                    List<EC_AccountGroup_Category__c> allowedCategoriesNew = new List<EC_AccountGroup_Category__c>();
                    if(!pricelistIds.isEmpty()){
                        for(Id pl : pricelistIds){
                            if(priceListCatMap.containsKey(pl) && String.isNotBlank(priceListCatMap.get(pl).EC_Category__c)){
                                catStr = catStr + priceListCatMap.get(pl).EC_Category__c;   
                            }	
                        }
                    }
                    
                    if(String.isNotBlank(catStr)){
                        //('catStr '+ catStr);
                        List<String> catList = catStr.split(',');
                        catSet.addAll(catList);    
                    }
                    
                    
                    //for(String curr: plCurrencies){
                    if(catSet.size()>0){
                        for(String cat: catSet){
                            allowedCategoriesNew.add( 
                                new EC_AccountGroup_Category__c(
                                    EC_Category__c = cat,
                                    EC_Currency__c = plCurrency,
                                    EC_Storefront__c = storefront,
                                    EC_AccountGroup__c = ag
                                )
                            );
                        }
                    }
                    
                    //}
                    
                    if(!allowedCategoriesNew.isEmpty()){
                        accGroupMap.put(ag,allowedCategoriesNew);
                    }
                }
            }            
        }
        
        
        //     Savepoint sp = Database.setSavepoint();
        //     Boolean doRollback = true;
        return accGroupMap;
    }
   /***************************************************************************************************************************************
  Method Name : walkUpTree
  Description : method to fetch and include the parent categories of the allowed categories corresponding to account records
  Return type : Set<Id>
 *************************************************************************************************************************************/
    private static Set<Id> walkUpTree(Set<Id> catIdSet){
        final Set<Id> retIds = new Set<Id>();
        for(ccrz__E_Category__c cat:[
            SELECT
            ccrz__ParentCategory__c,
            ccrz__ParentCategory__r.ccrz__ParentCategory__c,
            ccrz__ParentCategory__r.ccrz__ParentCategory__r.ccrz__ParentCategory__c
            FROM
            ccrz__E_Category__c
            WHERE
            Id IN :catIdSet
            Order By ccrz__ParentCategory__c
        ]){
            recurseParentTree(cat, retIds);
        }
        return retIds;
    }
    
    /***************************************************************************************************************************************
  Method Name : recurseParentTree
  Description : helper method of walkUpTree to fetch the allowed parent categories
  Return type : void
 *************************************************************************************************************************************/
    private static void recurseParentTree(ccrz__E_Category__c cat, Set<Id> catIdSet){
        try{
            if(null != cat.ccrz__ParentCategory__c){
                catIdSet.add(cat.ccrz__ParentCategory__r.id);
                recurseParentTree(cat.ccrz__ParentCategory__r, catIdSet);
            }
        }
        catch(Exception ignore){
            system.debug('exception cat ' + ignore.getMessage());
        }
    }
    
    /***************************************************************************************************************************************
  Class Name : TreeElement
  Description : Wrapper class to map category values and compare the categories
 *************************************************************************************************************************************/
    public class TreeElement implements Comparable{
        
        public String sfid{get;set;}
        public String name{get;set;}
        public String parentCategory{get;set;}
        public String categoryId{get;set;}
        transient public Integer sequence{get;set;}
        public List<TreeElement> children{get;set;}
         /***************************************************************************************************************************************
  Constructor Name : TreeElement
  Description :initializes the list
  Return type : N/A
 *************************************************************************************************************************************/
        public TreeElement(){
            children = new List<TreeElement>();
        }
      /***************************************************************************************************************************************
  Method Name : compareTo
  Description : – returns the sequence of elements
  Return type : Integer 
 *************************************************************************************************************************************/
        public Integer compareTo(Object obj){
            return sequence - ((TreeElement)obj).sequence;
        }
    }
    
    
     /***************************************************************************************************************************************
  Method Name : refreshCategoryCaches
  Description : – method to refresh the category json (insert new allowed and delete old categories)
  Return type : void
 *************************************************************************************************************************************/
    global static void refreshCategoryCaches( Map<Id,List<EC_AccountGroup_Category__c>> accountGrpCategoryMap, String[] plCurrencies, String storefront, String[] locales){
        final List<String> actLocales = new List<String>(locales);
        //actLocales.add('zzzz');
        Set<Id> acctGrps = accountGrpCategoryMap.keySet();
        List<EC_CategoryTreeCache__c> toInsert = new List<EC_CategoryTreeCache__c>();
        Set<Id> agIds = new Set<Id>();
        for(Id ag:acctGrps){
            agIds.add(ag);
            List<EC_AccountGroup_Category__c> accGroupCatList = accountGrpCategoryMap.get(ag);
            for(String plCurr:plCurrencies){
                toInsert.addAll(createCategoryTreeCache(ag,accGroupCatList, storefront, plCurr, actLocales));
            }
        }
        system.debug('toInsert'+toInsert.size());
        Savepoint sp = Database.setSavepoint();
        Boolean doRollback = true;
        try{
            DELETE [
                SELECT Id
                FROM EC_CategoryTreeCache__c
                WHERE
                EC_AccountGroup__c IN :agIds AND
                EC_Storefront__c = :storefront
            ];
            insert toInsert;
            //('toInsert-->'+toInsert);
            doRollback = false;
        }catch(Exception ex){
            system.debug('Exception refreshCategoryCaches '+ ex.getMessage()+  ' line ' + ex.getLineNumber());
        }finally{
            if(doRollback){
                Database.rollback(sp);
            }
        }
    }
    
     /***************************************************************************************************************************************
  Method Name : createCategoryTreeCache
  Description : method to create the category json
  Return type : List<EC_CategoryTreeCache__c>
 *************************************************************************************************************************************/
    private static List<EC_CategoryTreeCache__c> createCategoryTreeCache( Id agId, List<EC_AccountGroup_Category__c> accGroupCatList, String storefront, String plCurrency , List<String> actLocales){
        List<Id> categoryIdList = new List<Id>();
        for(EC_AccountGroup_Category__c cat:accGroupCatList){
            if(cat.EC_Currency__c == plCurrency){
                categoryIdList.add(cat.EC_Category__c);
            }
        }
        //('categoryIdList'+categoryIdList);
        
        Map<Id,ccrz__E_Category__c> allowedCats = new Map<Id,ccrz__E_Category__c>([
            SELECT
            Id,
            Name,
            ccrz__Sequence__c,
            ccrz__CategoryID__c,
            ccrz__ParentCategory__r.Id,
            (SELECT Name, ccrz__Locale__c FROM ccrz__CategoryI18Ns__r WHERE ccrz__Locale__c IN : actLocales)
            FROM
            ccrz__E_Category__c
            WHERE
            Id IN :categoryIdList AND
            ccrz__ParentCategory__c != NULL
            ORDER BY ccrz__Sequence__c
        ]);
        Map<String,List<TreeElement>> theTrees = new Map<String,List<TreeElement>>();
        Map<Id,Map<String,TreeElement>> elementLookup = new Map<Id,Map<String,TreeElement>>();
        
        for(ccrz__E_Category__c cat:allowedCats.values()){
            recurseCacheBuild(cat, allowedCats, theTrees, elementLookup, actLocales );
        }
        List<EC_CategoryTreeCache__c> caches = new List<EC_CategoryTreeCache__c>();
        
        for(String loc:theTrees.keySet()){
            String data = JSON.serialize(theTrees.get(loc));
            Integer startLimit = 0;
            Integer endLimit = 130000;
            Integer fixLimit = 130000;
            Integer sequence = 1;
            Boolean bcontinue = true;
            while(startLimit < data.length() && bcontinue){
                
                if(endLimit >= data.length()){
                    endLimit = data.length();
                    bcontinue = false;
                }
                
                String tempdata = data.substring(startLimit, endLimit);
                startLimit = endLimit;
                endLimit = endLimit + fixLimit;
                
                caches.add( new EC_CategoryTreeCache__c(
                    EC_AccountGroup__c = agId,
                    EC_Storefront__c = storefront,
                    EC_Currency__c = plCurrency,
                    EC_Locale__c = loc,
                    EC_CacheData__c = tempdata,
                    EC_Sequence__c = sequence
                ));
                sequence += 1;
            }     
        }
        return caches;
    }
    
    
     /***************************************************************************************************************************************
  Method Name : createPricelistCategoryMapping
  Description : method to get the allowed categories corresponding to pricelist of account records.
  Return type : String
 *************************************************************************************************************************************/
    global static String createPricelistCategoryMapping(Id pricelistIds, String plCurrency, String storefront){
        String catString = '';
        Date today = Date.today();
        Set<Id> catIds = new Set<Id>();
        List<ccrz__E_Category__c> retVal = new List<ccrz__E_Category__c>();
        ////('agId'+agId+'storefront'+storefront+'plCurrency'+plCurrency);        
        If (String.isNotBlank(pricelistIds)){
            for(AggregateResult ag:[
                SELECT count(ccrz__Product__r.Id), ccrz__Category__c
                FROM ccrz__E_ProductCategory__c
                WHERE
                ccrz__Product__c IN (
                    SELECT ccrz__Product__c
                    FROM ccrz__E_PriceListItem__c
                    WHERE
                    ccrz__Pricelist__c =:pricelistIds AND
                    ccrz__PriceList__r.ccrz__CurrencyISOCode__c = :plCurrency AND
                    ccrz__PriceList__r.ccrz__StartDate__c <= :today AND
                    ccrz__PriceList__r.ccrz__EndDate__c >= :today AND
                    ccrz__PriceList__r.ccrz__Storefront__c INCLUDES (:storefront) AND
                    ccrz__StartDate__c <= :today AND
                    ccrz__EndDate__c >= :today
                ) AND
                ccrz__Product__r.ccrz__StartDate__c <= :today AND
                ccrz__Product__r.ccrz__EndDate__c >= :today AND
                ccrz__Product__r.ccrz__Storefront__c INCLUDES (:storefront) AND
                ccrz__Product__r.ccrz__ProductStatus__c IN ('Released', 'Not Orderable') AND
                ccrz__Product__r.ccrz__ProductIndexStatus__c != :Label.EC_ProductIndexPending AND
                ccrz__StartDate__c <= :today AND
                ccrz__EndDate__c >= :today 
                GROUP BY ccrz__Category__c
                HAVING count(ccrz__Product__r.Id) > 0
                Order by ccrz__Category__c ASC
            ]){
                catIds.add((Id)ag.get('ccrz__Category__c'));
                if(!catString.contains(String.valueOf(ag.get('ccrz__Category__c')))){
                    catString = catString + (Id)ag.get('ccrz__Category__c') +  ',';  
                }
                
            }
            If (catIds.size() > 0) {
                Set<Id> firstRunParents = walkUpTree(catIds);
                if(firstRunParents != null && !firstRunParents.isEmpty()){
                    for(Id firstRunIds : firstRunParents){
                        if(!catIds.contains(firstRunIds)){
                            catIds.add(firstRunIds);
                        }
                    }
                }
                
                If(firstRunParents.size() > 0) {
                    Set<Id> secondRunParents = walkUpTree(firstRunParents);
                    if(secondRunParents != null && !secondRunParents.isEmpty()){
                        for(Id secondRunIds : secondRunParents){
                            if(!catIds.contains(secondRunIds)){
                                catIds.add(secondRunIds);
                            }
                        }
                    }
                }
                for(Id c : catIds){
                    if(!catString.contains(c)){
                        catString = catString + c + ','; 
                    }
                    
                }
            }
        }
        
        If (catIds.size() > 0) {
            //retVal = [SELECT Id, Name FROM ccrz__E_Category__c WHERE Id IN :catIds];
        }
        return catString;
        // return null;
        
    }
    
     /***************************************************************************************************************************************
  Method Name : recurseCacheBuild
  Description : helper method of createCategoryTreeCache to generate category tree json
  Return type : void
 *************************************************************************************************************************************/
    private static void recurseCacheBuild( ccrz__E_Category__c currCat,
                                          Map<Id,ccrz__E_Category__c> catMap,
                                          Map<String,List<TreeElement>> dataCache,
                                          Map<Id,Map<String,TreeElement>> elementLookup,
                                          List<String> locales ){
                                              
                                              if(null != currCat){
                                                  ccrz__E_Category__c currCatParent = catMap.get(currCat.ccrz__ParentCategory__c);
                                                  
                                                  if(null != currCatParent){
                                                      //('currCatParent-->IN--->'+currCatParent);
                                                      recurseCacheBuild(currCatParent, catMap, dataCache, elementLookup, locales);
                                                  }
                                                  //('currCatParent-->OUT--->'+currCatParent);
                                                  if(!elementLookup.containsKey(currCat.id)){
                                                      Map<String,String> mappedNames = new Map<String,String>();
                                                      for(ccrz__E_CategoryI18N__c i18nCat : currCat.ccrz__CategoryI18Ns__r){
                                                          mappedNames.put(i18nCat.ccrz__Locale__c,i18nCat.Name);
                                                      }
                                                      
                                                      Map<String,TreeElement> localeElemMap = new Map<String,TreeElement>();
                                                      for(String loc:locales){
                                                          TreeElement elem = new TreeElement();
                                                          elem.sfid = currCat.Id;
                                                          elem.parentCategory = currCat.ccrz__ParentCategory__r.Id;
                                                          elem.categoryId = currCat.ccrz__CategoryID__c;
                                                          if(null != currCat.ccrz__Sequence__c){
                                                              elem.sequence = currCat.ccrz__Sequence__c.intValue();
                                                          }else{
                                                              elem.sequence = 0;
                                                          }
                                                          if(mappedNames.containsKey(loc)){
                                                              elem.name = mappedNames.get(loc);
                                                          }else{
                                                              elem.name = currCat.name;
                                                          }
                                                          localeElemMap.put(loc,elem);
                                                      }
                                                      
                                                      if(null != currCatParent){
                                                          //('currCatParent ---->'+currCatParent);
                                                          Map<String,TreeElement> parentTrees = elementLookup.get(currCatParent.id);
                                                          
                                                          for(String loc:parentTrees.keySet()){
                                                              TreeElement pElem = parentTrees.get(loc);
                                                              TreeElement cElem = localeElemMap.get(loc);
                                                              pElem.children.add(cElem);
                                                              pElem.children.sort();
                                                          }
                                                      }else{//Top level element
                                                          for(String loc:locales){
                                                              List<TreeElement> topList = dataCache.get(loc);
                                                              if(null==topList){
                                                                  topList = new List<TreeElement>();
                                                                  dataCache.put(loc,topList);
                                                              }
                                                              topList.add(localeElemMap.get(loc));
                                                              topList.sort();
                                                              
                                                              
                                                              
                                                          }
                                                      }
                                                      elementLookup.put(currCat.Id, localeElemMap);
                                                  }
                                              }
                                          }
    
    
}