({
    doInit : function(component, event, helper) {        
        var url = window.location.href;
        if(url.indexOf('/s/case')>=0) {
            component.set("v.isarticleactive", false);
        }
    }
})