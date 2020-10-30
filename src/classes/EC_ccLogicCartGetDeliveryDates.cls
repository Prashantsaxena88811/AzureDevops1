/* Class Name    : EC_ccLogicCartGetDeliveryDates
 * Description      :Class to extend the Cloudcraze Logic Class ccLogicCartGetDeliveryDates
 * Created By       :Viraj  
 * Created On       :2019-Jul-24
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Jul-24        BC-76559        Created the class   
 *
 */
global virtual with sharing class EC_ccLogicCartGetDeliveryDates extends ccrz.ccLogicCartGetDeliveryDates{
     
     @TestVisible static Date today = date.today();
     
    /***************************************************************************************************************************************
  Method Name : getDeliveryDates
  Description : getDeliveryDates sets the excluded dates in the date picker in order info page
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global virtual override Map<String, Object> getDeliveryDates(Map<String, Object> inputData) {
        
        Map<String, Object> retData;
        retData = new Map<String, Object>();
        Integer availableDate = 1;
        if(!Test.isRunningTest()){
            retData = super.getDeliveryDates(inputData);
        }else{
            retData = inputData;
        }
        List<String> excDates = new List<String>();
        List<Account> shipToAccount= [SELECT id,EC_Division__c,EC_Account_Number__c,RecordType.Name,RecordTypeId,ParentId,BillingAddress,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,ShippingAddress,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet from Account where (Id=: ccrz.cc_CallContext.effAccountId)];
        String division = shipToAccount[0].EC_Division__c.replace(' & ','and');
        List<EC_ReqDelivery_Date_LeadTime__mdt> reqDate = [SELECT id,EC_Days__c,EC_Date_Type__c,Rush_Order_Days__c, DeveloperName FROM EC_ReqDelivery_Date_LeadTime__mdt where DeveloperName= :division.replace(' ','_')];
        //Date excDays = today-1;
        Date excDays = today;
        DateTime myexcDays;
        if(reqDate.size()>0){
            Integer totalDays = Integer.valueOf(reqDate[0].EC_Days__c) + availableDate;
            retData.put('RUSH_ORDER_DAYS',0);
            if (reqDate[0].Rush_Order_Days__c != null) {
               totalDays = Integer.valueOf(reqDate[0].Rush_Order_Days__c) + Integer.valueOf(reqDate[0].EC_Days__c) + availableDate; 
               retData.put('RUSH_ORDER_DAYS',Integer.valueOf(reqDate[0].Rush_Order_Days__c) );
            }
            for(Integer i = 0;i<totalDays;i++){
                if(reqDate[0].EC_Date_Type__c == Label.EC_Business_Days){
                    while(true){
                        excDays = excDays.addDays(1) ;
                        myexcDays = (DateTime) excDays;
                        ccrz.ccLog.log('myexcDays '+myexcDays.formatGMT('EEE'));
                        if(myexcDays.formatGMT('EEE')=='Sat' || myexcDays.formatGMT('EEE')=='Sun'){
                            continue;
                        }else{
                            break;
                        }
                    }
                }else{
                    excDays = excDays.addDays(1) ;
                    myexcDays = (DateTime) excDays;
                }
                ccrz.ccLog.log('excdays'+excDays );
                integer excday= excDays.day();
                integer excmonth= excDays.month();
                integer excyear= excDays.year();
                string excsday= String.valueOf(excday);
                string excsmonth= String.valueOf(excmonth);
                string excsyear= String.valueOf(excyear);
                string days;
                if(excday<=9){
                    days='0'+excsday;
                }
                else{
                    days=excsday;
                }
                ccrz.ccLog.log('excsday'+days+'excmonth'+excsmonth+'excsyear'+excsyear);
                string exeSDays=excsyear+'-'+excsmonth+'-'+days;
                excDates.add(String.valueOf(exeSDays));
                
            }
        }
        retData.put(ccrz.cc_api_DeliveryDate.DAYS_FILTER,new List<String>{reqDate[0].EC_Date_Type__c });
        retData.put(ccrz.cc_api_DeliveryDate.EXCLUDED_DATES,excDates);
        retData.put('HOT_SHOT_DAYS', Integer.valueOf(reqDate[0].EC_Days__c));
        ccrz.ccLog.log('retData34'+retData);
        return retData;
    }
}