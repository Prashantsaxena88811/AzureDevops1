({
    // Initialize fuction on page load 
    initialize: function(component, event, helper) {
        var action5 = component.get("c.getProfile");
        action5.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var ret = response.getReturnValue();
                var EcolabiBuyUser = $A.get("$Label.c.EC_EcolabiBuyUser");
                if(ret !== EcolabiBuyUser) { //EcolabiBuyUser
                    var resourcePath = $A.get("$Resource.EC_Branding_Theme");
                    var domain = window.location.host;
                    window.$buoop = { 
                        required: { e: -4, f: -3, o: -3, s: -1, c: -3 }, 
                        api: 2019.09,
                        insecure:true,
                        unsupported:true,
                        jsshowurl: resourcePath + '/js/update.show.min.js', 
                        container: document.body,
                        domain: domain
                    };
                    var e = document.createElement("script"); 
                    e.src = resourcePath + "/js/update.min.js";
                    document.body.appendChild(e);
                    helper.outageHelper(component);     
                    $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
                    component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));  
                } else {
                    var errorURL = $A.get("$Label.c.EC_ErrorURL") ;
        			window.open(errorURL, "_self"); 
                }
            }
        });
        $A.enqueueAction(action5);
    }, 
    // Login helper Function call
    handleLogin: function(component, event, helpler) {
        helpler.handleLogin(component, event, helpler);
    },    
    // set start URL
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    // navigate to sefl registration page
    navigateToSelfRegister: function(cmp, event, helper) {
        var selfRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selfRegUrl == null) {
            selfRegUrl = cmp.get("v.selfRegisterUrl");
        }
        var startUrl = cmp.get("v.startUrl");
        if(startUrl){
            if(selfRegUrl.indexOf("?") === -1) {
                selfRegUrl = selfRegUrl + '?startURL=' + decodeURIComponent(startUrl);
            } else {
                selfRegUrl = selfRegUrl + '&startURL=' + decodeURIComponent(startUrl);
            }
        }
        var attributes = { url: selfRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    // capture login click
    loginClick: function(component, event, helper) {
        var userName = component.find("loginForm");
        var userNameValue = userName.get("v.value");
        
        if (!userNameValue) {
            userName.reportValidity();
           var reportValidity = userName.reportValidity();
        }  
        
        var urlEvent = $A.get("e.force:navigateToURL");
        var loginRedirect = '../../login?so=00D5C000000DPuX';
        urlEvent.setParams({
            "url": loginRedirect,
            "target" : '_self'
        });
        urlEvent.fire();  
    },
    // registration page redirection
    registerRedirect: function(component, event, helper) {
         var baseUrl = window.location.href ;
         baseUrl = baseUrl.replace('login','registrationPage');
        window.open(baseUrl, '_self');
       
    }
    
    
})