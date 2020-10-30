({
	doInit: function(component, event, helper) {
        
        var cuUserId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", cuUserId);
        // Get array of pre-chat fields defined in Setup using the prechatAPI component
        var prechatFields = component.find("prechatAPI").getPrechatFields();
        component.set("v.prechatFields", prechatFields);	
        //component.find('contactRecordLoader').reloadRecord(true); 
        helper.getContact(component, event, helper);
	},
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)            
            //console.log("Contact is loaded successfully.");
            var contactRecord = component.get("v.record");
            //console.log(JSON.stringify(contactRecord));            
            var prechatInfo = component.get("v.prechatFields");
            prechatInfo.forEach(function(field) {
                //console.log('### ' + JSON.stringify(field));
                if(field.name=='FirstName') {
                    field.value = contactRecord.Contact.FirstName;
                }
                if(field.name=='LastName') {
                    field.value = contactRecord.Contact.LastName;
                }
            });            
            helper.startChat(component, event, helper);
        }
    }
});