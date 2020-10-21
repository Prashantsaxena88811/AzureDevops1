({
    // show error section
    showError : function(component){
        if(component.get("v.DocCount")){
                    component.set("v.emptyDocumentsWrapper", true);
                }else{
                    var cmpTarget = component.find('sdsDocumentsWrapper');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
    },
    // fetch documents
	fetchSDSDocs : function(component) {
		var sdsDocs;
        
        var url = window.location.href;
		var valueEntered = /term=([^&]+)/.exec(url)[1];
        valueEntered = decodeURIComponent(valueEntered);
         var decodedValue = valueEntered.replace(/\+/g, '%20'); 
        decodedValue = decodeURIComponent(decodedValue)
        
        component.set("v.SearchText",decodedValue);
		var action = component.get("c.getDocsSearchResultsAura");
        
        action.setParams({
			searchText: valueEntered
		});
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
                
				sdsDocs = ret;
                var doclength = 0;
                
                sdsDocs.forEach(function(element){
                    doclength += element.lstGroupedSDSBean.length;
                })
                
                if(ret.length){
                    component.set("v.emptyDocumentsWrapper", true);
                }else{
                    var cmpTarget = component.find('sdsDocumentsWrapper');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
               	component.set("v.sdsDocsList", sdsDocs);
                
                var setDocCount = component.getEvent("setAttribute");
                setDocCount.setParams({
                    "sdsDocattributeValue":doclength,
                    "activeTab":"document"                  
                });
                setDocCount.fire();
            }
        });
        $A.enqueueAction(action);
	},
    // redirect document links
    redirectDocLink : function(component,event){
      var docLink = event.target.closest(".doc-info").getAttribute("data-order"); 
        window.open(docLink,"_blank");
    }
})