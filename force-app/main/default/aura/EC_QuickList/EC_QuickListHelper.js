({
    // error handling for quicklisted products
    showError : function(component){
        if(component.get("v.quickListCount")){
                    component.set("v.emptyQuickList", true);
                }else{
                    var cmpTarget = component.find('quickListDocument');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
    },
    // fetch quicklisted products
	getQuickList : function(component, event, helper) {
        
        var url = window.location.href;
		var valueEntered = /term=([^&]+)/.exec(url)[1];
        valueEntered = decodeURIComponent(valueEntered);
         var decodedValue = valueEntered.replace(/\+/g, '%20'); 
        decodedValue = decodeURIComponent(decodedValue)
        var action = component.get("c.getQuickListAura");
        action.setParams({
			searchText:valueEntered
		});
        
        
        
        component.set("v.SearchTextField",decodedValue);
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
                var retLength = Object.keys(ret).length;
                
                if(ret.length){
                    component.set("v.emptyQuickList", true);
                }else{
                    var cmpTarget = component.find('quickListDocument');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
                console.log('Return value in the sample component is +++++++++'+JSON.stringify(ret))
                var quickLists = [];
                for ( var key in ret ) {
                    quickLists.push({value:ret[key], key:key});
                }
				component.set("v.QuickList", quickLists);
                var setQCCount = component.getEvent("setAttribute");
                setQCCount.setParams({
                    "quicklistattributeValue":retLength,
                    "activeTab":"quicklist"                  
                });
                setQCCount.fire();
            }
        });
        $A.enqueueAction(action);
    }
})