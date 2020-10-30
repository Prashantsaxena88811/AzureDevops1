({
    doInit : function(component, event,helper){    
        helper.getURLParams(component, event,helper);
        helper.getvalidateUser(component, event,helper);
        
        //This check is used to identify Self-Registration/ CDM Flow 
        if(!component.get("v.fromSelfReg")){
            helper.popupvalue(component, event, helper);
            helper.setProgressFlag(component, event, helper);
        }
    },
    
    validateSelection : function(component, event,helper) {
        var fieldVal = component.find("mygroup").get("v.value");
        if(fieldVal != undefined || fieldVal != Null)
        {
            component.set("v.ContinueButton",false);
        }
    },

    onContinue: function (component, event, helper) {
        var accType = component.find("mygroup").get("v.value");
        let userEmail = component.get("v.username");
        component.set("v.fromSelfReg",false);
        helper.setProgressFlag(component, event, helper);
        helper.popupvalue(component,event,helper);
        helper.createDirectoryUser(userEmail, accType, component, event, helper);
    }
})