({
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
    getProductListDetails: function (component, event, helper) {
        event.stopPropagation();
        component.set('v.DefaultImage', $A.get("$Resource.EC_Branding_Theme") + "/images/product.png");
        var clickedSection = event.getSource(),
        OrderObj = event.getSource().get("v.value"),
            orderValue = OrderObj.orderNum,
            isActive = $A.util.hasClass(clickedSection, "active");
        var cmpTarget = document.getElementById(orderValue);

        if (!cmpTarget.classList.contains("slds-hide")) {
            $A.util.removeClass(clickedSection, "active");
            component.set("v.viewMorestatus", false);
            clickedSection.set('v.label', 'View more');
            cmpTarget.classList.toggle("slds-hide");
        } else {
            $A.util.addClass(clickedSection, "active");
            component.set("v.viewMorestatus", true);
            clickedSection.set('v.label', 'View less');
            var orderDetailsArrayHasValue = component.get("v.OrderDetail").length;
            if(!orderDetailsArrayHasValue){
				var orderDetails = OrderObj;
				var action = component.get("c.getProductData");
				var productList = [];
				orderDetails.orderLineItems.forEach(function (item) {
					productList.push(item.orderLineMaterialNum);
				});
				action.setParams({
				    "productList": productList
                });
				action.setCallback(this, function (response) {
					 if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
						var ret = response.getReturnValue();
                        orderDetails.orderLineItems.forEach(function (item) {
                            var itemObject = ret.filter(function(prod) {
                                return prod.Product.ccrz__SKU__c == item.orderLineMaterialNum;
                            });
                            if (itemObject != null && itemObject !== ''){
                              var prodId = itemObject[0].Product.Id;
                              item.prodId = itemObject[0].Product.Id;
                              item.ProdImg = itemObject[0].ProdImageMap[prodId];
                              item.PrdDetUrl = itemObject[0].PrdDetUrl;
                              item.ProdSDSURI = itemObject[0].ProdSDSMap[prodId];
                            }
                        });
                        component.set("v.order.orderLineItems", orderDetails.orderLineItems);
                        component.set("v.viewMorestatus", true);
					}
				});
				$A.enqueueAction(action);
				cmpTarget.classList.toggle("slds-hide");
            }
            else{
              cmpTarget.classList.toggle("slds-hide");
            }
        }

    },

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