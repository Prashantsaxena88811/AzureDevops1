({
    init : function(component, event, helper) {
        console.log('EC_SelfAlignmentPopups invoked');
        document.addEventListener("click", function(){
            component.set("v.isOpen", false);  
        });
    },
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    navToMainPage: function(component, event, helper) {
        var landingPage = $A.get("$Label.c.EC_HostNameForIframe");
        window.open(landingPage, "_self");
    }
})