({
    getContact: function(component, event, helper) {
        var action = component.get("c.fetchContact");
        action.setParams({ "userId" : component.get("v.userId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contactRecord = response.getReturnValue();
                component.set("v.record", contactRecord);
                var prechatInfo = component.get("v.prechatFields");
                prechatInfo.forEach(function(field) {
                    console.log('### ' + JSON.stringify(field));
                    if(field.name=='FirstName') {
                        field.value = contactRecord.FirstName;
                    }
                    if(field.name=='LastName') {
                        field.value = contactRecord.LastName;
                    }
                });
                helper.startChat(component, event, helper);
            } 
            else {
                console.log('contact fetch failed');
            }
        });
        $A.enqueueAction(action);
    },
    
    startChat: function(component, event, helper) {
        var prechatInfo = component.get("v.prechatFields");
        var contactRecord = component.get("v.record");
        if(component.find("prechatAPI").validateFields(prechatInfo).valid) {
            var custevent = new CustomEvent(
                "setCustomField",
                {
                    detail: {
                        callback: component.find("prechatAPI").startChat.bind(this, prechatInfo),
                        customField: contactRecord.Id //ContactId
                    }
                }
            );
            // Dispatch the event.
            document.dispatchEvent(custevent);
            console.log('Fired setCustomField event');
		} else {
			// Show some error
			console.log('Error starting chat');
		}
	}
})