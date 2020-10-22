({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    redirectToLogin :function(component,event,helper){
         var startUrl = component.get("v.startUrl");
        if(!startUrl){
            startUrl = '';
        }
        startUrl = decodeURIComponent(startUrl);
        var action = component.get("c.redirectLogin");
         action.setParams({
           
            "startUrl" : startUrl
        });
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
          if (rtnValue !== null) {
             component.set("v.errorMessage",rtnValue);
             component.set("v.showError",true);
              window.open(a.getReturnValue(),'_parent');
          }
       });
    $A.enqueueAction(action);       
    },
    redirectToRedemptionUrl :function(component,event,helper){
        var redirectRedemptionUrl = component.get("v.redemptionUrl");       
        if (redirectRedemptionUrl !== null) {
            component.set("v.errorMessage",redirectRedemptionUrl);
            component.set("v.showError",true);
            console.log('redirecting to redemption url ->');
            window.open(redirectRedemptionUrl,'_parent');
         }    	
	},

    createCase: function(fValue,lValue,accountValue,phoneValue,emailValue,component,event,helper){
        var startUrl = component.get("v.startUrl");
        if(!startUrl){
            startUrl = '';
        }
        startUrl = decodeURIComponent(startUrl);
        
        var action = component.get("c.validateRegistration");
        var regMap = component.get("v.RegistrationMap");
        regMap["FirstName"]=fValue;
        regMap["LastName"]=lValue;
        regMap["AccountNumber"]=accountValue; 
        regMap["PhoneNumber"]=phoneValue;
        regMap["Email"]=emailValue;
        regMap["SalesRepEmail"] = component.find("salesRep").get("v.value");
        
        this.showSpinner(component, event);
        
        action.setParams({
            "registrationDetails": regMap,
            "startUrl" : startUrl
        });
        
        
        action.setCallback(this, function(a){
            component.set("v.registerBtn", true);
            var rtnValue = a.getReturnValue();
            this.hideSpinner(component, event);
            if (rtnValue !== null) {
                var rtnMapValue = rtnValue['code'];
                var redemptionUrlValue = rtnValue['redemptionUrl'];
                component.set("v.redemptionUrl",redemptionUrlValue);
                //Below console log for testing purposes. Need to be removed
                console.log('redemptionUrl ->' + redemptionUrlValue);
                var status = rtnMapValue[0].EC_CustomCodes__c;
                var label = rtnMapValue[0].EC_Popup_Label__c;
                var message = rtnMapValue[0].EC_Message__c;
                if(status =='1001') {
                    if(redemptionUrlValue !== '' && redemptionUrlValue !== null){
                        helper.redirectToRedemptionUrl(component,event, helper);    
                    }else{
                        helper.redirectToLogin(component,event, helper);
                    }                    
                }
                else {
                    component.set("v.statusForPop",status);
                    component.set("v.labelForPop",label);
                    component.set("v.messageForPop",message);
                    component.set("v.errorFlag",true);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    handleSelfRegister: function (component, event, helpler) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("fName").get("v.value");
        var lastname = component.find("lName").get("v.value");
        var email = component.find("email").get("v.value");
        var country = component.find("country").get("v.value");
        var phoneNo = component.find("phone").get("v.value");
        var accountNo = component.find("accountNo").get("v.value");
        var salesRep = component.find("salesRep").get("v.value");
        var action = component.get("c.selfRegister");
        
        action.setParams({firstname:firstname,lastname:lastname, email:email,country:country,phoneNo:phoneNo,
                          accountNo:accountNo, salesRep:salesRep});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
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
,
    showSpinner: function(component, event) {
        $A.util.removeClass(component.find("registrationPageSpinner"), "slds-hide");
    },
    hideSpinner: function(component, event) {
        $A.util.addClass(component.find("registrationPageSpinner"), "slds-hide");
    }
});