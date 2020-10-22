({
    initialize: function (component, event, helper) {
        helper.outageHelper(component);
        var action5 = component.get("c.getProfile");
        action5.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                var EcolabiBuyUser = $A.get("$Label.c.EC_EcolabiBuyUser");
                if(ret !== EcolabiBuyUser) { //EcolabiBuyUser
                	//helper.outageHelper(component);
                } else {
                    var errorURL = $A.get("$Label.c.EC_ErrorURL") ;
        			window.open(errorURL, "_self"); 
                }
            }
        });
      }
  })