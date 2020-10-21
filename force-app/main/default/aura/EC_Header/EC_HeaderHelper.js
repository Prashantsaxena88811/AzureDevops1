({
  // signout function
	helpersignout : function(component,event,helper) {
               
    },
    // update cart quantity
    cartQuantity:function(component){
       var action = component.get("c.cartQuantity");
       action.setCallback(this, function (response) {
      
      if (response.getState() == "SUCCESS") {
         component.set("v.CartQuant", response.getReturnValue().cartItemNo);
         component.set("v.cartURL", response.getReturnValue().cartURL);
        }
      });

      $A.enqueueAction(action);
    },
    // check if component is visible
    isCompVisible : function(component) {
       
        var action = component.get("c.compVisible");
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
                var i;
              for (i=0;i<ret.length;i++)  { 
                   if(ret[i].permName == $A.get("$Label.c.EC_Buy_Online")){
                 component.set("v.buyOnline", ret[i].permVal);
                   
                }
               }
           
            }
        });
        $A.enqueueAction(action);
    },
    // show mobile menu function
    showMobMenu: function(component,event,helper){
    var target = component.find('hamburger_menu');
    $A.util.toggleClass(target, 'slds-hide');     
    $A.util.toggleClass(target, 'showit');  
    var target_account = document.getElementsByClassName("account-dropdown")[0]; 
    target_account.classList.add("slds-hide");    
    },
    expandDiv:function(component,event,helper)
    {   
        var showWhat = component.get('v.showCross');
        var logoHide = component.find("logo").getElement();
        var hamHide = component.find("hamburger-menu-ham").getElement();
        var target = component.find("toExpand").getElement();
        var searchButtonShow = document.getElementsByClassName("search-btn")[0];
        var navMenu = document.getElementsByClassName("nav-menu")[0];
    
        searchButtonShow.classList.remove("hide_logo");
        navMenu.classList.add("hide_logo");
        target.classList.add("full_mobile");
        component.set('v.showCross',true);
        logoHide.classList.add("hide_logo");
        hamHide.classList.add("slds-hide");
        
        
     
    },
    // shrink div functionality
    shrinkDiv:function(component,event,helper)
    {
         var showWhat = component.get('v.showCross');
         var logoHide = component.find("logo").getElement();
         var hamHide = component.find("hamburger-menu-ham").getElement();
         var target = component.find("toExpand").getElement(); 
        var searchButtonShow = document.getElementsByClassName("search-btn")[0]; 
        var autocomplete = document.getElementsByClassName("auto-complete")[0];
        var navMenu = document.getElementsByClassName("nav-menu")[0];
        
        searchButtonShow.classList.add("hide_logo");
        autocomplete.classList.add("slds-hide");
        navMenu.classList.remove("hide_logo");
         target.classList.remove("full_mobile");
         component.set('v.showCross',false);
         logoHide.classList.remove("hide_logo");
         hamHide.classList.remove("slds-hide");
         document.getElementsByClassName("globalSearch")[0].value = "";
        
    },
    //117174
    checkPayerAccess : function (component, helper) {
      var checkPayerConfigs = component.get("c.checkPayerPermission");
      checkPayerConfigs.setCallback(this, function (response) {
          if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
              var ret = response.getReturnValue();
              console.log("isPayer:"+ret)
              component.set("v.isEligibleForPaymentPortal", ret);
          }
      });
      $A.enqueueAction(checkPayerConfigs);
  }

})