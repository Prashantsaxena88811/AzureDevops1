public without Sharing class EC_ServiceRequestAssignmentRule {
    
    public case caseRules (case caseRec) {
            Database.DMLOptions dmlItem = new Database.DMLOptions();
            dmlItem.AssignmentRuleHeader.useDefaultRule = true;
            caseRec.setOptions(dmlItem);
        	system.debug('caseRec.setOptions:'+caseRec);	
            return caseRec;
    }
    
}