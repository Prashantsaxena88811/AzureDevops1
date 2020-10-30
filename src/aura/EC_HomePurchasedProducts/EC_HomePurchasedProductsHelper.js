({
    // Check Basic/Buyer Permissions
    isBasicBuyerCheck: function (component) {
        var action = component.get("c.isBasicBuyerCheck");
        action.setCallback(this, function (response) {
            var rtnValue = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                component.set("v.isBasicBuyerCheck", rtnValue);
            }
            else {
                console.log('Error Occured!!');
            }
        });
        $A.enqueueAction(action);
    },
    
    // cart page redirection
    cartRedirect: function (component, event, helper) {
        var orderItemId = event.getSource().get('v.value');
        var action = component.get("c.getCartURL");
        action.setParam("orderItemId", orderItemId);
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            window.location.reload();
        });
        $A.enqueueAction(action);
	},
    // is component is visible
    isCompVisible : function(component) {

        var action = component.get("c.compVisible");
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
                var i;
              for (i=0;i<ret.length;i++)  {

                if(ret[i].permName == $A.get("$Label.c.EC_Buy_Online")){
                 component.set("v.buyOnline", ret[i].permVal);
                }
                 else if(ret[i].permName == $A.get("$Label.c.EC_View_Price")){
                 component.set("v.viewPrice", ret[i].permVal);
                }
               }

            }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function(component, event) {
        $A.util.addClass(component.find("homePageSpinner"), "slds-show");
        $A.util.removeClass(component.find("homePageSpinner"), "slds-hide");
    },
    hideSpinner: function(component, event) {
        $A.util.removeClass(component.find("homePageSpinner"), "slds-show");
        $A.util.addClass(component.find("homePageSpinner"), "slds-hide");
    },
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