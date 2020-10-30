({
	onReportSelectHelper : function(component, event, helper) {
        component.set("v.serviceDetails",event.getParam("selectedServiceReport"));
		component.set("v.displayElement",true);
	}
})