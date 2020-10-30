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
		//Done by Graytitude team to run assignment rules when case is created from community.
        //Due to standard limitation, through community once case is created then Assignment rule don't fire automatically. 
        //Graytitude Team   14.09.2020   doAssignmentRulesRun - method added to perform assignment rules on community related cases.         
        EC_CaseTriggerHandler.doAssignmentRulesRun(Trigger.newMap);  
    }	
}