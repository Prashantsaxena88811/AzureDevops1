trigger EC_CaseSalesRep on Case (After Insert) {
    if(Trigger.isAfter) {
 		List<Case> newCases = new List<Case>();
    	List<Id> ids = new List<Id>();
		Boolean isFutureRequired = false;
    	for(Case sObj : Trigger.New){
			if(sObj.Type == 'Request Service') {
				ids.add(sObj.Id);
				 isFutureRequired = true;
			}
   		}
   		if (ids != null && isFutureRequired) {
            EC_CaseTriggerHandler.doFutureCallout(ids);
		}      
    }	
}