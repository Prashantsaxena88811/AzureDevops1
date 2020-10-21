({
    // error handling in products component
    showError : function(component){
        if(component.get("v.productsCount")){
                    component.set("v.emptyList", true);
                }else{
                    var cmpTarget = component.find('showEmptyProductList');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
    },
    // function to fetch product from dB 
	fetchProduct : function(component, event, helper) {
        var products;
         var prodLength;
		
		var url = window.location.href;
      
        var valueEntered = /term=([^&]+)/.exec(url)[1];
       
       var decodedValue = valueEntered.replace(/\+/g, '%20');
        
        decodedValue = decodeURIComponent(decodedValue)
        
        valueEntered = decodeURIComponent(valueEntered);
         
      
		var action = component.get("c.getProdSearchResultsAura");
		action.setParams({
			searchText: valueEntered
		});
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
				products = ret;
                component.set("v.SearchTextField",decodedValue);
                if(ret.length){
                    component.set("v.emptyList", true);
                }else{
                    var cmpTarget = component.find('showEmptyProductList');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
                prodLength  = ret.length;
                
                component.set("v.productsList", products);
                
                var setPrdCount = component.getEvent("setAttribute");
                setPrdCount.setParams({
                    "prodattributeValue":prodLength,
                    "activeTab":"product"                  
                });
                setPrdCount.fire();
            }
        });
        $A.enqueueAction(action);
    },
})