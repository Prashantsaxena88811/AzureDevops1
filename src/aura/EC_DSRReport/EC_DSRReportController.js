({
  doInit : function(component, event, helper) {
    var serviceDetails = component.get("v.serviceDetails");
    if (serviceDetails.service.serviceEnd) {
        component.set("v.showEnddate", true);
        var formatDate = new Date(serviceDetails.service.serviceEnd);
        formatDate.setMinutes(formatDate.getMinutes()+(serviceDetails.service.gmtoffsetInMinutes));
        var modifiedDate = helper.formatedDateValue(formatDate,helper);
        component.set("v.showEndDateValue", modifiedDate);  
    }
  }
})