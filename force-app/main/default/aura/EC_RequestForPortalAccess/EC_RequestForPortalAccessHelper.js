({
	createCaseHelper : function(component, event, helper) {
	    var roleObj = component.get("v.roles"),
            btnName = component.get("v.selectRoleName"),
            action = component.get("c.assigningPermissionSet");
        action.setParam("conRole", btnName);
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) { 
                component.set('v.currentRole',rtnValue);
                component.set("v.registerBtn", false);
               
            } 
        });
        $A.enqueueAction(action);
        
      if(component.get("v.caseCreation")){
            //112382 - check if the current url has the landing page param
            var landingPageParam = $A.get("$Label.c.EC_LandingPageParam");
          	var landingPageParamValArray = new RegExp('[\?&]' + landingPageParam + '=([^&#]*)').exec(window.location.search);
            if(landingPageParamValArray !== null){
                console.log('redirecting to home page because of landing page param in URL');
                window.open("/s","_self"); 
            }else{
                $A.get('e.force:refreshView').fire();
            }             
        }else{
              window.open("/s","_self"); 
        }
	},
    getRoles: function(component, event, helper){
        var action = component.get("c.userRoles");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.roles',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    paymentAccessHelper : function(component, event, helper){
        console.log('one');
        var action = component.get("c.payerpermission");
        action.setCallback(this, function(response) {
            console.log('2');
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                console.log('3');
                var ret = response.getReturnValue();
                console.log('response-->'+ret);
                if(ret === true){
                    component.set('v.payerportalpermission',ret);
                    
                }
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    caseCreationhelper : function(component, event, helper){
        console.log('one11');
        component.set("v.requestBtn", true);
        var action = component.get("c.caseCreationPayer");
        var toastEvent = $A.get("e.force:showToast");
        action.setCallback(this, function(response) {
            console.log('2111');
            if(response.getState() == "SUCCESS"){
                toastEvent.setParams({
                    "message": "Request sent. You will be notified when your request is complete."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();

            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    buttonChange : function(component, event, helper){
        console.log('one');
        var action = component.get("c.conditioncheckPayer");
        action.setCallback(this, function(response) {
            console.log('2');
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                console.log('3');
                var ret = response.getReturnValue();
                console.log('response-->'+ret);
                component.set('v.caseType',ret);
            }
        });
        
        $A.enqueueAction(action);
        
    },
     caseClosure : function(component, event, helper){
        var action = component.get("c.Caseclosureafterpermissionsetassigned");
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                console.log('3');
                var ret = response.getReturnValue();
                console.log('response-->'+ret);
                component.set('v.caseStatus',ret);
            }
        });
        
        $A.enqueueAction(action);
        
    }
    
})