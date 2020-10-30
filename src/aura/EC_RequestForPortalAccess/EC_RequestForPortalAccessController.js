({
initialize: function (component, event, helper) {
    helper.getRoles(component, event, helper);
    helper.paymentAccessHelper(component, event, helper);
    if(!component.get("v.caseCreation")){
        component.set("v.confirmBtn", false);
    } 
helper.buttonChange(component, event, helper);
helper.caseClosure(component, event, helper); 
    },
    selectRole: function (component, event, helper) {
        var btnName = event.getSource().get("v.name");
        component.set("v.selectRoleName", btnName);
    
        var elem = ((typeof event.getSource !== "undefined") ? event.getSource().getLocalId().toLowerCase() : event.target.getAttribute("id").toLowerCase());
        if (elem === "selectedbutton") {
                        event.target.parentElement.parentElement.parentElement.querySelectorAll(".right-spacer").forEach(function (item) {
                item.firstChild.classList.remove('active_btn');
            });
            component.set("v.confirmBtn", false);
            component.set("v.cancelBtn", false);
        } else {
              event.target.parentElement.parentElement.querySelectorAll(".right-spacer").forEach(function (item) {
                item.firstChild.classList.remove('active_btn');
            });
            component.set("v.confirmBtn", false);
            component.set("v.cancelBtn", false);
            event.target.classList.toggle("active_btn");
        }
    },
    createCase : function(component, event, helper){
        helper.createCaseHelper(component, event, helper);
    },
    createCasePayer : function(component, event, helper){
    helper.caseCreationhelper(component, event, helper);
},
    cancelCase : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    }

})