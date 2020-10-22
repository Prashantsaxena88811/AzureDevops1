/* Trigger Name    : EC_SetAccount_BillingNumber 
 * Description      : Trigger to set the Billing account number field of account on Insert
 * Created By       :Viraj 
 * Created On       :2019-Sep-12
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj             2019-Sep-12             BC-76559        Created the class   
 *
 */
trigger EC_SetAccount_BillingNumber on Account (before insert) {
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert ){
             updateAccount();
        }//End of isInsert condition
        
    }//End of isBefore condition
     /***************************************************************************************************************************************
  Constructor Name : updateAccount
  Description : Function to set the EC_Billing_Account_Number__c field
  Return type : void
 *************************************************************************************************************************************/
    public static void updateAccount(){
        
        try{
            List<Account> accList = new  List<Account>();
            Boolean toUpdate = false;
            List<RecordType> rectype = [SELECT Name from RecordType where id =:Trigger.new[0].RecordTypeId ];
            List<Account> parentAccount = [SELECT id,EC_Account_Number__c,RecordType.Name,EC_Division__c,EC_Billing_Account_Number__c,ccrz__SourceSystem__c from Account where id =:Trigger.new[0].ParentId];
            for (Account acc : Trigger.new) {
                String sourceString = '';
                if(acc.ccrz__SourceSystem__c != null && acc.ccrz__SourceSystem__c!=''){
                    sourceString = acc.ccrz__SourceSystem__c + '/';
                }
                if(acc.EC_Account_Number__c != null && rectype[0].Name == Label.EC_Account_SoldTo &&  !acc.EC_Account_Number__c.contains('/')  && (acc.EC_Division__c == 'WATER' || acc.EC_Division__c == 'ENERGY' || acc.EC_Division__c == 'PAPER' || (parentAccount.size()>0 && ( parentAccount[0].EC_Division__c == 'WATER' || parentAccount[0].EC_Division__c == 'ENERGY' || parentAccount[0].EC_Division__c == 'PAPER')))) {
                    acc.EC_Billing_Account_Number__c = sourceString + acc.EC_Account_Number__c.replaceAll('^0+','');
                    toUpdate = true;
                }else if(acc.EC_Account_Number__c != null && rectype[0].Name == Label.EC_Account_ShipTo  && acc.EC_Account_Number__c.contains('/')  && (acc.EC_Division__c == 'WATER' || acc.EC_Division__c == 'ENERGY' || acc.EC_Division__c == 'PAPER'  ||(parentAccount.size()>0 && (  parentAccount[0].EC_Division__c == 'WATER' || parentAccount[0].EC_Division__c == 'ENERGY' || parentAccount[0].EC_Division__c == 'PAPER')))){
                    acc.EC_Billing_Account_Number__c = sourceString + acc.EC_Account_Number__c.split('/')[1].replaceAll('^0+','');
                    toUpdate = true;
                }
                if(acc.EC_Division__c!=null && (acc.EC_Division__c == 'WATER' || acc.EC_Division__c == 'ENERGY' || acc.EC_Division__c == 'PAPER' ) && acc.ShippingCountry!=null && Label.EC_UnitedStates.contains(acc.ShippingCountry)){
                    acc.EC_PaymentMode__c = Label.EC_Payment_Mode_BOTH;
                }else{
                    acc.EC_PaymentMode__c = Label.EC_Payment_Mode_PO;
                }
                accList.add(acc);
            }
            if(toUpdate){
                update accList;
            }
            
        }Catch (Exception ex) {
            System.debug('Exception occured while invoking Marketing Cloud Connector Triggered Send '+ ex.getMessage());
        }//End of Catch Block
        
    }//End of Method  
    
}