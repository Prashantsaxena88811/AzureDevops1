({
    doInit : function(component, event, helper) {
        var supportUrl = "/s/support";
        var caseList = "/s/caselist";
        var supportUrl_Text = 'Back to Articles';
        var caseUrl_Text = 'Back to Caselist';  
        var caseRecordUrl_Text = 'Back to Case';
        var device = $A.get("$Browser.formFactor");
        var url = window.location.href;
        if(url.indexOf('/s/case/')>-1) {
            component.set("v.url", encodeURI(caseList));
            component.set("v.label", caseUrl_Text);
        }
        else if(url.indexOf('/s/topic/')>-1 || url.indexOf('/s/global-search/')>-1 || url.indexOf('/s/article/')>-1) {
            component.set("v.url", encodeURI(supportUrl));
            component.set("v.label", supportUrl_Text);            
        } else if(device==="PHONE" && (url.indexOf('/CaseComments')>-1 || url.indexOf('/CombinedAttachments')>-1) && url.indexOf('/relatedlist/')>-1) {
            var res = url.split("/relatedlist/");
            res = res[1].split("/CaseComments")[0];
            component.set("v.url", encodeURI("/s/case/" + res));
            component.set("v.label", caseRecordUrl_Text);
        }        
    },
    
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": component.get("v.url")
        });
        urlEvent.fire();
	}
    
})