({
    doInit : function(component,event,helper){
       var action = component.get("c.getAdTileContents");
       action.setCallback(this, function(response) {
           var state = response.getState();
           if(component.isValid() && state === 'SUCCESS') {
               component.set('v.contents', response.getReturnValue());
           }
       });
        $A.enqueueAction(action);
    }
   
})