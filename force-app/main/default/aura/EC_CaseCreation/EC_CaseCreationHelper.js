({
    
    outageHelper : function(component){
        var action = component.get("c.outageRedirect");
         action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
                if(!ret){
                    var outageURL = $A.get("$Label.c.EC_OutageRedirect");
                    window.open(outageURL, "_self"); 
                } else {
                    component.set("v.showSpinner", false);
                }
            } 
        });
        
         $A.enqueueAction(action);
    
    }

	
    
})