({
	getOauthClientCredential : function(component, event, helper) {
        helper.getDashboards(component);
        var action = component.get("c.OAuthTokenClientCredentials");            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.clientCredAccessToken",response.getReturnValue());
                helper.getDataSet(component, event, helper);
            }
        });
        $A.enqueueAction(action);
	}
})