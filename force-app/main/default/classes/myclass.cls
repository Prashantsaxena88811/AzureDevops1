global class DataSetup implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    global SObject_Data_Sync_Configuration__mdt currentsObject;
    global List<String> parentRelations = new List<String>();
    global String accessToken;
    global OAuth objAuthenticationInfo;
    global Map<String,Map<String,String>> objectNameToOld_NewId = new Map<String,Map<String,String>>();// Account-[oldId-NewId]
    global Database.SaveResult[] saveresultList;
    global Map<String,String> targetAccountRecordTypeNameToIdMap =  fetchAccountRecordTypeNameToIdMap();
    global Map<String,String> sourceAccountRecordTypeNameToIdMap =  getAccountRecordTypeFromSource();
    //global DateTime productLastDateProcessed;
    //global String lastNameProcessed;
    global List<Sobject> sobjectList = new List<Sobject>();
    global List<Sobject> sobjectListClone = new List<Sobject>();
    
    public  Map<String,String> fetchAccountRecordTypeNameToIdMap(){
        Map<String,String> targetAccountRecordTypeNameToIdMap = new Map<String,String>();
        List<RecordType> recordTypeList =  new List<RecordType>();
        recordTypeList = [Select Id,Name,developername FROM recordtype where SobjectType ='Account'];
        System.debug(recordTypeList);
        for(RecordType recordTypeVar : recordTypeList){
            targetAccountRecordTypeNameToIdMap.put(recordTypeVar.developername,recordTypeVar.Id);
        }
        return targetAccountRecordTypeNameToIdMap;
    }
    public Map<String,String> getAccountRecordTypeFromSource(){
        Map<String,String> sourceAccountRecordTypeNameToIdMap = new Map<String,String>();
        objAuthenticationInfo = getAccessToken();
        accessToken = objAuthenticationInfo.access_token;
        String endpointUrl =  objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q=Select+Id,Name,developerName+FROM+Recordtype+where+SobjectType=\'Account\'';
        Map<String, Object> responseMap = fetchSobejctData(endpointUrl);
        List<Sobject> recordTypeList = (List<Sobject>)JSON.deserialize(JSON.serializePretty(responseMap.get('records')), List<Sobject>.Class);
        for(Sobject sobjectvar : recordTypeList ){
            sourceAccountRecordTypeNameToIdMap.put( String.valueOf(sobjectvar.get('Id')) , String.valueOf(sobjectvar.get('DeveloperName')) ) ;
        }
        return sourceAccountRecordTypeNameToIdMap;                                            
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        List<SObject_Data_Sync_Configuration__mdt> sObjectConfiList =  new List<SObject_Data_Sync_Configuration__mdt>();
        sObjectConfiList = [Select sObjectAPIName__c,Fields__c,Parent_Relations__c from SObject_Data_Sync_Configuration__mdt];
        System.debug('sObjectConfiList--->'+sObjectConfiList);
        List<String> parentRelations;
        List<String> relationShipInfo;
        String query = 'Select Id,Filter_Mode__c,Hold_Value__c,SObjectRecordLimit__c,order__c,sObjectAPIName__c,Fields__c,Parent_Relations__c from SObject_Data_Sync_Configuration__mdt  order by Order__c asc ';
        return Database.getQueryLocator(query);
        
    }
    public String retrieveFilterOfObject(){
        // need disucssion for child objects filters or use map to use filter for each object.
        try{
            String filterMode;
            filterMode='+'+currentsObject.Filter_Mode__c+'+';
            List<SObject_Data_Sync_Configuration_Filters__mdt> filtersList = new List<SObject_Data_Sync_Configuration_Filters__mdt>();
            filtersList = [Select Filter_Field__c,Filter_Value__c,SObject_Data_Sync_Configuration__c,Filter_Type__c,isActive__c from SObject_Data_Sync_Configuration_Filters__mdt where SObject_Data_Sync_Configuration__c=:currentsObject.Id and isActive__c = true ];
            //filtersList = [Select Filter_Field__c,Filter_Value__c,SObject_Data_Sync_Configuration__c,Filter_Type__c,isActive__c from SObject_Data_Sync_Configuration_Filters__mdt where SObject_Data_Sync_Configuration__c=:'m0G2h0000004FIx'];
            System.debug('filtersList------------>'+filtersList);
            Schema.DisplayType fieldtype;
            SObjectType sObjectTypeVar = ((SObject)(Type.forName('Schema.'+currentsObject.sObjectAPIName__c).newInstance())).getSObjectType();
            DescribeSObjectResult describeSObjectResultVar = SObjectTypeVar.getDescribe();
            String whereClause='';
            for(SObject_Data_Sync_Configuration_Filters__mdt filtermdt : filtersList){
                System.debug('type of field---->'+describeSObjectResultVar.fields.getMap().get(filtermdt.Filter_Field__c).getDescribe().getType());
                fieldtype = describeSObjectResultVar.fields.getMap().get(filtermdt.Filter_Field__c).getDescribe().getType();
                if( fieldtype == Schema.DisplayType.STRING ){
                    if(filtermdt.Filter_Type__c == 'Exact Match'){
                        if(whereClause == ''){
                            whereClause = '+where+(+'+filtermdt.Filter_Field__c+'='+'\''+filtermdt.Filter_Value__c+'\'';
                        }else{
                            //whereClause=whereClause+'+OR+'+filtermdt.Filter_Field__c+'='+'\''+filtermdt.Filter_Value__c+'\'';
                            whereClause=whereClause+filterMode+filtermdt.Filter_Field__c+'='+'\''+filtermdt.Filter_Value__c+'\'';
                        }
                        
                    }
                    else if(filtermdt.Filter_Type__c == 'LIKE'){
                        if(whereClause == ''){
                            whereClause = '+where+(+'+filtermdt.Filter_Field__c+'+LIKE+'+'\''+'%25'+filtermdt.Filter_Value__c+'%25'+'\'';
                        }else{
                            whereClause=whereClause+filterMode+filtermdt.Filter_Field__c+'+LIKE+'+'\''+'%25'+filtermdt.Filter_Value__c+'%25'+'\'';
                        }
                        
                    }
                    else if(filtermdt.Filter_Type__c == 'IN'){
                        String ee = filtermdt.Filter_Value__c.replace(',', '\',\'');
                        System.debug('ee-->'+ee);
                        if(whereClause == ''){
                            whereClause = '+where+(+'+filtermdt.Filter_Field__c+'+IN+'+'(\''+filtermdt.Filter_Value__c.replace(',', '\',\'')+'\')';
                        }else{
                            whereClause=whereClause+filterMode+filtermdt.Filter_Field__c+'+IN+'+'(\''+filtermdt.Filter_Value__c.replace(',', '\',\'')+'\')';
                        }
                        
                    }
                    
                }
                else if(fieldtype == Schema.DisplayType.BOOLEAN){
                    if(whereClause == ''){
                        whereClause = '+where+(+'+filtermdt.Filter_Field__c+'+=+'+filtermdt.Filter_Value__c;
                    }else{
                        whereClause=whereClause+filterMode+filtermdt.Filter_Field__c+'+=+'+filtermdt.Filter_Value__c;
                    }
                }
                else if(fieldtype == Schema.DisplayType.INTEGER || fieldtype == Schema.DisplayType.DOUBLE){
                    if(whereClause == ''){
                        whereClause = '+where+(+'+filtermdt.Filter_Field__c+'+=+'+filtermdt.Filter_Value__c;
                    }else{
                        whereClause=whereClause+'filterMode'+filtermdt.Filter_Field__c+'+=+'+filtermdt.Filter_Value__c;
                    }
                }
                else if(fieldtype == Schema.DisplayType.REFERENCE){
                    if(whereClause == ''){
                        whereClause = '+where+(+'+filtermdt.Filter_Field__c+'+IN+'+'(\''+filtermdt.Filter_Value__c.replace(',', '\',\'')+'\')';
                    }else{
                        whereClause=whereClause+filterMode+filtermdt.Filter_Field__c+'+IN+'+'(\''+filtermdt.Filter_Value__c.replace(',', '\',\'')+'\')';
                    }
                }
            }
            System.debug('whereClause->'+whereClause);
            if(whereClause != null && whereClause!=''){
               whereClause = whereClause+')'; 
            }
            
            System.debug('whereClause->'+whereClause);
            return whereClause;
        }catch(Exception e){
            System.debug('retrieveFilterOfObject get exeption on line number-->'+e.getLineNumber()+' error is-->'+e.getMessage());
            return null;
        }
        
        
    }
    public void removeKeysFromMap(){
        if(currentsObject.sObjectAPIName__c == 'ccrz__E_ConfigurationModule__c'){
            objectNameToOld_NewId.remove('ccrz__E_PageLabel__c');
            
        }else if(currentsObject.sObjectAPIName__c == 'ccrz__E_Configuration__c'){
            objectNameToOld_NewId.remove('ccrz__E_ConfigurationModule__c');
        }
        else if(currentsObject.sObjectAPIName__c == 'ccrz__E_AccountGroup__c'){
            objectNameToOld_NewId.remove('ccrz__E_Configuration__c');
            objectNameToOld_NewId.remove('ccrz__E_ConfigurationMeta__c');
        }
        else if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceList__c'){
            objectNameToOld_NewId.remove('Account');
            objectNameToOld_NewId.remove('Contact');
        }
        else if(currentsObject.sObjectAPIName__c == 'ccrz__E_Product__c'){
            objectNameToOld_NewId.remove('ccrz__E_AccountGroupPriceList__c');
            objectNameToOld_NewId.remove('ccrz__E_AccountGroup__c');
        }
        else if(currentsObject.sObjectAPIName__c == 'ccrz__E_Spec__c'){
            objectNameToOld_NewId.remove('ccrz__E_PriceListItem__c');
            objectNameToOld_NewId.remove('ccrz__E_PriceList__c');
        }
        else if(currentsObject.sObjectAPIName__c == 'ccrz__E_ProductMedia__c'){
            objectNameToOld_NewId.remove('ccrz__E_ProductSpec__c');
            objectNameToOld_NewId.remove('ccrz__E_Spec__c');
        }
        else if(currentsObject.sObjectAPIName__c == 'ccrz__E_RelatedProduct__c'){
            objectNameToOld_NewId.remove('ccrz__E_ProductMedia__c');
        }else if(currentsObject.sObjectAPIName__c == 'ccrz__E_Category__c'){
            objectNameToOld_NewId.remove('ccrz__E_RelatedProduct__c');
        }else if(currentsObject.sObjectAPIName__c == 'ccrz__E_ProductCategory__c'){
            objectNameToOld_NewId.remove('ccrz__E_Menu__c');
        }
    }
    
    public string createInQuery(set<String> Idset , Integer idCount){
        String Ids = '';
        Integer Counter = 0;
        for(String parentId :Idset ){
            if(idCount == Counter ){
                break; 
            }
            Counter = Counter + 1;
            if(Ids ==''){
                Ids =   '\''+parentId+'\'';
            }else{
                Ids =Ids+','+ '\''+parentId+'\'';   
            }
        }
        return Ids;
    }
    
    public String returnEndpointURL(String whereClause,String Ids,String accountGroupIds , List<String> parentRelationInfo){
        String endpointUrl;
        if(whereClause !=null && whereClause!='' ){
            if( currentsObject.SObjectRecordLimit__c !=null ){
                System.debug('*********11************');
                if(currentsObject.sObjectAPIName__c == 'ccrz__E_AccountGroupPriceList__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+whereclause+'+LIMIT+'+integer.valueOf(currentsObject.SObjectRecordLimit__c)+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }else if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceListItem__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+whereclause+'LIMIT+'+integer.valueOf(currentsObject.SObjectRecordLimit__c)+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }else{
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+whereclause+'+LIMIT+'+integer.valueOf(currentsObject.SObjectRecordLimit__c)+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }
            }else{
                System.debug('*********22************');
                if(currentsObject.sObjectAPIName__c == 'ccrz__E_AccountGroupPriceList__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+whereclause+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }
                else if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceListItem__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+whereclause+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }else{
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+whereclause+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }
            }  
        }else{
            if( currentsObject.SObjectRecordLimit__c !=null ){
                System.debug('*********1************');
                if(currentsObject.sObjectAPIName__c == 'ccrz__E_AccountGroupPriceList__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+'+LIMIT+'+integer.valueOf(currentsObject.SObjectRecordLimit__c)+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }
                else if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceListItem__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+'+LIMIT+'+integer.valueOf(currentsObject.SObjectRecordLimit__c)+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }else{
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+'+LIMIT+'+integer.valueOf(currentsObject.SObjectRecordLimit__c)+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }
            }else{ 
                System.debug('*********2************');
                if(currentsObject.sObjectAPIName__c == 'ccrz__E_AccountGroupPriceList__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }
                else if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceListItem__c'){
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }else{
                    endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+'(Select+Id,'+currentsObject.Fields__c +'+FROM+' +parentRelationInfo[2]+')'+'+FROM+'+parentRelationInfo[0]+'+WHERE+ID+IN+'+Ids;
                    
                }
            }   
        }
        return endpointUrl;
    }
   
    global void execute(Database.BatchableContext BC, List<SObject_Data_Sync_Configuration__mdt> confugurationList) {	// expecting a single record here
        try{
            
            
            currentsObject = confugurationList[0];
            //remove all the keys from map which are not required
            removeKeysFromMap();
            System.debug('sourceAccountRecordTypeNameToIdMap-->'+sourceAccountRecordTypeNameToIdMap);
            System.debug('targetAccountRecordTypeNameToIdMap-->'+targetAccountRecordTypeNameToIdMap);
            parentRelations = new List<String>();
            List<String> parentRelationInfo = new List<String>();
            String queryFilter = '';
            saveresultList = new List<Database.SaveResult>();
            sobjectList = new List<Sobject>();
            sobjectListClone = new List<Sobject>();
            
            System.debug('config------------>'+currentsObject);  
            objAuthenticationInfo = getAccessToken();
            System.debug('access-token--->'+objAuthenticationInfo.access_token);
            accessToken = objAuthenticationInfo.access_token;
            System.debug('accessToken--->'+accessToken);
            String endpointUrl = '';
            // if there is  parent for this sobject
            if( (currentsObject.Parent_Relations__c != '' && currentsObject.Parent_Relations__c != null) &&
               !(currentsObject.sObjectAPIName__c == 'ccrz__E_Menu__c' 
                 || currentsObject.sObjectAPIName__c == 'ccrz__E_ConfigurationMeta__c'
                 || currentsObject.sObjectAPIName__c == 'ccrz__E_ConfigurationModule__c'  ||
                 currentsObject.sObjectAPIName__c == 'ccrz__E_Configuration__c' ) ){
                     System.debug('******************');
                     System.debug('*************parent relations*****'+currentsObject.Parent_Relations__c);
                     //reteieve only those child objects records which are related to the parent
                     parentRelations = currentsObject.Parent_Relations__c.split('-');
                     parentRelationInfo = parentRelations[0].split('/');
                     System.debug('objectNameToOld_NewId-Keys-'+objectNameToOld_NewId);
                     for(String mapKeys : objectNameToOld_NewId.keySet()){
                         System.debug('exec KEY PRESENT IN MAP------>'+mapKeys);
                         
                     }
                     String Ids ='';
                     //integer idCount = 0;//max 600
                     Ids = createInquery(objectNameToOld_NewId.get(parentRelationInfo[0]).keySet() , 550);

                     Ids = '('+Ids+')';
                     
                     //System.debug('retrieveFilterOfObject()---->'+whereClause);
                     String accountGroupIds = '';
                     /*if(currentsObject.sObjectAPIName__c == 'ccrz__E_AccountGroupPriceList__c'){
                         accountGroupIds = createInquery(objectNameToOld_NewId.get('ccrz__E_AccountGroup__c').keySet(),50);
                        
                         accountGroupIds = '('+accountGroupIds+')';
                     } */
                     
                    /* if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceListItem__c'){
                         accountGroupIds = '';// productids when query pricelistitem
                         accountGroupIds = createInquery(objectNameToOld_NewId.get('ccrz__E_Product__c').keySet(),500);
                         
                         accountGroupIds = '('+accountGroupIds+')';
                     }*/
                     String whereClause = retrieveFilterOfObject();
                     String parentFieldCheck='';
                     for(String parentField :parentRelations){
                         if(parentFieldCheck == ''){
                             parentFieldCheck = parentField.split('/')[1]+'+!=null+';
                         }else{
                             parentFieldCheck = parentFieldCheck+'+AND+'+parentField.split('/')[1]+'+!=null+';
                         }
                     }
                     if(whereClause!=null && whereClause!=''){
                         whereClause =whereClause +'+'+parentFieldCheck;
                     }else{
                         whereClause = '+where+'+parentFieldCheck+'+';
                     }
                     endpointUrl = returnEndpointURL(whereClause,Ids,accountGroupIds,parentRelationInfo);
                     System.debug('returnsObjectData-endpointUrl>'+endpointUrl); 
                     //
                     //parent field must be null , if for the sobject parent exists.
                     
                     //endpointUrl=endpointUrl+parentFieldCheck;
                     //
                     returnsObjectData(endpointUrl,true,parentRelationInfo);
                 }else{
                     String whereClause ='';
                     System.debug('******************');
                     //if parent exist for this sobject for now only for single for single parent.
                     endpointUrl = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,'+currentsObject.Fields__c+'+FROM+'+currentsObject.sObjectAPIName__c; 
                      
                     whereClause = retrieveFilterOfObject();
                     if(whereClause !=null && whereClause!='' ){
                         endpointUrl=endpointUrl+whereClause; 
                     }
                     if(currentsObject.Parent_Relations__c != '' && currentsObject.Parent_Relations__c != null){
                         parentRelations = currentsObject.Parent_Relations__c.split('-');
                     }
                     if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceList__c'){
                         /*Map<String, Object> responseMap = new Map<String, Object>();
                         // query on accountgroup pricelist to retrieve the pricelist IDs
                         String accountgroupPricelist = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,ccrz__AccountGroup__c,ccrz__Pricelist__c+from+ccrz__E_AccountGroupPriceList__c+WHERE+ccrz__AccountGroup__c+IN+';
                         String Ids ='';
                         //integer idCount = 0;//max 500
                         Ids = createInquery(objectNameToOld_NewId.get('ccrz__E_AccountGroup__c').keySet() , 500);
                         Ids = '('+Ids+')';
                         accountgroupPricelist = accountgroupPricelist+Ids;
                         System.debug('accountgroupPricelist-->'+accountgroupPricelist);
                         responseMap = fetchSobejctData(accountgroupPricelist);
                         List<Sobject> accountGrpsobjectList = new List<Sobject>();
                         accountGrpsobjectList = (List<Sobject>)JSON.deserialize(JSON.serializePretty(responseMap.get('records')), List<Sobject>.Class);
                         String priceListIds ='';
                         Integer idCount = 0;//max 500
                         //make set of Pricelist Ids
                         for(Sobject accountGrpsobjectvar : accountGrpsobjectList ){
                             if(idCount == 500 )
                                 break;
                             if(accountGrpsobjectvar.get('ccrz__Pricelist__c') != null && accountGrpsobjectvar.get('ccrz__Pricelist__c') != '' && (!priceListIds.containsIgnoreCase( String.valueOf(accountGrpsobjectvar.get('ccrz__Pricelist__c')) ))  ){                      
                                 idCount = idCount + 1;
                                 if(priceListIds ==''){
                                     priceListIds =   '\''+accountGrpsobjectvar.get('ccrz__Pricelist__c')+'\'';
                                 }else{
                                   priceListIds =priceListIds+','+ '\''+accountGrpsobjectvar.get('ccrz__Pricelist__c')+'\''; 
                                 }
                                 
                             }
                         }
                         priceListIds = '('+priceListIds+')';
                         System.debug('endpointUrl11--->'+endpointUrl);
                         if(whereClause !=null && whereClause!='' ){
                             endpointUrl=endpointUrl+'+AND+Id+IN+'+priceListIds; 
                             System.debug('endpointUrl21--->'+endpointUrl);
                         }else{
                             endpointUrl=endpointUrl+'+WHERE+Id+IN+'+priceListIds; 
                             System.debug('endpointUrl41--->'+endpointUrl);
                         }
                         responseMap.clear();*/
                         endpointUrl =  buildQueryForObject(endpointUrl,whereClause);
                     }
                     else if(currentsObject.sObjectAPIName__c == 'ccrz__E_Product__c'){
                       /*  Map<String, Object> responseMap = new Map<String, Object>();
                         // query on accountgroup pricelist to retrieve the pricelist IDs
                         String priceListItem = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,ccrz__Product__c+from+ccrz__E_PriceListItem__c+WHERE+ccrz__Product__c+!=NULL+AND+ccrz__Pricelist__c+IN+';
                         String Ids ='';
                         //integer idCount = 0;//max 500
                         Ids = createInquery(objectNameToOld_NewId.get('ccrz__E_PriceList__c').keySet() , 500);
                         Ids = '('+Ids+')';
                         priceListItem = priceListItem+Ids;
                         System.debug('priceListItem-for-product-fetch->'+priceListItem);
                         responseMap = fetchSobejctData(priceListItem);
                         List<Sobject> priceListItemList = new List<Sobject>();
                         priceListItemList = (List<Sobject>)JSON.deserialize(JSON.serializePretty(responseMap.get('records')), List<Sobject>.Class);
                         String productIds ='';
                         Integer idCount = 0;//max 500
                         //make set of Pricelist Ids
                         for(Sobject priceListvar : priceListItemList ){
                             if(idCount == 500 )
                                 break;
                             if(priceListvar.get('ccrz__Product__c') != null && priceListvar.get('ccrz__Product__c') != '' && (!productIds.containsIgnoreCase( String.valueOf(priceListvar.get('ccrz__Product__c')) ))  ){                      
                                 idCount = idCount + 1;
                                 if(productIds ==''){
                                     productIds =   '\''+priceListvar.get('ccrz__Product__c')+'\'';
                                 }else{
                                    productIds =productIds+','+ '\''+priceListvar.get('ccrz__Product__c')+'\''; 
                                 }
                                 
                             }
                         }
                         productIds = '('+productIds+')';
                         System.debug('endpointUrl11--->'+endpointUrl);
                         if(whereClause !=null && whereClause!='' ){
                             endpointUrl=endpointUrl+'+AND+Id+IN+'+productIds; 
                             System.debug('endpointUrl21--->'+endpointUrl);
                         }else{
                             endpointUrl=endpointUrl+'+WHERE+Id+IN+'+productIds; 
                             System.debug('endpointUrl41--->'+endpointUrl);
                         }
                         responseMap.clear();*/
                         endpointUrl = buildQueryForObject(endpointUrl,whereClause);
                     }
                   
                     if(currentsObject.SObjectRecordLimit__c != null &&
                        !(currentsObject.sObjectAPIName__c == 'ccrz__E_AccountGroup__c' 
                          || currentsObject.sObjectAPIName__c == 'ccrz__E_Category__c' || currentsObject.sObjectAPIName__c == 'ccrz__E_Spec__c'
                          || currentsObject.sObjectAPIName__c == 'ccrz__E_ProductMedia__c'
                          || currentsObject.sObjectAPIName__c == 'ccrz__E_ProductCategory__c' || currentsObject.sObjectAPIName__c == 'ccrz__E_PageLabel__c'
                          || currentsObject.sObjectAPIName__c == 'ccrz__E_ConfigurationModule__c' || currentsObject.sObjectAPIName__c == 'ccrz__E_Configuration__c' 
                          || currentsObject.sObjectAPIName__c == 'ccrz__E_ConfigurationMeta__c' ) ){
                              System.debug('***********LIMIT**************');
                              endpointUrl =endpointUrl+'+LIMIT+'+Integer.valueOf(currentsObject.SObjectRecordLimit__c); 
                              
                          }
                     
                     returnsObjectData(endpointUrl,false,new List<String>());
                 }
            
        }catch(Exception e){
            System.debug('get exeption on line number-->'+e.getLineNumber()+' error is-->'+e.getMessage());
        }
    }
    //this method will build query only for ccrz__E_Product__c and ccrz__E_PriceList__c
    public String buildQueryForObject(String endpointUrl , String whereClause){
        Map<String, Object> responseMap = new Map<String, Object>();
        String Ids ='';
        string field = '';
        //accountgroupPricelist
        String junctionRecordquery ; // store the accountgroupPricelist in case of ccrz__E_PriceList__c and pricelist item in case of ccrz__E_Product__c
        if(currentsObject.sObjectAPIName__c == 'ccrz__E_PriceList__c'){
            junctionRecordquery = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,ccrz__AccountGroup__c,ccrz__Pricelist__c+from+ccrz__E_AccountGroupPriceList__c+WHERE+ccrz__AccountGroup__c+IN+';
            Ids = createInquery(objectNameToOld_NewId.get('ccrz__E_AccountGroup__c').keySet() , 500);
            field = 'ccrz__Pricelist__c';
        }else if (currentsObject.sObjectAPIName__c == 'ccrz__E_Product__c'){
            junctionRecordquery = objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q='+'Select+Id,ccrz__Product__c+from+ccrz__E_PriceListItem__c+WHERE+ccrz__Product__c+!=NULL+AND+ccrz__Pricelist__c+IN+';
        	Ids = createInquery(objectNameToOld_NewId.get('ccrz__E_PriceList__c').keySet() , 500);
            field = 'ccrz__Product__c';
        }
        // query on accountgroup pricelist to retrieve the pricelist IDs
        // query on  pricelist to retrieve the pricelist IDs
       
        //integer idCount = 0;//max 500
        
        Ids = '('+Ids+')';// store the accountgroup Ids in case of ccrz__E_PriceList__c and pricelist id in case of ccrz__E_Product__c
        junctionRecordquery = junctionRecordquery+Ids;
        System.debug('junctionRecordlist-->'+junctionRecordquery);
        responseMap = fetchSobejctData(junctionRecordquery);
        List<Sobject> junctionRecordList = new List<Sobject>();
        junctionRecordList = (List<Sobject>)JSON.deserialize(JSON.serializePretty(responseMap.get('records')), List<Sobject>.Class);
        String recordIds =''; // store the Pricelist Ids in case of ccrz__E_PriceList__c and products ids item in case of ccrz__E_Product__c
        Integer idCount = 0;//max 500
        //make set of Pricelist Ids
        for(Sobject accountGrpsobjectvar : junctionRecordList ){
            if(idCount == 500 )
                break;
            if(accountGrpsobjectvar.get(field) != null && accountGrpsobjectvar.get(field) != '' && (!recordIds.containsIgnoreCase( String.valueOf(accountGrpsobjectvar.get(field)) ))  ){                      
                idCount = idCount + 1;
                if(recordIds ==''){
                    recordIds =   '\''+accountGrpsobjectvar.get(field)+'\'';
                }else{
                    recordIds =recordIds+','+ '\''+accountGrpsobjectvar.get(field)+'\''; 
                }
                
            }
        }
        recordIds = '('+recordIds+')';
        System.debug('endpointUrl11--->'+endpointUrl);
        if(whereClause !=null && whereClause!='' ){
            endpointUrl=endpointUrl+'+AND+Id+IN+'+recordIds; 
            System.debug('endpointUrl21--->'+endpointUrl);
        }else{
            endpointUrl=endpointUrl+'+WHERE+Id+IN+'+recordIds; 
            System.debug('endpointUrl41--->'+endpointUrl);
        }
        responseMap.clear();
        return endpointUrl;
    }
    public Map<String, Object> fetchSobejctData(String endpointUrl ){
        System.debug('endpointUrl-fetchSobejctData->'+endpointUrl);
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET'); //grant-type:jwt-bearer  
        httpRequest.setHeader('Authorization', 'Bearer' + ' ' + accessToken); 
        httpRequest.setEndpoint(endpointUrl);  
        httpRequest.setTimeout(50000);  
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequest);  
        if (httpResponse.getStatusCode() == 200 ) { 
            Map<String, Object> responseMap = new Map<String, Object>();
            System.debug('response body-->'+httpResponse.getBody());
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
            return responseMap;
        }else{
            System.debug(' httpResponse ' + httpResponse.getBody() );  
            throw new CalloutException( httpResponse.getBody() );
            
        }
    }
    
    public void returnsObjectData(String endpointUrl , boolean isChild ,List<String> parentRelationInfo){
        try{
            String Ids =''; // soldtoAccountIds
            saveresultList = new List<Database.SaveResult>();
            System.debug('endpointUrl--->'+endpointUrl);
            system.debug('***********returnsObjectData**************');
            System.debug('currentsObject-------->'+currentsObject);
            System.debug('accessToken-------->'+accessToken);
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap = fetchSobejctData(endpointUrl);
            String nextQueryLink='';
            
            if (responseMap !=null && (!responseMap.isEmpty()) ) { 
                System.debug('***************************************8');
                
                
                for(String resString:responseMap.keySet()){
                    System.debug('-----output--->'+responseMap.get(resString));
                }
                if(responseMap.containsKey('nextRecordsUrl')){
                    nextQueryLink = (String)responseMap.get('nextRecordsUrl');
                }
                System.debug('responseMap->'+responseMap);
                System.debug('nextQueryLink->'+nextQueryLink);
                
                // insert the below list first set the Id to null
                if(!isChild){
                    System.debug('*******not child**********');
                    if(sobjectList.isEmpty()){
                        sobjectList = (List<Sobject>)JSON.deserialize(JSON.serializePretty(responseMap.get('records')), List<Sobject>.Class);
                    }else if( !sobjectList.isEmpty()){
                        sobjectList.addAll((List<Sobject>)JSON.deserialize(JSON.serializePretty(responseMap.get('records')), List<Sobject>.Class));
                    }
                    
                    System.debug('sobjectList-------->'+sobjectList);
                    
                    
                }else{
                    
                    Boolean isSoldToAccount =  false;
                    integer idCount = 0;
                    System.debug('child record-->'+responseMap.get('records'));
                    List<SObject> sobjectList1 = new List<SObject>();
                    List<SObject> sobjectList2 = new List<SObject>();
                    String soldToAccountIds = '';
                    List<Object> responseMapList =(List<Object>)JSON.deserializeUntyped( JSON.serializePretty(responseMap.get('records')) );
                    responseMap = null;
                    for(Object ss : responseMapList){
                        System.debug(ss+'=================================');
                        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ss));
                        for(String childKey :  m.keySet()){
                            System.debug(childKey+'--------------'+m.get(childKey));
                            if( m.get(childKey) != null && ( childKey.containsIgnoreCase('__r') || childKey == parentRelationInfo[2]  )   ){
                                Map<String, Object> m1 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize( m.get(childKey)));
                                sobjectList1 = (List<Sobject>)JSON.deserialize(JSON.serializePretty(m1.get('records')), List<Sobject>.Class);
                                
                                if( currentsObject.sObjectAPIName__c == 'Account' ){
                                    sobjectList1 = (List<Sobject>)JSON.deserialize(JSON.serializePretty(m1.get('records')), List<Sobject>.Class);
                                    for(Sobject sobjectvar : sobjectList1){
                                        System.debug('RecordtypeId-->'+sobjectvar.get('RecordtypeId'));
                                        if(isSoldToAccount){
                                            break;
                                        }
                                        if(sourceAccountRecordTypeNameToIdMap.get(String.valueOf(sobjectvar.get('RecordtypeId'))) == 'EC_SoldTo'){
                                            isSoldToAccount = true; // if anyone recordtype is sold to then do not insert ship to accounts
                                            sobjectList.add(sobjectvar);
                                            sobjectList2 =  new List<SObject>();
                                            if(Ids ==''){
                                                Ids =   '\''+String.valueOf(sobjectvar.get('Id'))+'\'';
                                            }
                                            Ids =Ids+','+ '\''+String.valueOf(sobjectvar.get('Id'))+'\'';
                                        }else{
                                            sobjectList2.add(sobjectvar);  // add only if all the related accounts to account group are shipto Accounts
                                            
                                        }
                                        System.debug('recordtypeIdtobeassigned'+targetAccountRecordTypeNameToIdMap.get(String.valueOf(sobjectvar.get('RecordtypeId'))));
                                        sobjectvar.put('RecordtypeId',targetAccountRecordTypeNameToIdMap.get( sourceAccountRecordTypeNameToIdMap.get(String.valueOf(sobjectvar.get('RecordtypeId')))));
                                    } 
                                    if(!isSoldToAccount){
                                        if(sobjectList.isEmpty()){
                                            sobjectList = sobjectList2;
                                        }else{
                                            sobjectList.addAll(sobjectList2);
                                        }  
                                    }
                                    isSoldToAccount = false;
                                    
                                }else{
                                    if(sobjectList.isEmpty()){
                                        sobjectList = (List<Sobject>)JSON.deserialize(JSON.serializePretty(m1.get('records')), List<Sobject>.Class);
                                    }else{
                                        sobjectList.addAll((List<Sobject>)JSON.deserialize(JSON.serializePretty(m1.get('records')), List<Sobject>.Class));
                                    }  
                                }
                                
                                System.debug('sobjectList=='+sobjectList[0]);
                            }
                        }
                        
                        
                    }
                    
                }
                System.debug('sobjectList--->'+sobjectList);
                System.debug('sobjectList--->'+sobjectList);
                
                responseMap = new Map<String, Object>();
                
            } else {  
                System.debug('***********RESPONSE MAP IS NULL******************' );
                
            }
            //if nextQueryLink is not blank that is more records exits
            if(nextQueryLink!=''){
                System.debug('again retreiuve data for link-->'+nextQueryLink);
                returnsObjectData(objAuthenticationInfo.instance_url+nextQueryLink,isChild,parentRelationInfo);
            }else{
                sobjectListClone=(List<Sobject>)JSON.deserialize(JSON.serializePretty(sobjectList), List<Sobject>.Class);
                System.debug('sobjectListClone--->'+sobjectListClone.size());
                System.debug('sobjectList--->'+sobjectList.size());
                System.debug('parentRelationInfo****----->>>>>>>'+parentRelationInfo);
                for(Sobject SobjectIns : sobjectList){
                    //System.debug('set the sobjectId to null');
                    SobjectIns.Id = null;
                    if(currentsObject.sObjectAPIName__c == 'ccrz__E_Product__c'){
                        // SobjectIns.put('lastmodifieddate',null); 
                    }
                    if(isChild || (currentsObject.sObjectAPIName__c == 'ccrz__E_Menu__c'  || 
                                   currentsObject.sObjectAPIName__c == 'ccrz__E_ProductMedia__c' 
                                   || currentsObject.sObjectAPIName__c == 'ccrz__E_ProductSpec__c' 
                                   || currentsObject.sObjectAPIName__c == 'ccrz__E_ProductMedia__c' || currentsObject.sObjectAPIName__c == 'ccrz__E_ProductCategory__c' 
                                   || currentsObject.sObjectAPIName__c == 'ccrz__E_ConfigurationMeta__c'
                                   || currentsObject.sObjectAPIName__c == 'ccrz__E_Configuration__c') ){
                                       System.debug('parentRelations--->'+parentRelations);
                                       for(String parentRelationInfoVar:parentRelations){
                                           parentRelationInfo = parentRelationInfoVar.split('/');
                                           System.debug('parentRelationInfo--->'+parentRelationInfo);
                                           System.debug('SobjectIns.get(parentRelationInfo[1])--'+SobjectIns.get(parentRelationInfo[1]));
                                           if( SobjectIns.get(parentRelationInfo[1]) != null ){
                                               SobjectIns.put(parentRelationInfo[1] , (objectNameToOld_NewId.get(parentRelationInfo[0])).get((String)SobjectIns.get(parentRelationInfo[1])) );
                                           } 
                                       }
                                   }
                }
                
                // fetch the childs of sold of Accounts 
                if(currentsObject.sObjectAPIName__c == 'Account'){
                    System.debug('fetch the child Account os sold to Accounts');
                    getChildAccounts(Ids,sobjectList,sobjectListClone);
                }else{
                    try{
                       List<sObject> sObjectList = deleteOldRecords();
                        if(!sObjectList.isEmpty()){
                           // database.delete(sObjectList,false);
                        }
                    }catch(Exception e){
                        System.debug('get exeption delete records on line number-->'+e.getLineNumber()+' error is-->'+e.getMessage());
                        
                    }
                    saveresultList = Database.insert(sobjectList, false); // containing new Ids
                    System.debug('saveresultList--->'+saveresultList.size()+'------'+sobjectList.size()+'--new records Inserted-->'+sobjectListClone.size());
                    Map<String,String> oldToNewIdMap = new Map<String,string>();
                    if( objectNameToOld_NewId.containsKey(currentsObject.sObjectAPIName__c) ){
                        oldToNewIdMap = objectNameToOld_NewId.get(currentsObject.sObjectAPIName__c);
                    }
                    for(Integer counter = 0 ; counter < saveresultList.size() ; counter++){
                        System.debug(counter+'---**---'+saveresultList[counter].isSuccess());
                        System.debug('sobjectListClone--'+sobjectListClone[counter]+'--sobjectList--'+ sobjectList[counter]);
                        System.debug('--sobjectListClone--'+sobjectListClone[counter]+'--sobjectList--'+ sobjectList[counter]);
                        
                        if( saveresultList[counter].isSuccess() ){
                            oldToNewIdMap.put(sobjectListClone[counter].Id , sobjectList[counter].Id);
                        }else{
                            System.debug('error is--->'+saveresultList[counter].geterrors()[0].getMessage());
                        }
                    }
                   
                    if(currentsObject.sObjectAPIName__c != 'ccrz__E_ProductCategory__c' || currentsObject.sObjectAPIName__c != 'ccrz__E_ProductSpec__c'
                       || currentsObject.sObjectAPIName__c != 'ccrz__E_ProductMedia__c' || currentsObject.sObjectAPIName__c != 'ccrz__E_RelatedProduct__c'
                       || currentsObject.sObjectAPIName__c != 'ccrz__E_Menu__c' || currentsObject.sObjectAPIName__c != 'ccrz__E_Configuration__c'
                       || currentsObject.sObjectAPIName__c != 'ccrz__E_PageLabel__c' || currentsObject.sObjectAPIName__c != 'ccrz__E_AccountGroupPriceList__c'){
                           objectNameToOld_NewId.put(currentsObject.sObjectAPIName__c ,oldToNewIdMap );// scobject to Old to new Id map
                       }
                    
                    
                }
                
            }
            System.debug('Limits.getHeapSize()--->'+Limits.getHeapSize() +'==Limits.getLimitHeapSize()--'+Limits.getLimitHeapSize());   
        }catch(Exception e){
            System.debug('get exeption on line number-->'+e.getLineNumber()+' error is-->'+e.getMessage());
        }
    }
    public List<sObject> deleteOldRecords(){
        String sObjectQuery = 'SELECT Id FROM '+currentsObject.sObjectAPIName__c+' Limit 5000';
        System.debug('sObjectQuery--->'+sObjectQuery);
        List<sObject> sObjectList = Database.query(sObjectQuery);
        System.debug('sObjectQuery--size--->'+sObjectList.size());
        return sObjectList;
        //delete sObjectList;
        
    }
    public void getChildAccounts(String Ids , List<Sobject> sobjectListparent , List<Sobject> sobjectListparentClone){
        if( Ids!='' && Ids!=null)
            Ids = '('+Ids+')';
        sobjectList = new List<Sobject>();
        sobjectListClone = new List<Sobject>();
        objAuthenticationInfo = getAccessToken();
        accessToken = objAuthenticationInfo.access_token;
        String endpointUrl =  objAuthenticationInfo.instance_url+'/services/data/v49.0/query/?q=Select+Id,(Select+Id,ParentId,'+currentsObject.Fields__c+'+FROM+ChildAccounts)'+'+FROM+'+currentsObject.sObjectAPIName__c+'+WHERE+ID+IN'+Ids;
        Map<String, Object> responseMap = new Map<String, Object>(); 
        System.debug('Ids------------------>'+Ids);
        if( Ids!='' && Ids!=null){
            System.debug('FETCH CHDILD ACCOUNTS');
            responseMap = fetchSobejctData(endpointUrl);
            
        }
        
        try{
            List<sObject> sObjectList = deleteOldRecords();
            if(!sObjectList.isEmpty()){
                //database.delete(sObjectList,false);
            }
        }catch(Exception e){
            System.debug('get exeption delete records on line number-->'+e.getLineNumber()+' error is-->'+e.getMessage());
            
        }
        //parentAccountinserted here
        createOldToNewIdMap(sobjectListparent,sobjectListparentClone);
        
        System.debug('responseMap---getChildAccounts>'+responseMap);
        if (responseMap !=null && (!responseMap.isEmpty()) ) { 
            List<Object> responseMapList =(List<Object>)JSON.deserializeUntyped( JSON.serializePretty(responseMap.get('records')) );
            System.debug('responseMapList--->'+responseMapList);
            responseMap = null;
            for(Object ss : responseMapList){
                System.debug(ss+'=================================');
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ss));
                for(String childKey :  m.keySet()){
                    System.debug(childKey+'--------------'+m.get(childKey));
                    if( m.get(childKey) != null && ( childKey.containsIgnoreCase('ChildAccounts')   )   ){
                        Map<String, Object> m1 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize( m.get(childKey)));
                        if(sobjectList.isEmpty()){
                            sobjectList = (List<Sobject>)JSON.deserialize(JSON.serializePretty(m1.get('records')), List<Sobject>.Class);
                        }else{
                            sobjectList.addAll((List<Sobject>)JSON.deserialize(JSON.serializePretty(m1.get('records')), List<Sobject>.Class));
                        }
                        System.debug('sobjectList=='+sobjectList[0]);
                    }
                }
            }
        }
        sobjectListClone=(List<Sobject>)JSON.deserialize(JSON.serializePretty(sobjectList), List<Sobject>.Class);
        for(Sobject SobjectIns : sobjectList){
            SobjectIns.Id = null;
            SobjectIns.put('ParentId',objectNameToOld_NewId.get('Account').get( String.valueOf(SobjectIns.get('ParentId')) ));
            SobjectIns.put('ccrz__E_AccountGroup__c',objectNameToOld_NewId.get('ccrz__E_AccountGroup__c').get( String.valueOf(SobjectIns.get('ccrz__E_AccountGroup__c')) ) );
            System.debug('SobjectInsFORCHILDACCOUNT___------>'+SobjectIns); 
            SobjectIns.put('RecordtypeId',targetAccountRecordTypeNameToIdMap.get( sourceAccountRecordTypeNameToIdMap.get(String.valueOf(SobjectIns.get('RecordtypeId')))));
            
        }
        if(!sobjectList.isEmpty())
            createOldToNewIdMap(sobjectList,sobjectListClone);
        
    }
    public void createOldToNewIdMap(List<Sobject> sobjectListparent , List<Sobject> sobjectListparentClone){
        saveresultList = new List<Database.SaveResult>();
        Map<String,String> oldToNewIdMap = new Map<String,string>();
        if( objectNameToOld_NewId.containsKey(currentsObject.sObjectAPIName__c) ){
            oldToNewIdMap = objectNameToOld_NewId.get(currentsObject.sObjectAPIName__c);
        }
        saveresultList = Database.insert(sobjectListparent,false);
        
        for(Integer counter = 0 ; counter < saveresultList.size() ; counter++){
            System.debug(counter+'---**---'+saveresultList[counter].isSuccess());
            System.debug('sobjectListClone--'+sobjectListparentClone[counter]+'--sobjectList--'+ sobjectListparent[counter]);
            System.debug('--sobjectListClone--'+sobjectListparentClone[counter]+'--sobjectList--'+ sobjectListparent[counter]);
            
            if( saveresultList[counter].isSuccess() ){
                oldToNewIdMap.put(sobjectListparentClone[counter].Id , sobjectListparent[counter].Id);
            }else{
                System.debug('error is--->'+saveresultList[counter].geterrors()[0].getMessage());
            }
        }
        objectNameToOld_NewId.put(currentsObject.sObjectAPIName__c,oldToNewIdMap);
    }
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
    
    
    
    public static OAuth getAccessToken(){
        
        try{
            List<Post_Refresh_Metadata_Config__mdt> postRefreshMetadataConfigList = new List<Post_Refresh_Metadata_Config__mdt>();
            postRefreshMetadataConfigList = [Select Auth_Token_Url__c, Consumer_Key__c, Consumer_Secret__c, Username__c, Password__c, Request_Body__c, Source_SFDC_Url__c, Private_Key__c From Post_Refresh_Metadata_Config__mdt where DeveloperName=:'Refresh_Configuration_QA'];
            
            
            final  String ENDPOINT_URL = postRefreshMetadataConfigList[0].Auth_Token_Url__c; // 'https://test.salesforce.com/services/oauth2/token';
            final  String REQUEST_BODY = postRefreshMetadataConfigList[0].Request_Body__c; //'grant_type=password&client_id={0}&client_secret={1}&username={2}&password={3}';
            final  String USERNAME = postRefreshMetadataConfigList[0].Username__c; //'nikhil.soni@ecolab.com.connect.devec1';
            final  String PASSWORD = postRefreshMetadataConfigList[0].Password__c; //'Enjoy@11';
            final  String CONSUMER_KEY = postRefreshMetadataConfigList[0].Consumer_Key__c; //'3MVG9er.T8KbeePSJ4H9L_W6l2F_siEKCkRnNiY3QTjd3BQS6slEXakaofRLznFYyAMBzVx.fUaMUqo7Y3QEW';
            final  String CONSUMER_SECRET = postRefreshMetadataConfigList[0].Consumer_Secret__c; //'1A3D6F50F248C9AA68813A0ADB06E46C83F16735E5847EAA9D1083CCAB4F3A08';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT_URL);
            req.setMethod('POST');          
            Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader); 
            req.setBody(String.format(REQUEST_BODY ,new string[]{CONSUMER_KEY,CONSUMER_SECRET, USERNAME,PASSWORD}));
            req.setTimeout(60000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('response-->'+res.getbody());
            OAuth objAuthenticationInfo = (OAuth)JSON.deserialize(res.getbody(), OAuth.class);
            return objAuthenticationInfo;
        }catch(CallOutException ce){
            throw ce;
        }
    }
    global class OAuth{
        public String id{get;set;}
        public String issued_at{get;set;}
        public String instance_url{get;set;}
        public String signature{get;set;}
        public String access_token{get;set;}    
    }
    
}
