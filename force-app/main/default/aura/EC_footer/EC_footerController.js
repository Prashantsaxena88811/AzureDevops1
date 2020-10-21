({
  init: function (component, event, helper) {
   var url = window.location.href;
   var page = "login";
   var registration = "registrationPage";    
   var status = (url.indexOf(page)=== -1 || url.indexOf(registration)=== -1);   
   
   if(!status) {
  
      	sessionStorage.setItem("cookie-info-flag","true");
    
      } else {
          if(sessionStorage.getItem("cookie-info-flag") !== null) { 
              if(sessionStorage.getItem("cookie-info-flag") == "true") {
                  component.set('v.isLogin',true);
              } else {
                  component.set('v.isLogin',false);
              }
              console.log("2 "+sessionStorage.getItem("cookie-info-flag"));
          } else {
             component.set('v.isLogin',true);
      		 sessionStorage.setItem("cookie-info-flag","true") 
             console.log("3 "+sessionStorage.getItem("cookie-info-flag"));
          }
    }
  },
    closeModal:  function (component, event, helper) {
        helper.closeModal(component, event, helper)
    },
})