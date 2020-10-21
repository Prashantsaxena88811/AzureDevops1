({
    getURLParams: function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); 
        var sURLVariables = sPageURL.split('&'); 
        var sParameterName, userName, i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); 
            if (sParameterName[0] === 'username') { 
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                userName = sParameterName[1];
            }
            else if(sParameterName[0] === 'c' && sParameterName[1] === '1') {
                component.set("v.fromSelfReg", true);
            }
        }
        component.set("v.username", userName);
    },

    registerRedirect: function(component, event, helper) {
        component.set('v.isModalOpen',false);
        var baseUrl = window.location.href ;
        baseUrl = baseUrl.replace('completeregistration','login');
        window.open(baseUrl, '_self');
    },

    popupvalue: function(component, event, helper) {
        component._interval = setInterval($A.getCallback(function () {
            var progress = component.get('v.progress');
            component.set('v.progress', progress === 100 ? 0 : progress + 1);
      }), 200); 
    },

    getvalidateUser : function(component, event, helper) {
        var selfReg = component.get("v.fromSelfReg") ? '1' : '0';
        var userEmail = component.get("v.username");

        var action = component.get("c.validateUser");
        action.setParams({
            "userEmail" : userEmail,
            "source" : selfReg
        });

        action.setCallback(this, function(response) {
            console.log('getvalidateUser Response: '+JSON.stringify(response.getReturnValue()));
            var state = response.getState();
            var rtnValue = JSON.parse(response.getReturnValue());
            if(state === "SUCCESS") {
                if(rtnValue.caseStatus.toLowerCase() === 'new' && rtnValue.status == '1001') {
                    component.set("v.firstName", rtnValue.firstName);
                    component.set("v.lastName", rtnValue.lastName);

                    if(component.get("v.fromSelfReg")){
                        component.set("v.isCompleteRegistration", true);
                    } else if(rtnValue.accountType.toLowerCase() === 'all') {
                        component.set('v.progress',100);
                        clearInterval(component._interval);
                        component.set("v.isModalOpen",false);
                        component.set("v.isCompleteRegistration", true);
                    } else if(rtnValue.accountType.toLowerCase() === 'localaccount') {
                        helper.createDirectoryUser(userEmail, 'LocalAccount', component, event, helper);
                    } else if(rtnValue.accountType.toLowerCase() === 'federated') {
                        helper.createDirectoryUser(userEmail, 'federated', component, event, helper);
                    } else {
                        component.set('v.progress',100);
                        clearInterval(component._interval);
                        component.set("v.isModalOpen",false);
                        helper.displayPopUp(component, event, helper, rtnValue.status, rtnValue.label, rtnValue.message);
                    }
                } else if(rtnValue.caseStatus.toLowerCase() === 'closed'){
                    component.set('v.progress',100);
                    clearInterval(component._interval);
                    component.set("v.isModalOpen",false);
                    helper.displayPopUp(component, event, helper, rtnValue.status, rtnValue.label, rtnValue.message);
                } else {
                    component.set('v.progress',100);
                    clearInterval(component._interval);
                    component.set("v.isModalOpen",false);
                    helper.displayPopUp(component, event, helper, rtnValue.status, rtnValue.label, rtnValue.message);
                }
            } else if (state === "INCOMPLETE") {
                if(component.get("v.isProgressing") == true)
                    {
                    component.set('v.progress',100);
                    clearInterval(component._interval);
                    component.set("v.isModalOpen",false);
                    helper.displayPopUp(component, event, helper, rtnValue.status, rtnValue.label, rtnValue.message);
                    }
            } else if (state === "ERROR") {
                 console.log("Unknown error");
                component.set('v.progress',100);
                clearInterval(component._interval);
                component.set("v.isModalOpen",false);
            }
            });
        $A.enqueueAction(action); 
    },
    
    createDirectoryUser : function(userEmail, accType, component, event, helper){
        let fName = component.get("v.firstName");
        let lName = component.get("v.lastName");

        var action = component.get("c.createDirectoryUser");
        action.setParams({
            "userEmail" : userEmail,
            "accountType" : accType,
            "firstName" : fName,
            "lastName" : lName
        });
        action.setCallback(this, function(response){
            console.log('createDirectoryUser Response: '+JSON.stringify(response.getReturnValue()));
            var state = response.getState();
            var rtnValue = JSON.parse(response.getReturnValue());
            if(state === "SUCCESS") {
                if(rtnValue != null) {
                    if(component.get("v.isProgressing") == true) {
                        component.set('v.progress',100);
                        clearInterval(component._interval);
                        component.set("v.isModalOpen",false);
                        helper.displayPopUp(component, event, helper, rtnValue.status, rtnValue.label, rtnValue.message);
                   }
                }
            }
            else if(state === "INCOMPLETE") {
                if(component.get("v.isProgressing") == true) {
                   component.set('v.progress',100);
                   clearInterval(component._interval);
                   component.set("v.isModalOpen",false);
                }
            }
            else if(state === "ERROR") {
                console.log("Unknown error");
                component.set('v.progress',100);
                clearInterval(component._interval);
                component.set("v.isModalOpen",false);
            }
        });
        $A.enqueueAction(action);
    },

    displayPopUp : function(cmp, evt, helper, status, label, message) {
        cmp.set("v.statusForPop", status);
        cmp.set("v.labelForPop", label);
        cmp.set("v.messageForPop", message);
        cmp.set("v.errorFlag",true);
    },

    setProgressFlag : function(cmp, evt, helper) {
        cmp.set("v.isModalOpen", true);
        cmp.set("v.flagForProgressBar", true);
        cmp.set("v.isProgressing", true); 
    }
    
})