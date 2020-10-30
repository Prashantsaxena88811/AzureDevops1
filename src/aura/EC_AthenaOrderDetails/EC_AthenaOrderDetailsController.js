({
	showProducts: function (component, event, helper) {
	  event.stopPropagation();
	  helper.getProductListDetails(component, event, helper);
	},
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
	  var orderVal= component.get("v.order");
	  component.set("v.orderLineStatuses", orderVal.lineStatuses);
	},
	addItemToCart: function (component, event, helper) {
	  var clickedSection = event.getSource(),
		orderValue = event.getSource().get("v.value");
	  var productSkuArray = [];
	  var productQuantityArray = [];
	  for(var i=0 ; i<orderValue.orderLineItems.length ; i++){
		productQuantityArray.push(orderValue.orderLineItems[i].orderLineMaterialNum+':'+orderValue.orderLineItems[i].orderLineQuantity);
		productSkuArray.push(orderValue.orderLineItems[i].orderLineMaterialNum);
	  }
	  var action = component.get("c.athenaReorder");
	  action.setParams({
		"effectiveAccountNum": orderValue.orderShipToNumber,
		  "productSkuArray": productSkuArray,
		  "orderItems": productQuantityArray
	  });
	  action.setCallback(this, function (response) {
		if (response.getState() && response.getReturnValue() != null) {
		  var redirectUrl = response.getReturnValue();
		  window.open(redirectUrl, '_parent');
		}
	  });
	  $A.enqueueAction(action);
	},
	imageError: function (component, event, helper) {
	  event.target.setAttribute("src", component.get("v.DefaultImage"));
	},

	getCurrentURL: function (component, event, helper) {
	  var currentRec = event.target.getAttribute("data-recId");
	  var imgMap = component.get("v.ProductImage");
	  component.set("v.currentProductURL", imgMap[currentRec]);
	},
    openModel: function(component, event, helper) {
	  // Show Fourkites Modal
	  component.set("v.isModalOpen", true);
	  event.target.parentElement.parentElement.classList.add("show-fourkites");
	  document.body.style.overflowY = "hidden";
    },
  
    closeModel: function(component, event, helper) {
	  // Hide Fourkites Modal
	  component.set("v.isModalOpen", false);
	  event.target.parentElement.parentElement.parentElement.parentElement.classList.remove("show-fourkites");
	  document.body.style.overflowY = "scroll";
    }
  })