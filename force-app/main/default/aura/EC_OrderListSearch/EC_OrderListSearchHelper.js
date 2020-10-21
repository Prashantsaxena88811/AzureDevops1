({
    // error handling on order list search
    showError : function(component){
        if(component.get("v.ordersCount")){
                    component.set("v.emptyOrderList", true);
                }else{
                    var cmpTarget = component.find('orderListEmptyWrapper');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
    },
    // show hide data spinner
    showSpinner: function(component) {
		var spinnerMain =  component.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
	},

	hideSpinner : function(component) {
		var spinnerMain =  component.find("Spinner");
		$A.util.addClass(spinnerMain, "slds-hide");
	},
    // fetch product details on click
    getProductListDetails: function(component,event,helper) {
        
         var clickedSection = event.getSource(),
            orderValue = event.getSource().get("v.value"),
            OrderObj = {
                "orderId" : orderValue
            },
            isActive = $A.util.hasClass(clickedSection, "active");
        	var cmpTarget = document.getElementById(orderValue);
        	
            if(isActive) {
                $A.util.removeClass(clickedSection, "active");
                clickedSection.set('v.label','View more');
                cmpTarget.classList.toggle("slds-hide");
            } else {
                $A.util.addClass(clickedSection, "active");
                clickedSection.set('v.label','View less');
                var action = component.get("c.getOrderDetails");
                action.setParams({ 
                    "orderId" : OrderObj.orderId
                });
                action.setCallback(this, function(response) {
                    if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                        var orderDetails = response.getReturnValue();
                        component.set("v.OrderDetail", orderDetails);
                        cmpTarget.classList.toggle("slds-hide");
                    }
                });
                $A.enqueueAction(action); 
                
            }
    },
    // testing order list search component visibility
    compVisible : function(component) {
       
        var action = component.get("c.compVisible");
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
                
                var i;
              for (i=0;i<ret.length;i++)  { 
                  
                if(ret[i].permName == $A.get("$Label.c.EC_View_Invoices")){
                 component.set("v.invoiceVisible", ret[i].permVal);
                   
                }else if(ret[i].permName ==$A.get("$Label.c.EC_Buy_Online")){
                   component.set("v.buyOnline", ret[i].permVal); 
                    
                }else if(ret[i].permName ==$A.get("$Label.c.EC_View_Price")){
                   component.set("v.viwPrice", ret[i].permVal); 
                     
                }
               }
               
            }
        });
        $A.enqueueAction(action);
    }

    
    
})