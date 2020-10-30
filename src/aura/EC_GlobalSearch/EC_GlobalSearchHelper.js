({
	doGlobalSearch: function(component, event, helper){
        
        var searchTerms = component.get("v.searchTerm");
    	if(searchTerms != '' && searchTerms != undefined && searchTerms.length > 3){
    		component.set("v.searchEnabled",true);
    		searchTerms = encodeURIComponent(searchTerms);
	    	//window.location = homeUrl + searchTerm;		//get URL from CC
        }else{
    		component.set("v.searchEnabled",false);
        }
    }
})