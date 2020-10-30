({
	getPermissions : function(component) {
		var baseURL = window.location.protocol + "//" + window.location.hostname;
		component.set("v.baseURL", baseURL);

		var action = component.get("c.getUserPermissions");
		action.setCallback(this, function(response){
			var rtnValue = response.getReturnValue();

			if(response.getState() === "SUCCESS") {
				component.set('v.enableDSR', rtnValue.enableDSR);
				component.set('v.enableIntelligence', rtnValue.enableIntelligence);
			}
			else if (response.getState() === "INCOMPLETE") {
				console.log("Error Occured!!");
			}
			else if (response.getState() === "ERROR") {
				console.log("Error Occured!!");
			}
		});

		$A.enqueueAction(action);
	}
})