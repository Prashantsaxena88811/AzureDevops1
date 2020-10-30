({
    doInit : function(component, event, helper) {
        let defaultAction = component.get("c.getDefaultValues");
        defaultAction.setParams({"articleUrl":window.location.pathname.split("/").splice(-1)[0]});
        defaultAction.setCallback(this,function(res){
            let state = res.getState();
            if(state=='SUCCESS'){
                component.set("v.category", res.getReturnValue().Category__c);
                component.set("v.subCategory", res.getReturnValue().Sub_Category__c);
                
            }else{
                var errors = res.getError();
                    console.log('errors  :-  ',errors[0]);
                    var message = '';
                    if (errors) {
                        for(var i=0; i < errors.length; i++) {
                            for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                                message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                            }
                            if(errors[i].fieldErrors) {
                                for(var fieldError in errors[i].fieldErrors) {
                                    var thisFieldError = errors[i].fieldErrors[fieldError];
                                    for(var k=0; k < thisFieldError.length; k++) {
                                        message += (message.length > 0 ? '\n' : '') + thisFieldError[k].message;
                                    }
                                }
                            }
                            if(errors[i].message) {
                                message += (message.length > 0 ? '\n' : '') + errors[i].message;
                            }
                        }
                        
                        console.log('Error : ' + message);
                    }
            }
            
        });
        $A.enqueueAction(defaultAction);
        
        ////Done by Ranu on 1st October 2020 : reCaptcha validation
        window.addEventListener("message", function (event) {
            if (event.data === "Unlock") {
                component.set("v.captchaStatus", "Verified");
                component.set("v.isSubmitDisabled", false);
            }else if (event.data === "resizeCaptcha") {
                component.find('iframe_captcha').getElement().classList.add("challengeLoaded");
            } else if (event.data === "revertResize") {
                component.find('iframe_captcha').getElement().classList.remove("challengeLoaded");
            } else if (event.data === "Expired") {
                component.set("v.captchaStatus", "Expired");
                component.set("v.isSubmitDisabled", true);
            } 
        }, false);
        
    },
    handleSubmit : function(component, event, helper) {
        var showSpinner = component.find("spinner");
        
      
        //Done by Ranu on 1st October 2020 : Email and Phone Number validation        
        // Validate the Email
        if(!helper.validateEmail(component.find("email").get("v.value"))){
            helper.showNotification(component, event, 'Please enter a valid email address.');
            event.preventDefault();    
            return;
        }  
        
        // Validate the phone number
        var phoneNumber = component.find("phone").get("v.value");
        if(!helper.validPhoneNumber(phoneNumber)){
            helper.showNotification(component, event, 'Please enter 10 digit phone number (no spaces, dashes or brackets)');
            event.preventDefault();    
            return;
        }
        
        
        $A.util.toggleClass(showSpinner, 'case-redirection-show');
        event.preventDefault(); 
            
            var objCase = component.get("v.objCase");
            console.log('case Obj  :-  ',typeof objCase);
            objCase.Category__c = component.get("v.category");
            objCase.Sub_Category__c = component.get("v.subCategory");
            objCase.Run_Assignment_Rule__c = true;
            objCase.Description = component.find("description").get("v.value");
            objCase.Subject = component.find("subject").get("v.value");
            
            var phone = phoneNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
            objCase.SuppliedPhone = "(" + phone[1] + ") " + phone[2] + "-" + phone[3];
            
            objCase.Contact_Email__c = component.find("email").get("v.value");
            objCase.First_Name__c = component.find("firstname").get("v.value");
            objCase.Last_Name__c = component.find("lastname").get("v.value");
            objCase.Company_Name__c = component.find("company").get("v.value");
            
            console.log('objCase  :-  ',JSON.stringify(objCase));
            
            let action = component.get("c.saveCase");
            action.setParams({objCase : objCase});
            action.setCallback(this,function(res){
                let state = res.getState();
                if(state=='SUCCESS'){
                    console.log('success ok',res.getReturnValue());
                    var record = res.getReturnValue();
                    console.log('onsuccess: ', record);
                    
                    
                    $A.util.toggleClass(showSpinner, 'case-redirection-show');
                    var temp = component.find("model-section");
        			var isHide = $A.util.hasClass(temp, 'slds-hide');
                    if(isHide){
                        $A.util.removeClass(temp, 'slds-hide');
                        $A.util.toggleClass(temp, 'slds-show');
                    }else{
                        $A.util.toggleClass(temp, 'slds-hide');
                        $A.util.removeClass(temp, 'slds-show');
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Case Captured",
                        "type":"success",
                        "message": "Case created successfully."
                    });
                    toastEvent.fire();
                    
                } else {
                    $A.util.toggleClass(showSpinner, 'case-redirection-show');
                    var errors = res.getError();
                    console.log('errors  :-  ',errors[0]);
                    var message = '';
                    if (errors) {
                        for(var i=0; i < errors.length; i++) {
                            for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                                message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                            }
                            if(errors[i].fieldErrors) {
                                for(var fieldError in errors[i].fieldErrors) {
                                    var thisFieldError = errors[i].fieldErrors[fieldError];
                                    for(var k=0; k < thisFieldError.length; k++) {
                                        message += (message.length > 0 ? '\n' : '') + thisFieldError[k].message;
                                    }
                                }
                            }
                            if(errors[i].message) {
                                message += (message.length > 0 ? '\n' : '') + errors[i].message;
                            }
                        }
                        var toastEvent1 = $A.get("e.force:showToast");
                        toastEvent1.setParams({
                            "title": "Error!",
                            "type":"error",
                            "message": message
                        });
                        toastEvent1.fire();
                    }
                }
                
                
            });
            $A.enqueueAction(action);
        
        
        
    },
    handleSuccess: function(component, event) {
        var record = JSON.parse(JSON.stringify(event.getParams()));
        console.log('onsuccess: ', record.response.id);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case captured successfully!",
            "type":"success",
            "message": ""
        });
        toastEvent.fire();
    },
    handleError: function(component, event) {
        var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
        console.log('failure: ', updatedRecord);
        var showSpinner = component.find("spinner");
        $A.util.toggleClass(showSpinner, 'case-redirection-show');
    },
    
    handleShowModal : function(component, event) {
        component.find("subject").set("v.value", "");
        component.find("phone").set("v.value", "");
        component.find("email").set("v.value", "");
        component.find("firstname").set("v.value", "");
        component.find("lastname").set("v.value", "");
        component.find("company").set("v.value", "");
        component.find("description").set("v.value", "");
        
        
        var temp = component.find("model-section");
        var isHide = $A.util.hasClass(temp, 'slds-hide');
        if(isHide){
            $A.util.removeClass(temp, 'slds-hide');
            $A.util.toggleClass(temp, 'slds-show');
        }else{
            $A.util.toggleClass(temp, 'slds-hide');
            $A.util.removeClass(temp, 'slds-show');
        }
    },
        
    
    startChat: function(component, event) {
        var clicklableicon = document.querySelector('.embeddedServiceHelpButton .flatButton');
        console.log(clicklableicon);
        clicklableicon.click();
    }
})