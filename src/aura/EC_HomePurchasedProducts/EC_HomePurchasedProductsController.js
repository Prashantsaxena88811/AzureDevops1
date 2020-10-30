({
    // fetch already processed orders
    fetchOrders: function (component, event, helper) {
          helper.outageHelper(component);
          helper.isBasicBuyerCheck(component);
        component.set('v.DefaultImage', $A.get("$Resource.EC_Branding_Theme") + "/images/product.png");
        var orders;
        helper.showSpinner(component, event);
        var action = component.get("c.getRecentOrder");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                orders = ret;
                component.set("v.ordersRetrieved", true);
                orders.forEach(function (item) {
                    item.productName = item.productName.replace(/(.{48})..+/, "$1…");
                    if (!item.image) {
                        item["image"] = component.get('v.DefaultImage');
                    }
                    var price = item.price.toString().split(".");
                    item["Dollars"] = price[0];
                    item["Cents"] = "." + price[1];
                    if(item.unitPrice){
                        let unitPrice = item.unitPrice.toString().split(".");
                        item["customDollars"] = unitPrice[0];
                        item["customCents"] = "." + unitPrice[1];                        
                    }
                    delete item.price;
                });
                component.set("v.productsList", orders);
                helper.hideSpinner(component, event);
            }else{
                helper.hideSpinner(component, event);
            }
        });
        $A.enqueueAction(action);
        helper.isCompVisible(component);
    },
    // add product to cart
    addItemToCart: function (component, event, helper) {
        helper.cartRedirect(component, event, helper);
    },
    // view already processed orders
    viewAllOrders: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/orders"
        });
        urlEvent.fire();
    },
    // open order page to check specific order
    goToSpecificOrder: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/orders"
        });
        urlEvent.fire();
    },
    // image error handling
    imageError: function (component, event, helper) {
        event.target.setAttribute("src", component.get("v.DefaultImage"));
    },
})