({
    // initialize fuction on page load 
    init: function (component, event, helper) {

      //  helper.getOrgURl(component);
       helper.checkPayerAccess(component, helper); //117174: CheckPaymentPortalAccess

        var baseUrl = window.location.protocol + "//" + window.location.hostname;
        var action5 = component.get("c.getProfile");
        action5.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var userId = $A.get("$SObjectType.CurrentUser.Id");
                component.set("v.userId", userId);
                var ret = response.getReturnValue();
                var EcolabiBuyUser = $A.get("$Label.c.EC_EcolabiBuyUser");
                if(ret !== EcolabiBuyUser) { //EcolabiBuyUser
                	
                    var action = component.get("c.getHeaderLinks");
                    action.setCallback(this, function (response) {
                        if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                            var ret = response.getReturnValue();
                            var url = window.location.href;
                            var str = url.split("?");
                          
                            ret.forEach(function (item) {
                                if (item.displayName.toLocaleLowerCase() !== "products") {
                                    if (item.displayName.toLocaleLowerCase() === "home") {
                                        item["url"] = baseUrl + "/s/";
                                    } else if(item.displayName.toLocaleLowerCase() === "service") {
                                        item["url"] = baseUrl + "/s/servicerequest";
                                       
                                    } else {
                                        item["url"] = baseUrl + "/s/" + item.displayName.toLocaleLowerCase();
                                    }
                                }
                                
                                if (item.displayName.toLocaleLowerCase() === "products" && url.match(/ProductList/g)) {
                                    item["class"] = "is-active";
                                } else {
                                    var pagename = str[0];
                                    if ((pagename === item.url.toLocaleLowerCase()) ||
                                        (item.displayName.toLocaleLowerCase() === "home" && pagename === "")) {
                                        item["class"] = "is-active";
                                    }
                                }
                            });
                            
                            component.set("v.headerMenuItems", ret);
                        }
                    });
                    $A.enqueueAction(action);
                    
                    var pageInfo = "Home";
                    component.set("v.pageName", pageInfo);
                    
                    document.addEventListener("click", function () {
                        var pageInfo = "Home";
                        component.set("v.pageName", pageInfo);
                        var ham = document.getElementsByClassName("header-items")[0];
                        ham.classList.add("slds-hide");
                        ham.classList.remove("showit");
                        var target = document.getElementsByClassName("account-dropdown")[0];
                        if(document.getElementById("iconChange").innerHTML == "expand_less")
                        {
                            target.classList.add("slds-hide");
                            document.getElementById("iconChange").innerHTML = "expand_more";
                        }
                        else if(document.getElementById("iconChange").innerHTML == "expand_more")  
                        {
                            target.classList.add("slds-hide");   
                        }
                        var cmpTarget = component.find('AccountInfo');
                    });
                    
                    var action2 = component.get("c.getContact");
                    action2.setCallback(this, function (response) {
                        if (response.getState() == "SUCCESS") {
                            var ret = response.getReturnValue();
                            component.set("v.Contact", ret);
                        }
                    });
                    $A.enqueueAction(action2);
                    
                    var action3 = component.get("c.getLogoutUrl");
                    action3.setCallback(this, function (response) {
                        if (response.getState() == "SUCCESS") {
                            var ret = response.getReturnValue();
                            component.set("v.RedirectUrl", ret);
                        }
                    });
                    $A.enqueueAction(action3);
                    
                    var action4 = component.get("c.getQuickListUrl");
                    action4.setCallback(this, function (response) {
                        var effAccId = Get_Cookie('apex__effacc');
                        if (response.getState() == "SUCCESS") {
                            var ret = response.getReturnValue();
                            if(effAccId && effAccId !=''){
                              ret = ret+"&effectiveAccount="+effAccId;  
                            }
                            component.set("v.QuickListURL", ret);
                        }
                    });
                    
                    $A.enqueueAction(action4);
                    helper.cartQuantity(component);
                    helper.isCompVisible(component);
                    
                }
                else {
                    
                    var errorURL = $A.get("$Label.c.EC_ErrorURL") ;
        			window.open(errorURL, "_self"); 
                }
            }
        });
        $A.enqueueAction(action5);


     //117174
     var billTrustURL = $A.get("$Label.c.EC_PaymetPortalLink");
     component.set("v.BillTrustURL", billTrustURL);

        function Get_Cookie(name) {
            var start = document.cookie.indexOf(name+"=");
            if (start == -1) return null;
            if ((!start) && (name != document.cookie.substring(0,name.length))) return null;
            var len = start+name.length+1;
            var end = document.cookie.indexOf(";",len);
            if (end == -1) end = document.cookie.length;
            return unescape(document.cookie.substring(len,end));
        }
       
    },
    // show homepage products
    showProducts: function (component, event, helper) {
        event.stopPropagation();
        
        var cmpTarget = component.find('AccountInfo');
        var target = document.getElementsByClassName("account-dropdown")[0];
         
        if (document.getElementById("iconChange").innerHTML == "expand_less") {
            document.getElementById("iconChange").innerHTML = "expand_more";
            target.classList.add("slds-hide");
        } else {
            document.getElementById("iconChange").innerHTML = "expand_less";
            target.classList.remove("slds-hide");
        }
        var target_ham = component.find('hamburger_menu');
        $A.util.addClass(target_ham, 'slds-hide');     
        $A.util.removeClass(target_ham, 'showit');
        
        
    },
    // sign out functionality
    signout: function (component, event, helper) {
       
        helper.helpersignout(component, event);
    },
    // show account information menu
    showAccountinformationMenu: function (component, event, helper) {
        
        var clickedSection = event.getSource(),
            isActive = $A.util.hasClass(clickedSection, "active");
        if (isActive) {
            $A.util.removeClass(clickedSection, "active");
        } else {
            $A.util.addClass(clickedSection, "active");
        }
    },
    // highlight tabs selection
    highlightThis: function (component, event, helper) {
        
        
        event.target.classList.add('is-active');
        var links = document.querySelectorAll('.nav-link');
        
        // Loop through each link
        for (var i = 0; i < links.length; i++) {
            
            // If the link is the one clicked, skip it
            if (links[i] === event.target) continue;
            
            // Remove the .active class
            links[i].classList.remove('is-active');
            
        }
    },
    // account settings page redirect
    accountSettings: function (component, event, helper) {
        
        var accountURL = $A.get("$Label.c.EC_AccountSettingsRedirect") ;
        window.open(accountURL, "_self");
    },
    // show mobile menu
    showMobMenu: function (component, event, helper) {
        event.stopPropagation();
        helper.showMobMenu(component, event, helper);
        
    },
    // expand and shrink div
    expandDiv: function (component, event, helper) {
       helper.expandDiv(component, event, helper);
    },
    shrinkDiv:function (component, event, helper) {
        helper.shrinkDiv(component, event, helper);
    },
    
})