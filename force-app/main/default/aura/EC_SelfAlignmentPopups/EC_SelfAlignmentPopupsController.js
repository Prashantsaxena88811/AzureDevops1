({
	init : function(component, event, helper) {
        document.addEventListener("click", function(){
           component.set("v.isOpen", false);  
        });
	},
    openModel: function(component, event, helper) {
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   }
})