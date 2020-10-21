({
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

    },
    
    showSpinner: function(component, event) {
        $A.util.removeClass(component.find("registrationPageSpinner"), "slds-hide");
    },
    
    hideSpinner: function(component, event) {
        $A.util.addClass(component.find("registrationPageSpinner"), "slds-hide");
    },
    
    popupvalue: function(component, event, helper) {
        component._interval = setInterval($A.getCallback(function () {
            var progress = component.get('v.progressreg');
            component.set('v.progressreg', progress === 100 ? 0 : progress + 1);
      }), 200); 
    },
    modalClose: function(component, event, helper) {
        component.set('v.progressreg',100);
        clearInterval(component._interval);
        component.set("v.isModalOpen",false);
    },
    statusMessage:function(component, event, helper, data){
        component.set("v.statusForPop",data.status);
        component.set("v.labelForPop",data.label);
        component.set("v.messageForPop",data.message);
        component.set("v.errorFlag",data.errorFlag);
    },
    redirectToCompleteRegistration :function(Email,component,event,helper){
        var baseUrl = window.location.href ;
         if(component.get("v.isProgressingreg") == true) {
            helper.modalClose(component,event,helper);
            }
        var addstring = 'completeregistration?username='+Email+'&c=1&';
        baseUrl = baseUrl.replace('registrationPage?',addstring);
        window.open(baseUrl, '_self'); //open page in same tab
    },
    
    registerUser: function(fValue,lValue,accountValue,phoneValue,emailValue,component,event,helper){
        var action = component.get("c.registerUser");
        var mapUserDetails = component.get("v.RegistrationMap");
        mapUserDetails["FirstName"] = fValue;
        mapUserDetails["LastName"]=lValue;
        mapUserDetails["AccountNumber"]=accountValue;
        mapUserDetails["PhoneNumber"]=phoneValue;
        mapUserDetails["Email"]=emailValue;
        mapUserDetails["SalesRepEmail"] = component.find("salesRep").get("v.value");
        component.set("v.isModalOpen",true);
        component.set("v.flagForProgressBarreg", true);
        component.set("v.isProgressingreg", true);
        helper.popupvalue(component,event,helper);
        action.setParams({
            "mapUserDetails": mapUserDetails
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Response STATE: ' + state);
            
            if(state == "SUCCESS") {
                var rtnValue = response.getReturnValue();
                console.log('Returned Response: ' + rtnValue);
                
                if (rtnValue !== null) {
                    var parsed = JSON.parse(rtnValue);
                    var status = parsed.status;
                    var label = parsed.label;
                    var message = parsed.message;
                    var caseStatus = parsed.caseStatus;
                    var firstName = parsed.firstName;
                    var lastName = parsed.lastName;
                    var accountType = parsed.accountType;
                    var userEmail =  emailValue;
                    var info = {status:status,label:label,message:message,errorFlag:true};
                    if(status == '1001') {
                        if(caseStatus == 'New') {
                            if(accountType == 'All') {
                                helper.redirectToCompleteRegistration(emailValue,component,event, helper);
                            } else if(accountType == 'LocalAccount') {
                                helper.createDirectoryUser(firstName, lastName, userEmail, accountType, component,event, helper);
                            } else if(accountType == 'federated') {
                                helper.createDirectoryUser(firstName, lastName, userEmail, accountType, component,event, helper);
                            }
                        } 
                    } else {
                        if(component.get("v.isProgressingreg") == true) {
                            helper.modalClose(component,event,helper);
                            helper.statusMessage(component,event,helper, info);
                            }
                        
                    }
                }
            } else if (state === "INCOMPLETE") {
                if(component.get("v.isProgressingreg") == true) {
                    helper.modalClose(component,event,helper);
                    }
                console.log("Unknown error");
            } else if (state === "ERROR") {
                if(component.get("v.isProgressingreg") == true) {
                    helper.modalClose(component,event,helper);
                    }
                console.log("Unknown error");
            } 
        });
        
        $A.enqueueAction(action);
    },
      
    createDirectoryUser : function(firstName, lastName, userEmail, accountType, component,event,helper){
        console.log('Inside createDirectoryUser: ' + firstName + lastName + userEmail + accountType);
        
        var action = component.get("c.createDirectoryUser");
        action.setParams({
            "userEmail": userEmail,
            "accountType": accountType,
            "firstName": firstName,
            "lastName": lastName
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('Response STATE: ' + state);
            if(state == "SUCCESS") {
                var rtnValue = response.getReturnValue();
                console.log('Returned Response: ' + rtnValue);
                var parsed = JSON.parse(rtnValue);
                var status = parsed.status;
                var label = parsed.label;
                var message = parsed.message;
                var info = {status:status,label:label,message:message,errorFlag:true};
                if(component.get("v.isProgressingreg") == true) {
                    helper.modalClose(component,event,helper);
                    helper.statusMessage(component,event,helper,info);
                }
            } else if (state === "INCOMPLETE") {
               if(component.get("v.isProgressingreg") == true) {
                   helper.modalClose(component,event,helper);
                }
                console.log("Unknown error");
            } else if (state === "ERROR") {
                if(component.get("v.isProgressingreg") == true) {
                    helper.modalClose(component,event,helper);
                    helper.statusMessage(component,event,helper,info);
                    }
                console.log("Unknown error");
            } 
        });
        
        $A.enqueueAction(action);
    },
});