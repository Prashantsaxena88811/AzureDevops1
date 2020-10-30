({
	doInit : function(component, event, helper) {        
        let action = component.get("c.getDataCategory");
        action.setParams({
            "UrlName":window.location.pathname.split("/").splice(-1)[0]
        })
        action.setCallback(this,function(res){
            let state = res.getState();
            if(state=="SUCCESS"){                
                component.set("v.dataCategory", res.getReturnValue());
            }
            else{
                console.log('Error while fetching article data category')
            }
        });
        $A.enqueueAction(action);
    }
})