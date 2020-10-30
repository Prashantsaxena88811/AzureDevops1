({
  // show products on order details page
  showProducts: function (component, event, helper) {
    event.stopPropagation();
    helper.getProductListDetails(component, event, helper);
  },
  // initialize function on page load
  init: function (component, event, helper) {
    if (window.matchMedia("(min-width: 768px) and (max-width:1365px)").matches) {
      component.set("v.showTabView", true);
      component.set("v.showDesktopView", false);
      component.set("v.showMobileView", false);
    } else if (window.matchMedia("(min-width: 1366px)").matches) {
      component.set("v.showTabView", false);
      component.set("v.showDesktopView", true);
      component.set("v.showMobileView", false);
    } else if (window.matchMedia("(max-width:767px")) {
      component.set("v.showTabView", false);
      component.set("v.showDesktopView", false);
      component.set("v.showMobileView", true);
    }
    window.addEventListener("resize", function () {
      if (window.matchMedia("(min-width: 768px) and (max-width:1365px)").matches) {
        component.set("v.showTabView", true);
        component.set("v.showDesktopView", false);
        component.set("v.showMobileView", false);
      } else if (window.matchMedia("(min-width: 1366px)").matches) {
        component.set("v.showTabView", false);
        component.set("v.showDesktopView", true);
        component.set("v.showMobileView", false);
      } else if (window.matchMedia("(min-width: 320px) and (max-width: 767px)")) {
        component.set("v.showTabView", false);
        component.set("v.showDesktopView", false);
        component.set("v.showMobileView", true);
      }
    });

  },
  /* viewInvoice: function (component, event, helper) {
     helper.fetchInvoice(component, event, helper);
   }, */
  // add product to cart
  addItemToCart: function (component, event, helper) {
    var clickedSection = event.getSource(),
      orderValue = event.getSource().get("v.value"),
      OrderObj = {
        "orderId": orderValue
      }
    console.log(orderValue);
    var action = component.get("c.reorder");
    action.setParams({
      "orderId": orderValue
    });
    action.setCallback(this, function (response) {
      if (response.getState() && response.getReturnValue() != null) {
        var redirectUrl = response.getReturnValue();
        window.open(redirectUrl, '_parent');
      }
    });
    $A.enqueueAction(action);
  },
  // image error handler - products
  imageError: function (component, event, helper) {
    event.target.setAttribute("src", component.get("v.DefaultImage"));
  },
  // get clicked product URL
  getCurrentURL: function (component, event, helper) {
    var currentRec = event.target.getAttribute("data-recId");
    var imgMap = component.get("v.ProductImage");
    component.set("v.currentProductURL", imgMap[currentRec]);
  }
})