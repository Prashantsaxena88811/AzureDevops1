({

    doInit: function (component, event, helper) {
        var action = component.get("c.getUserDetailsCache");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                component.set("v.ContactId", ret.ContactId);
                component.set("v.contactFirstName", ret.ConFirstName);
                component.set("v.contactLastName", ret.ConLastName);
                component.set("v.userPhoneNumber", ret.ConPhone);
                component.set("v.phone", ret.ConPhone);
                component.set("v.userEmail", ret.ConEmail);
                component.set("v.isInstUser", ret.isInstUser);
                component.set("v.effectiveAccountId", ret.effectiveAccountId);
                component.set("v.actContactFirstName", ret.ConFirstName);
                component.set("v.actContactLastName", ret.ConLastName);
                component.set("v.actPhone", ret.ConPhone);
                component.set("v.actUserEmail", ret.ConEmail);
                component.set("v.effectiveAccountName", ret.SelectedAccount);
                component.set("v.effectiveAccountNumber", ret.SelectedAccountNumber);
                component.set("v.effectiveParentAccountNumber", ret.SelectedParentAccountNumber);
                if (ret.ConPhone) {
                    component.set("v.showPhoneNumberAsReadOnly", false);
                }
            }
        });
        $A.enqueueAction(action);
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        helper.fetchPicklistValues(component, controllingFieldAPI, dependingFieldAPI);

        // window.addEventListener("message", function (evt) {
        //     if (evt.data === "Unlock") {
        //         console.log("Reached If");
        //         component.set("v.captchaStatus", "Verified");
        //     }
        // }, false);
        // window.addEventListener("message", function (event) {
        //     if (event.data === "resizeCaptcha") {
        //         component.find('iframe_captcha').getElement().classList.add("challengeLoaded");
        //         component.find("captcha-container").getElement().classList.add("challengeLoaded");
        //     } else if (event.data === "revertResize") {
        //         component.find('iframe_captcha').getElement().classList.remove("challengeLoaded");
        //         component.find("captcha-container").getElement().classList.remove("challengeLoaded");
        //     }
        // });
    },
    validateFields: function (cmp, event, helper) {
        var account = cmp.find("account").get("v.value"),
            requestType = cmp.find("requestType").get("v.value"),
            category = cmp.get("v.objDetail"),
            notes = cmp.find("notes").get("v.value"),
            email = cmp.find("emailId").get("v.value"),
            phone = cmp.find("phone").get("v.value");
        if (account && requestType && category && notes && email && phone) {
            cmp.set("v.isFormValidated", false)
        }
    },
    onControllerFieldChange: function (component, event, helper) {
        var controllerValueKey = event.getSource().get("v.value");
        var depnedentFieldMap = component.get("v.depnedentFieldMap");

        if (controllerValueKey != '') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];

            if (ListOfDependentFields.length > 0) {
                component.set("v.bDisabledDependentFld", false);
                helper.fetchDepValues(component, ListOfDependentFields);
            } else {
                component.set("v.bDisabledDependentFld", true);
                component.set("v.listDependingValues", ['']);
            }

        } else {
            component.set("v.listDependingValues", ['']);
            component.set("v.bDisabledDependentFld", true);
        }
    },
    Submit: function (cmp, event, helper) {
        cmp.set("v.isSubmitDisabled", true);
        const regex = new RegExp(/<[^>]*>/);
        var Acc = cmp.get("v.selectedAccount.accountNumber"),
            soldTo = cmp.get("v.selectedAccount.soldTo");
        if (Acc == undefined || Acc == '' || Acc == null) {
            Acc = cmp.get("v.effectiveAccountNumber");
            soldTo = cmp.get("v.effectiveParentAccountNumber");
        }
        var AccValue = (Acc != undefined && Acc != null && Acc != '')?Acc.replace(regex, ''):'',
            reqType = cmp.find("requestType"),
            requestTypeValue = "INSTITUTIONAL",//reqType.get("v.value"),
            catType = cmp.find("category"),
            categoryValue = cmp.get("v.objDetail"),
            NoteType = cmp.find("notes"),
            NoteValue = NoteType.get("v.value"),
            getTheContactNumber = document.getElementById("contactNumber"),
            phoneNumber,
            email = cmp.get("v.userEmail"),
            firstName = cmp.get("v.contactFirstName"),
            lastName = cmp.get("v.contactLastName"),
            reportValidity = true;	
        if (document.getElementById("contactNumber")) {
            phoneNumber = getTheContactNumber.innerHTML;
        }
        if (phoneNumber == undefined || phoneNumber == null || phoneNumber == '') {
            var ConPhone = cmp.find("phone"),
            ConPhoneValue = ConPhone.get("v.value");
        } else {
            ConPhoneValue = phoneNumber;
        }

        if (!AccValue) {
            var accDetails = cmp.find("account");
            cmp.set("v.isDisable", false);
            reportValidity = accDetails.reportValidity();
            cmp.set("v.isDisable", true);
        }

        if (!ConPhoneValue) {
            ConPhone.showHelpMessageIfInvalid();
            reportValidity = ConPhone.reportValidity();
        } else if (ConPhoneValue && ConPhoneValue.length < 10) {
            ConPhone.showHelpMessageIfInvalid();
            reportValidity = false;
        }

        if (!NoteValue) {
            NoteType.reportValidity();
            //reportValidity = NoteType.reportValidity();
        }
        if (!requestTypeValue) {
            reqType.showHelpMessageIfInvalid();
            reportValidity = reqType.reportValidity();
        } else {
            cmp.set("v.divisionType", requestTypeValue);
        }

        if (!categoryValue) {
            catType.showHelpMessageIfInvalid();
            reportValidity = catType.reportValidity();
        } else {
            cmp.set("v.categoryType", categoryValue);
        }
        cmp.set('v.currentDate', new Date());
        if (reportValidity) {
            helper.createCase(AccValue, requestTypeValue, categoryValue, NoteValue, ConPhoneValue, soldTo, email, firstName+' '+lastName, cmp, event, helper);
        }
    },

    showOriginalFormat : function(component, helper, event){
        var phoneNo = component.find("phone"),
        	phoneNumber = phoneNo.get('v.value'),
            ShowOriginalFormat = ("" + phoneNumber).replace(/\D/g, '');
        phoneNo.set('v.value', ShowOriginalFormat);
    }, 
    
    //To format the given number
    formatPhoneNumber: function (component, helper, event) {
        var phoneNo = component.find("phone");
        var phoneNumber = phoneNo.get('v.value');
        var s = ("" + phoneNumber).replace(/\D/g, '');
        if(helper.type=="blur"){
            var m = s.match(/^(\d{3})(\d{3})(\d{4})$/);
            var formattedPhone = (!m) ? phoneNumber : "(" + m[1] + ") " + m[2] + "-" + m[3];
            phoneNo.set('v.value', formattedPhone);
        }
    },

    resetView: function (component, event, helper) {
        component.set("v.isDocAvailable", false);
        helper.cancelFile(component, event, helper);
        $A.get('e.force:refreshView').fire();
    },

    handleUploadFinished: function (component, event, helper) {
        var files = event.getParam("files");
        console.log('File Size=='+files[0].contentsize);
        component.set("v.DocumentInitialName", files[0].name);
        component.set("v.isDocAvailable", true);
    },

    onFileDelete: function (component, event, helper) {
        component.set("v.isDocAvailable", false);
        helper.cancelFile(component, event, helper);
    },
    requestService: function(component, event, helper) {
        helper.newServiceRequest(component, event, helper);
    },
    newService : function(component, event, helper) {
        component.set("v.isSubmitDisabled", false);
        helper.fillServiceForm(component, event, helper);
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        helper.fetchAccounts(component, event);
        //hide body scroll bar on open
        document.body.style.overflowX = 'hidden';
        document.body.style.overflowY = 'hidden';
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.searchAccountKey", '');
        component.set("v.NoSearchResults", false);
        component.set("v.isModalOpen", false);
        //enable body scroll bar on close
        document.body.style.overflowX = 'scroll';
        document.body.style.overflowY = 'scroll';
    },
    onAccountSelect: function(component, event, helper) {
         console.log('cap event');
        //enable body scroll bar on close
        document.body.style.overflowX = 'scroll';
        document.body.style.overflowY = 'scroll';
        component.set("v.effectiveAccountName", "");
        var selectedAccount = event.getParam("eventShipToAccount");
 		component.set("v.selectedAccount", selectedAccount);
        component.set("v.effectiveAccountId", selectedAccount.ID); 
        console.log('selectedAccount',component.get("v.selectedAccount"));
        component.set("v.isModalOpen", false);
    },
    
    searchAccounts: function(component, event, helper){
        	component.set("v.NoSearchResults", false);
            helper.fetchAccounts(component, event);
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = '';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.DocumentInitialName", fileName);
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            console.log('Please Select a Valid File');
        }
    },
    onDeleteFile: function (component, event, helper) {
        component.set("v.isDocAvailable", false);
        component.set("v.DocumentInitialName", '');
        component.set("v.isDocError", false);
        component.find('fileId').set('v.files', []);
    },
})