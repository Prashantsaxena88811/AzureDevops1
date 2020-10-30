public without Sharing class EC_Unsubscribe {
    
    public EC_Unsubscribe(){
        
    }
    
    public void updateContact(){
        String contactEmail = apexpages.currentpage().getparameters().get('Email');
        String contactId = apexpages.currentpage().getparameters().get('contactId');
        if(contactEmail != NULL && contactId != NULL){
            List<Contact> ContactList = [select Id, Name, Email, Unsubscribe__c from Contact where Id = :contactId and Email =:contactEmail];
            
            if(ContactList.size() >= 1){
                for(Contact cnt : ContactList){
                    cnt.Unsubscribe__c = TRUE;
                }
                
                update ContactList;
            }    
        }
        
    }
}