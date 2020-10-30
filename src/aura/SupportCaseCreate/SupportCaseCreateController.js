({
    doInit : function(component, event, helper) {
        let defaultAction = component.get("c.getDefaultValues");
        defaultAction.setParams({"articleUrl":window.location.pathname.split("/").splice(-1)[0]});
        defaultAction.setCallback(this,function(res){
            let state = res.getState();
            if(state=='SUCCESS'){
                console.log('res.getReturnValue()  :-  ',res.getReturnValue());
                component.set("v.category", res.getReturnValue().Category__c);
                component.set("v.subCategory", res.getReturnValue().Sub_Category__c);
            }
            
        });
        $A.enqueueAction(defaultAction);
                
        
        let userId = $A.get("$SObjectType.CurrentUser.Id");
        let action = component.get("c.getIssueRecordTypeId");
        action.setCallback(this,function(res){
            let state = res.getState();
            if(state=='SUCCESS'){
                component.set("v.issueRecordTypeId",res.getReturnValue())
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": "Please contact to system administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getContactId");
        action.setParams({
            userId:userId
        });
        action.setCallback(this,function(res){
            let state = res.getState();
            if(state=='SUCCESS'){        
                console.log("123 contact  :-  ",res.getReturnValue());
                component.set("v.contactId",res.getReturnValue().Id);
                component.set("v.email",res.getReturnValue().Email);
                let pattern = /[^0-9]/g;
                if(!$A.util.isEmpty(res.getReturnValue().Phone)) {
                    let phoneNumber = res.getReturnValue().Phone.replace(pattern, "");
                    component.set("v.phone", phoneNumber);
                }
                let action = component.get("c.getContactRelatedAccounts");
                action.setParams({
                    contactId:res.getReturnValue().Id
                });
                action.setCallback(this,function(res){
                    let state = res.getState();
                    if(state=='SUCCESS'){
                        if(res.getReturnValue()!=null){
                            component.set("v.options",res.getReturnValue().map(item=>({label:item.Account.Name,value:item.AccountId})));
                        }   
                    }
                    else{
                        console.log('record type error1  :-  ',res.getError());
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type":"error",
                            "message": "Please contact to system administrator."
                        });
                        toastEvent.fire();
                    }
                })
                $A.enqueueAction(action);
            }
            else{
                console.log('record type error2  :-  ',res.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": "Please contact to system administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    handleSubmit : function(component, event, helper) {
        
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
        
        var showSpinner = component.find("spinner");
        $A.util.toggleClass(showSpinner, 'case-redirection-show');
        let accountId = component.find("account").get("v.value");
        console.log('accountId test  :-  ',accountId);
       
            
            var objCase = component.get("v.objCase");
            console.log('case Obj  :-  ',typeof objCase);
            objCase.AccountId = accountId;
            objCase.Origin = "Portal Support";
            objCase.ContactId = component.get("v.contactId");
            objCase.Category__c = component.get("v.category");
            objCase.Sub_Category__c = component.get("v.subCategory");
            objCase.RecordTypeId = component.get("v.issueRecordTypeId");
            console.log('record type id  :-  ',objCase.RecordTypeId);
            objCase.Run_Assignment_Rule__c = true;
            objCase.Description = component.find("description").get("v.value");
            objCase.Subject = component.find("subject").get("v.value");
            console.log('objCase.Subject  :-  ',objCase.Subject ,component.find("subject").get("v.value") );
            
            var phone = phoneNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
            objCase.SuppliedPhone = "(" + phone[1] + ") " + phone[2] + "-" + phone[3];
            
            objCase.Contact_Email__c = component.find("email").get("v.value");
            // objCase.Subject = objCase.Sub_Category__c;
            
            console.log('123 objCase  :-  ',JSON.stringify(objCase));
            
            let action = component.get("c.saveCase");
            action.setParams({objCase : objCase});
            action.setCallback(this,function(res){
                let state = res.getState();
                if(state=='SUCCESS'){
                    console.log('success ok',res.getReturnValue());
                    var record = res.getReturnValue();
                    console.log('onsuccess: ', record);
                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": record,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else {
                    $A.util.removeClass(showSpinner, 'case-redirection-show');
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
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type":"error",
                            "message": message
                        });
                        toastEvent.fire();
                    }
                }
                
                
            });
            $A.enqueueAction(action);
        
    },
    handleSuccess: function(component, event) {
        var record = JSON.parse(JSON.stringify(event.getParams()));
        console.log('onsuccess: ', record.response.id);
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": record.response.id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleError: function(component, event) {
        var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
        console.log('failure: ', updatedRecord);
        var showSpinner = component.find("spinner");
        $A.util.toggleClass(showSpinner, 'case-redirection-show');
    },
    
    handleShowModal : function(component, event) {
        console.log("handleShowModal called");
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