({
  // fetch contact details of account
  fetchContactAccount: function (component) {
    this.showSpinner(component, event);
    var contactAccRec;
    var action = component.get("c.getContactAccountInformation");
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
        var ret = response.getReturnValue();
        component.set('v.contactName', ret.contactName);
        component.set('v.contEmail', ret.contEmail);
        component.set('v.contPhone', ret.contPhone);
        component.set('v.accounts', ret.lstAcc);
        component.set('v.orginalAccountsList', ret.lstAcc);
		  if(ret.userType == 'Internal'){
          	$A.util.addClass(component.find("accountAlignment"), "slds-hide");
              $A.util.addClass(component.find("portalAccessId"), "slds-hide");
          }
        this.hideSpinner(component, event);
      } else {
        this.hideSpinner(component, event);
      }
    });
    $A.enqueueAction(action);
  },
  // find object in JSON
  findJSON: function (data, term, helper) {
    var re = new RegExp(term, 'ig');
    var result = [];
    data.forEach(function (dataItem) {
      Object.keys(dataItem).forEach(function (key) {
        if (Array.isArray(dataItem[key])) {
          var items = helper.findJSON(dataItem[key], term, helper);
          if (items && items.length > 0) {
            dataItem[key] = items;
            result.push(dataItem);
          }
        } else {
          if (re.test(dataItem[key].toString())) {
            dataItem[key] = dataItem[key].toString().replace(re, function (str) { return '<mark>' + str + '</mark>' });
            result.push(dataItem);
          }
        }
      });
    });
    result = result.filter(function (v, i, self) {
      return i == self.indexOf(v);
    });
    return result;
  },
  // add acoount in account settings
  addAccounts: function (component, event, helper) {
    var event_src = event.target.classList[0];
    if (event_src == "add-account") {
      component.set("v.toShowAcc", true);
    }
    else {
      component.set("v.toShowAcc", false);
      component.set('v.accNumber', null);
      component.set('v.eMail', null);
    }
  },
  // check entries of accounts in account settings
  checkEntries: function (component, event, helper) {
    var accNo = component.get('v.accNumber');
    var eMail = component.get('v.eMail');
    var ableIt = component.find("add_button").getElement();
    var mailformat = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
    var errorCheck = eMail.match(mailformat);
    if (accNo.length > 0 && eMail.length > 0 && errorCheck) {
      ableIt.removeAttribute("disabled");
    } else {
      ableIt.setAttribute("disabled", "true");
    }
  },
  // submit account change
  submitAccounts: function (component, event, helper) {
    component.set("v.errorFlag", false);

    var eMail = component.get('v.eMail');
    var accNo = component.get('v.accNumber');
    var mailformat = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
    if (eMail.match(mailformat)) {
      component.set("v.toShowAcc", false);
      component.set("v.accNumber", null);
      component.set("v.eMail", null);
      var action = component.get("c.selfAccountAlignment");
      var alignmentMap = component.get("v.AlignmentMap");

      alignmentMap["AccountNumber"] = accNo;
      alignmentMap["SalesRepEmail"] = eMail;
      action.setParams({
        "accountAlignment": alignmentMap
      });
      this.showSpinner(component, event);
      action.setCallback(this, function (response) {
          if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
              helper.updateAccountList(component,event);
              this.hideSpinner(component, event);
              var ret = response.getReturnValue();
              var status = ret[0].EC_CustomCodes__c;
              var label = ret[0].EC_Popup_Label__c;
              var message = ret[0].EC_Message__c;
              component.set("v.statusForPop", status);
              component.set("v.labelForPop", label);
              component.set("v.messageForPop", message);
              component.set("v.errorFlag", true);
          }
      });
      $A.enqueueAction(action);
    }
    else {
      component.set("v.errorFlag", true);
      component.set("v.statusForPop", "004");
    }
  },
  // update account list in account settings
  updateAccountList : function(component, event){
      var contactAccRec;
      var action = component.get("c.getContactAccountInformation");
      action.setCallback(this, function (response) {
        if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
            var ret = response.getReturnValue();
            component.set('v.accounts', ret.lstAcc);
            } 
            else {
            this.hideSpinner(component, event);
          }
      });
      $A.enqueueAction(action);
  },
  // data spinner show
  showSpinner: function (component, event) {
    $A.util.addClass(component.find("accountSettingsPageSpinner"), "slds-show");
    $A.util.removeClass(component.find("accountSettingsPageSpinner"), "slds-hide");
  },
  // data spinner hide
  hideSpinner: function (component, event) {
    $A.util.removeClass(component.find("accountSettingsPageSpinner"), "slds-show");
    $A.util.addClass(component.find("accountSettingsPageSpinner"), "slds-hide");
  },
  // error handling to show defunc page
  outageHelper: function (component) {
    var action = component.get("c.outageRedirect");
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
        var ret = response.getReturnValue();
        if (!ret) {
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