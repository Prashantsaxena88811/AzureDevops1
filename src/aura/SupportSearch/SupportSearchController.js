({
    doInit : function(component, event, helper) {
        var url = window.location.href;
        if(url.indexOf('/global-search/')>-1) {
            component.set("v.searchText", url.split('/global-search/')[1]);
        }
    },
    handleClick : function(component, event, helper) {
        var searchText = component.get("v.searchText");
        console.log("Search Text : " + searchText);
        //if($A.util.isEmpty(searchText)) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/s/global-search/" + searchText
        });
        urlEvent.fire();
        //}
    },
    handleKeyUp: function (cmp, evt) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var searchText = cmp.get("v.searchText");
            console.log("Search Text : " + searchText);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/s/global-search/" + searchText
            });
            urlEvent.fire();
        }
    }
})