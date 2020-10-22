({
	closeModal : function(component, event, helper) {
		component.set('v.isLogin',false);
        sessionStorage.setItem("cookie-info-flag","false");
        document.getElementById("image-wrap-id").style.display = "block";
	}
})