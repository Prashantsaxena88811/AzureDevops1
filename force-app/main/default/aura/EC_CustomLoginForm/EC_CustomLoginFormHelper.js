({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    // fetch community URL
    getCommunityUrl : function(component,event,helper){
        var action = component.get("c.getCommunityURL");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set('v.communityURL', response.getReturnValue());
            }else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
    },
    // Login Function
    handleLogin: function (component, event, helpler) {
        var startUrl = component.get("v.startUrl");
        console.log(startUrl);
        if(!startUrl){
            startUrl = '';
        }
        startUrl = decodeURIComponent(startUrl);
        console.log('Start Url--'+startUrl);
        
        var action = component.get("c.getSamlSSOUrl");
        action.setParams({
            startUrl : startUrl
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
            }else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    // Fetch Community self register URL
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    // outage helper
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