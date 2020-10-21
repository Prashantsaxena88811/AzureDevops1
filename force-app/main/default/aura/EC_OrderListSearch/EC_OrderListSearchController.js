({
    // initialize function on page load
	init : function(component, event, helper) {
        
        var searchTypeOptions= [
                        { id: "orderBy", label: 'Order Number', selected: true },
                    { id: "dateRange", label: 'Date Range'}
                ];
		component.set('v.searchTypeOptions', searchTypeOptions);
        component.set('v.loaded', false);
       helper.showError(component);
      helper.compVisible(component);
	},
    // view invoice of order
    viewInvoice : function(component, event, helper){
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
            "url":"invoice" 
        });
        eUrl.fire();
    }
})