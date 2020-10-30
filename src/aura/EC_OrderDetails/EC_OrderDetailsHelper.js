({
    // fetch orders to display
    fetchOrders: function (component) {
        var orders;
        var action = component.get("c.getPastOrder");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                orders = ret;
                component.set("v.Orders", orders);
            }
        });
        $A.enqueueAction(action);
    },
    // get product details list
    getProductListDetails: function (component, event, helper) {
        event.stopPropagation();
        component.set('v.DefaultImage', $A.get("$Resource.EC_Branding_Theme") + "/images/product.png");
        var clickedSection = event.getSource(),
            orderValue = event.getSource().get("v.value"),
            OrderObj = {
                "orderId": orderValue
            },
            isActive = $A.util.hasClass(clickedSection, "active");
        var cmpTarget = document.getElementById(orderValue);

        if (isActive) {
            $A.util.removeClass(clickedSection, "active");
            clickedSection.set('v.label', 'View more');
            cmpTarget.classList.toggle("slds-hide");
        } else {
            $A.util.addClass(clickedSection, "active");
            clickedSection.set('v.label', 'View less');
            var orderDetailsArrayHasValue = component.get("v.OrderDetail").length;
            if(!orderDetailsArrayHasValue){
                var action = component.get("c.getOrderDetails");
                action.setParams({
                    "orderId": OrderObj.orderId
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                        var orderDetails = response.getReturnValue();
                        
                        orderDetails.forEach(function (item) {
                            item.ProdName = item.ProdName.replace(/(.{48})..+/, "$1…");
                            var price = item.UnitPrice.toString().split(".");
                            item["Dollars"] = price[0];
                            item["Cents"] = "." + price[1];
                        }); 
                        
                        component.set("v.OrderDetail", orderDetails);
                        cmpTarget.classList.toggle("slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
            else{
              cmpTarget.classList.toggle("slds-hide");  
            }
        }

    },
    // fetch invoice of orders
    fetchInvoice: function (component, event, helper) {
        var viewInv = event.target.getAttribute("data-order");
        var eUrl = $A.get("e.force:navigateToURL");
        var action = component.get("c.getInvoice");
        action.setParams({
            "orderId": viewInv
        });

        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                eUrl.setParams({
                    "url": response.getReturnValue()
                });
                eUrl.fire();
            }
        });
        $A.enqueueAction(action);

    }

})