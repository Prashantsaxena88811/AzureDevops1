({
    validPhoneNumber : function(phoneNumber) {
        /* valid Phone Number (078) 789-8908;  */
        var pattern = /^(\d{3})(\d{3})(\d{4})$/;
        if(phoneNumber.match(pattern)) {
            return true;
        }  
        return false;
    },
    
    validateEmail : function(email) {
        var pattern = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        if(email.match(pattern)) {
            return true;
        }  
        return false;
    },
    
    showNotification : function(c, e, msg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": msg,
            "type": "error"
        });
        toastEvent.fire();
    }
})