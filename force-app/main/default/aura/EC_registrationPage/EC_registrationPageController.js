({
    initialize: function (component, event, helper) {
        var action5 = component.get("c.getProfile");
        action5.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                var EcolabiBuyUser = $A.get("$Label.c.EC_EcolabiBuyUser");
                if(ret !== EcolabiBuyUser) { //EcolabiBuyUser
                    helper.outageHelper(component);
                    window.addEventListener("message", function (evt) {
                        if (evt.data === "Unlock") {
                            component.set("v.captchaStatus", "Verified");
                            component.triggerValidateFields();
                        }
                    }, false);
                    window.addEventListener("message", function (event) {
                        if (event.data === "resizeCaptcha") {
                            component.find('iframe_captcha').getElement().classList.add("challengeLoaded");
                            component.find("captcha-box").getElement().classList.add("challengeLoaded");
                        } else if (event.data === "revertResize") {
                            component.find('iframe_captcha').getElement().classList.remove("challengeLoaded");
                            component.find("captcha-box").getElement().classList.remove("challengeLoaded");
                        }
                    });
                } else {
                    var errorURL = $A.get("$Label.c.EC_ErrorURL") ;
        			window.open(errorURL, "_self"); 
                }
            }
        });
        $A.enqueueAction(action5);
    },
    //Modal Function
    openModel: function (component, event, helper) {
        component.set("v.isOpen", true);
    },

    closeModel: function (component, event, helper) {
        component.set("v.isOpen", false);
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
    showOriginalFormat : function(component, helper, event){
        var phoneNo = component.find("phone"),
        	phoneNumber = phoneNo.get('v.value'),
            ShowOriginalFormat = ("" + phoneNumber).replace(/\D/g, '');
        phoneNo.set('v.value', ShowOriginalFormat);
    }, 
    isEmptyFieldValidation : function(component, helper, event){
        var firstName = component.find("fName"),
            fValue = firstName.get("v.value").trim(),
            lastName = component.find("lName"),
            lValue = lastName.get("v.value").trim(),
            isEmptyRegEx = /^\s*$/; 
        if (isEmptyRegEx.test(fValue)) {
             firstName.set('v.value', "");
        }
        if (isEmptyRegEx.test(lValue)) {
             lastName.set('v.value', "");
        }
    },
    

    validateFields: function (cmp, event, helper) {
        var firstName = cmp.find("fName").get("v.value"),
            lastName = cmp.find("lName").get("v.value"),
            emailAdd = cmp.find("email").get("v.value"),
            phoneNumber = cmp.find("phone").get("v.value"),
            country = cmp.find("country").get("v.value"),
            accountNo = cmp.find("accountNo").get("v.value"),
            saleRep = cmp.find("salesRep").get("v.value");
        var status = cmp.get("v.captchaStatus");
        if (status) {
            cmp.set("v.registerBtn", false);
        }
    },
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    register: function (cmp, evt, helper) {
        cmp.set("v.registerBtn", true);
        var firstName = cmp.find("fName"),
            fValue = firstName.get("v.value").trim(),
            lastName = cmp.find("lName"),
            lValue = lastName.get("v.value").trim(),
            emailAdd = cmp.find("email"),
            emailValue = emailAdd.get("v.value").trim(),
            phoneNumber = cmp.find("phone"),
            phoneValue = phoneNumber.get("v.value"),
            country = cmp.find("country"),
            countryValue = country.get("v.value"),
            accountNo = cmp.find("accountNo"),
            accountValue = accountNo.get("v.value").trim(),
            saleRep = cmp.find("salesRep"),
            saleValue = saleRep.get("v.value").trim(),
            reportValidity = true;

        
        if (!fValue) {
            firstName.reportValidity();
            reportValidity = firstName.reportValidity();
        }
        if (!lValue) {
            lastName.reportValidity();
            reportValidity = lastName.reportValidity();
        }
        if (!emailValue) {
            emailAdd.reportValidity();
            reportValidity = emailAdd.reportValidity();
        }
        if (!phoneValue) {
            phoneNumber.reportValidity();
            reportValidity = phoneNumber.reportValidity();
        }
        if (!countryValue) {
            country.showHelpMessageIfInvalid();
            //reportValidity = country.reportValidity();
        }
        if (!accountValue) {
            accountNo.reportValidity();
            reportValidity = accountNo.reportValidity();
        }
        if (!saleValue) {
            saleRep.reportValidity();
            reportValidity = saleRep.reportValidity();
        }
        if (reportValidity) {
            window.scrollTo(0, 0);
            helper.createCase(fValue, lValue, accountValue, phoneValue, emailValue, cmp, evt, helper);
        }
    }
})