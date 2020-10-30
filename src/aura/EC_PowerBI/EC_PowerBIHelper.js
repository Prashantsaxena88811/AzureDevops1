({
    getPowerBiEmbedToken : function(component,event,helper) {
		var action = component.get("c.getPowerBIEmbedToken");
        //clientCredaccessToken, String groupId, String reportId
        action.setParams({"clientCredaccessToken" : component.get("v.clientCredAccessToken"),"groupId" : component.get("v.groupId"), "reportId" : component.get("v.reportId"),"requestBody" : component.get("v.dataSetResponse") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var embedToken = response.getReturnValue();
                var embedUrl = 'https://app.powerbi.com/reportEmbed?groupId='+component.get("v.groupId")+'&reportId='+component.get("v.reportId");
                // Read report Id from Model
                var embedReportId = component.get("v.reportId");
                // Get models. models contains enums that can be used.
                var models = window['powerbi-client'].models;
                var config = {
                    type: 'report',
                    tokenType: models.TokenType.Embed,
                    accessToken: embedToken,
                    embedUrl: embedUrl,
                    id: embedReportId,
                    permissions: models.Permissions.All,
                    settings: {
                        filterPaneEnabled: false,
                        navContentPaneEnabled: false,
                         layoutType: models.LayoutType.MobileLandscape
                    }
                };
                
                // Get a reference to the embedded report HTML element
                var reportContainer = document.getElementById('reportContainer');  
                var report= powerbi.embed(reportContainer, config);
                var accountCount = component.get("v.accountCount");
                var accountDivision = component.get("v.accountDivision");
                if (accountCount == 1 && accountDivision == 'PEST') {
              		report.off('loaded');
            		report.on('loaded', function (event) {
                        var rptName = "Connect-GlobalDashboard-en-US";
                        var ulTab = rptName.indexOf('FBDashboard') > -1 ? 2 : 1;
                        var accountName = component.get("v.accountName");
                        var accountNumber = component.get("v.accountNumber"); 
                        var localLanguage = component.get("v.localLanguage");
                        if(localLanguage == null) {
                           localLanguage = 'en-US'; 
                        }
                        var doValue = accountName+" ("+accountNumber+")"; //THE FRESH MARKET #146 (THEF0243-0157)";
                        const unitLevelFilter = {
                            $schema: "http://powerbi.com/product/schema#basic",
                            target: {
                                table: "Service Address",
                                column: "Service Address Name"
                            },
                            operator: "In",
                            values: [doValue]
                        };
                        report.getPages().then(function (pages) {
                            report.bookmarksManager.getBookmarks().then(function (bookmarks) {
                                bookmarks.forEach(function (bookmark) {
                                    if (bookmark.displayName == ('UnitLevel'+localLanguage) || bookmark.displayName == ('UnitLevel' + '@Model.InitialLanguageBookmarkName'))
                                        report.bookmarksManager.apply(bookmark.name);
                                });
                            });
                            pages[ulTab].setFilters([unitLevelFilter]);
                        }).catch(function (errors) {
                            console.log(errors);
                        });
            		});
                }
                window.addEventListener('resize', $A.getCallback(function(){
                    if(component.isValid()) {                        
                        if (window.screen.availWidth < 768 || document.body.clientWidth <768){
                            console.log('in mobile responsive layout'); 
                             const newSettings = {
                                filterPaneEnabled: false,
                                navContentPaneEnabled: false,
                                layoutType: models.LayoutType.MobilePortrait
                            };  
                            $A.util.removeClass(reportContainer, 'normalHeight');
                            $A.util.addClass(reportContainer, 'extendedHeight');
                            report.updateSettings(newSettings).catch(error => { console.log('unable to set settings'); });
                            console.log('set report');
                        }else{
                            console.log('in normal layout');   
							$A.util.removeClass(reportContainer, 'extendedHeight');
                            $A.util.addClass(reportContainer, 'normalHeight');
                            const  newSettings2 = {
                                                    filterPaneEnabled: false,
                                                    navContentPaneEnabled: false,
                                                    layoutType: models.LayoutType.MobileLandscape
                                                };                            
                            report.updateSettings(newSettings2);
                        }
                                                
                    }
                }));
            } else {
                console.log("Embeded Key is empty");
            }
        });
        $A.enqueueAction(action);
      },
    
    getDataSet : function(component, event, helper) {
        var action = component.get("c.getDataSet");
        action.setParams({
            "clientCredaccessToken" : component.get("v.clientCredAccessToken"),
            "groupId" : component.get("v.groupId"),
            "reportId" : component.get("v.reportId"),
            "datasetId" : component.get("v.datasetId"),
            "role" : component.get("v.role")
        });
        action.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                component.set("v.dataSetResponse", rtnValue);
                helper.getPowerBiEmbedToken(component,event,helper);
            }
            else {
                console.log('Technical Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    getDashboards : function(component, event, helper) {
        var action = component.get("c.getUserDashboards");
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var rtnValue = response.getReturnValue();
                var cDashboards = rtnValue.dashboards;

                component.set("v.reportDetails", cDashboards);
                component.set("v.accountCount", rtnValue.accountCount);
                component.set("v.accountName", rtnValue.accountName);
                component.set("v.accountNumber", rtnValue.accountNumber);
                component.set("v.accountDivision", rtnValue.division);

                for(var i=0; i<cDashboards.length; i++) {
                    component.set("v.groupId", cDashboards[i].GroupId__c);
                    component.set("v.reportId", cDashboards[i].ReportId__c);
                    component.set("v.datasetId", cDashboards[i].Dataset__c);
                    component.set("v.localLanguage", cDashboards[i].Language__c);
                    component.set("v.role", cDashboards[i].Role__c);
                }
            }
        });
        $A.enqueueAction(action);
    }
})