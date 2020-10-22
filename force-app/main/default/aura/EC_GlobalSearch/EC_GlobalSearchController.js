({
  // initialize on page load
  init: function (component, event, helper) {
    document.addEventListener("click", function () {
      var targetDiv = document.getElementsByClassName("auto-complete")[0];
      targetDiv.classList.add('slds-hide');
    });
},
// check key code
checkKeyCode: function (component, event, helper) {

    var targetDiv = document.getElementsByClassName("auto-complete")[0];
    targetDiv.classList.remove('slds-hide');
  var valueEntered = component.find("globalSearchId").get("v.value");
  if (!!valueEntered && (valueEntered.length >= 3)) {
    var commerceURLStorefront = $A.get("$Label.c.EC_CommerceURLStorefron");
      if(event.getParams().keyCode == 13) {
          if (valueEntered != '' && valueEntered != undefined && valueEntered.length >= 3) {
              if(true){
                  window.location.href = "/"+commerceURLStorefront+"/ccrz__ProductList?cartID=&portalUser=&store=&effectiveAccount=&cclcl=&operation=quickSearch&searchText=" + encodeURIComponent(valueEntered);
              }else{
                  window.location.href = "/s/search-results?term=" + encodeURIComponent(valueEntered);
              }
          }
        }
    //component.set("v.Spinner", true);
    var action = component.get("c.getSuggestionResultsAura");
    action.setParams({
      searchText: valueEntered
    });
    component.set("v.dummyData", []);
      component.set("v.noResults", false);
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
        var ret = response.getReturnValue();
        var dummyData = ret;
        component.set("v.noResults", false);
        if (!!dummyData && dummyData.length > 0) {
          dummyData = dummyData.map(function (item) {
            var obj = {};
            obj.id = item;
            obj.value = item;
            return obj;
          });
          if(false){
              component.set("v.dummyData", dummyData);
          }
        } else {
          component.set("v.dummyData", []);
          component.set("v.noResults", true);
        }
      }
    });
    $A.enqueueAction(action);
  }
    else {
        component.set("v.Spinner", false);
        component.set("v.dummyData", []);
        component.set("v.noResults", false);
        $A.enqueueAction(action);
    }
},
// perform global search
doGlobalSearch: function (component, event, helper) {


    var searchTerm = component.get("v.searchTerm");
    var commerceURLStorefront = $A.get("$Label.c.EC_CommerceURLStorefron");
    if (searchTerm != '' && searchTerm != undefined && searchTerm.length >= 3) {
      // Overiding global search withproduct search
      if(true){
        window.location.href = "/"+commerceURLStorefront+"/ccrz__ProductList?cartID=&portalUser=&store=&effectiveAccount=&cclcl=&operation=quickSearch&searchText=" + encodeURIComponent(searchTerm);
      }else{
        window.location.href = "/s/search-results?term=" + encodeURIComponent(searchTerm);
      }

    }
},
// select global search term
selectSearchTerm: function (component, event, helper) {
  var keyWord = event.target.getAttribute("data-value");
  component.set("v.searchTerm", keyWord);
  component.set("v.dummyData", []);
  component.set("v.noResults", false);
},
  // hide spinner
  hideSpinner: function (component, event, helper) {
    component.set("v.Spinner", false);
  }

})