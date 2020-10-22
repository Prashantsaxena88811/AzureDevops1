({
  // Initialize fuction on page load  
  init: function (component, event, helper) {
    helper.outageHelper(component);
    helper.fetchContactAccount(component);

    //check and read value of parameter for landing page default
    //1.) Get the name of the parameter
    var landingPageParam = $A.get("$Label.c.EC_LandingPageParam");

    //2.) Read value from url and populate the landingPage attribute
    var landingPageParamValArray = new RegExp('[\?&]' + landingPageParam + '=([^&#]*)')
                      .exec(window.location.search);
    var landingPageParamVal = (landingPageParamValArray !== null) ? landingPageParamValArray[1] || 0 : false;
    component.set("v.landingPage", landingPageParamVal);
  },
  // Perform Account Search
  performAccountsSearch: function (component, event, helper) {
      var data = component.get("v.orginalAccountsList");
      var searchTerm = component.get("v.search");
      
      data = JSON.parse(JSON.stringify(data));
      if (!!searchTerm && searchTerm.length >= 3) {
          var results = helper.findJSON(data, searchTerm, helper);
      } else {
          var results = data;
      }
      component.set('v.accounts', results);
  },
  // Add account
  addAccount : function(component, event, helper) {
      helper.addAccounts(component, event, helper);
  },
  // Check Entry in Account
  checkEntry : function(component, event, helper) {
      helper.checkEntries(component, event, helper);	
  },
  // Submit account settings change
  submitAccount : function(component, event, helper) {
      helper.submitAccounts(component, event, helper);	
  },
  // Account settings data
  accountSettings: function(component, event, helper) {
      var tab1 = component.find('accountSettingsId');
      var TabOnedata = component.find('accountSettingsDataId');
      
      var tab2 = component.find('portalAccessId');
      var TabTwoData = component.find('portalAccessDataId');
      
      $A.util.addClass(tab1, 'slds-active');
      $A.util.addClass(TabOnedata, 'slds-show');
      $A.util.removeClass(TabOnedata, 'slds-hide');
      
      $A.util.removeClass(tab2, 'slds-active');
      $A.util.removeClass(TabTwoData, 'slds-show');
      $A.util.addClass(TabTwoData, 'slds-hide');
      
  },
  // Portal access data
  portalAccess: function(component, event, helper) {
      
      component.set("v.ordersSelected",true);
      
      var tab1 = component.find('accountSettingsId');
      var TabOnedata = component.find('accountSettingsDataId');
      
      var tab2 = component.find('portalAccessId');
      var TabTwoData = component.find('portalAccessDataId');
      
      $A.util.addClass(tab2, 'slds-active');
      $A.util.removeClass(TabTwoData, 'slds-hide');
      $A.util.addClass(TabTwoData, 'slds-show');
      
      $A.util.removeClass(tab1, 'slds-active');
      $A.util.removeClass(TabOnedata, 'slds-show');
      $A.util.addClass(TabOnedata, 'slds-hide');
  },
  // show ship to address information
  showShipToInfo : function(component, event, helper){
     event.stopPropagation();
     event.target.parentElement.parentElement.parentElement.nextSibling.classList.remove("slds-hide");
    
  },
  // close account settings popup
  closePopUp :  function(component, event, helper){
      event.stopPropagation();
     
     event.target.parentElement.parentElement.parentElement.parentElement.classList.add("slds-hide");
  },
    //set default tab
    setDefaultTab: function (component,event, helper) {
        var landingPage = component.get("v.landingPage");
        var defaultLandingTabVal = $A.get("$Label.c.EC_DefaultLandingTab");
        if(landingPage === defaultLandingTabVal){
            $A.enqueueAction(component.get('c.portalAccess'));
        }
    }
})