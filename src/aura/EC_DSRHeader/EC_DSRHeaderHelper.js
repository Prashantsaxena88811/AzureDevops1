({
	fetchAccounts: function(component, event, helper) {
        var searchkey=component.get("v.searchAccountKey");
        var searchkeytemp='';
        var action1 = component.get("c.getContactAccounts");
		if (searchkey.length < 3){
            action1.setParams({
                searchKey : searchkeytemp
            });
        }
        else {action1.setParams({
                searchKey : component.get("v.searchAccountKey")
            });
        }

        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var acclistmap=response.getReturnValue();
                var accountList = [];
                var totalacc=0;
                var firstAccount = '';
                for ( var key in acclistmap ) {
                    var objlist=acclistmap[key];
                    totalacc++;
                    for(var i=0; i<objlist.length; i++ ){
                        var accnumber = objlist[i].AccountNumber;
                        var parAccName = objlist[i].ParentAccountName;
                        var parAccNumber = objlist[i].ParentAccountNumber;
                        var primaryRep = '';
                        if (objlist[i].PrimaryRepName !== undefined) {
                            primaryRep = objlist[i].PrimaryRepName; //PBI-126181
                        }
                        var adress = objlist[i].ShippingAddress;
                        var searchKeyLowerCase = searchkey.toLowerCase();
                        if(searchkey){
                            var parAccNamePosition = parAccName.toLowerCase().indexOf(searchKeyLowerCase);
                            var adressPosition = adress.toLowerCase().indexOf(searchKeyLowerCase);
                            var subname = parAccName.substr(parAccNamePosition, searchkey.length);
                            var subadress = adress.substr(adressPosition, searchkey.length);
                            if (parAccNumber){
                                var parentAccountNumberPosition = parAccNumber.toLowerCase().indexOf(searchKeyLowerCase);
                                var subparentAccountNumber = parAccNumber.substr(parentAccountNumberPosition, searchkey.length);
                            }
                            if (accnumber){
                                var accnumberPosition = accnumber.toLowerCase().indexOf(searchKeyLowerCase);
                                var subaccnumber = accnumber.substr(accnumberPosition, searchkey.length);
                            }
                            var primaryRepPosition = primaryRep.toLowerCase().indexOf(searchKeyLowerCase);
                            var subprimaryRep = primaryRep.substr(primaryRepPosition, searchkey.length);
                            var re = new RegExp(searchkey, 'ig');
                            if (searchkey.length > 2){
                                objlist[i].ParentAccountName=parAccName.replace(re, "<span class='keyhighlight'>" + subname + "</span>");
                                objlist[i].ShippingAddress=adress.replace(re, "<span class='keyhighlight'>" + subadress + "</span>");
                                if (parAccNumber){
                                    objlist[i].ParentAccountNumber=parAccNumber.replace(re, "<span class='keyhighlight'>" + subparentAccountNumber + "</span>");
                                }
                                if (accnumber){
                                    objlist[i].AccountNumber=accnumber.replace(re, "<span class='keyhighlight'>" + subaccnumber + "</span>");
                                }
                                objlist[i].PrimaryRepName = primaryRep.replace(re, "<span class='keyhighlight'>" + subprimaryRep + "</span>");  //PBI-126181
                            }
                        }
                        if(i==0){
                            firstAccount = objlist[i];
                        }
                    }
                    accountList.push({key:key, value:acclistmap[key], ParentAccNumber:objlist[0].ParentAccountNumber, ParentAccName:objlist[0].ParentAccountName, PrimaryRep:objlist[0].PrimaryRepName});
                }
                component.set("v.accountListMap", accountList);
                this.sortAccountsDisplay(component, event);
                component.set("v.TotalAccounts", totalacc);

                if(totalacc == 1 && searchkey.length == 0){
                    component.set("v.ShipToaccount",firstAccount);
                    component.set("v.isSingleAccount",true);
                    component.set("v.effectiveAccountNumber", firstAccount.AccountNumber);
                    helper.getServiceDates(component, event, helper, firstAccount);
                } else {
                    if ( totalacc == 0 && searchkey.length > 2){
                        component.set("v.NoSearchResults", true);
                    }
                    component.set("v.isModalOpen", true);
                }
            }
        });
        $A.enqueueAction(action1);
    },

    getServiceDates: function(component, event, helper, firstAccount) {
        component.set("v.showSpinner", true);
        document.body.style.overflowY = 'hidden';
        var serviceDates;
        var getServiceDates = component.get("c.getDSRServiceDetails");
        getServiceDates.setParams({
            recordId : component.get("v.effectiveAccountNumber"),
            serviceStart : ""
        });
        getServiceDates.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.showDate", true);
                var resp = JSON.parse(response.getReturnValue());
                resp = resp['serviceDateHistory'];
                var finalDates = [];
                var dateOffSet = new Map();
                for(var i=0;i<resp.length;i++){
                    var startDate = resp[i].serviceStart;
                    var dateValues = startDate.split(/[^0-9]/);
                    var formatDate =new Date (dateValues[0],dateValues[1]-1,dateValues[2],dateValues[3],dateValues[4],dateValues[5]);
                    if(dateValues.length > 6){
                        formatDate =new Date (dateValues[0],dateValues[1]-1,dateValues[2],dateValues[3],dateValues[4],dateValues[5],dateValues[6]);
                    } 
                    formatDate.setMinutes(formatDate.getMinutes()+(resp[i].gmtOffSetInMinutes));
                    var modifiedDate = helper.formatedDateValue(formatDate,helper);
                    finalDates.push(modifiedDate);
                    dateOffSet[modifiedDate] = resp[i].gmtOffSetInMinutes;
                }
                component.set("v.serviceDates", finalDates);
                component.set("v.selectedDate", finalDates[0]);
                component.set("v.dateOffSet", dateOffSet);
                if(firstAccount != null) {
                    helper.updateFirstSelecedAcc(component,firstAccount);
                } else {
                    helper.updateSelecedAcc(component, event, helper);
                }
            } else if (response.getState() === "ERROR") {
                component.set("v.errorMessage",'No service reports completed for this location');
                component.set("v.showError",true);
                component.set("v.showDate", false);
                helper.updateSelecedAcc(component, event, helper);
            }
        });
        $A.enqueueAction(getServiceDates);
    },
    pad: function(number) {
        if (number < 10) {
            return '0' + number;
        }
        return number;
    },
 
    formatedDateValue: function(formatDate,helper) {
        return formatDate.getFullYear() +
            '-' + helper.pad(formatDate.getMonth() + 1) +
            '-' + helper.pad(formatDate.getDate()) +
            'T' + helper.pad(formatDate.getHours()) +
            ':' + helper.pad(formatDate.getMinutes()) +
            ':' + helper.pad(formatDate.getSeconds()) +
            '.' + helper.pad(formatDate.getMilliseconds());
    },
    
    getServiceDetails: function(component, event, helper) {
        component.set("v.showSpinner", true);
        document.body.style.overflowY = 'hidden';
        var getServiceDetails;
        var getServiceDetails = component.get("c.getDSRServiceDetails");
        var startDate = component.get("v.selectedDate");
        var dateValues = startDate.split(/[^0-9]/);
        var formatDate =new Date (dateValues[0],dateValues[1]-1,dateValues[2],dateValues[3],dateValues[4],dateValues[5]);
        if(dateValues.length > 6){
            formatDate =new Date (dateValues[0],dateValues[1]-1,dateValues[2],dateValues[3],dateValues[4],dateValues[5],dateValues[6]);
        }
        var dateOffSet = component.get("v.dateOffSet");
        formatDate.setMinutes(formatDate.getMinutes()-(dateOffSet[component.get("v.selectedDate")]));
        var originalDate = helper.formatedDateValue(formatDate,helper);
        getServiceDetails.setParams({
            recordId : component.get("v.effectiveAccountNumber"),
            serviceStart : originalDate
        });
        getServiceDetails.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var resp = JSON.parse(response.getReturnValue());
                component.set("v.serviceDetails", resp);
                var compEvent = $A.get("e.c:EC_ReportSelectedEvent");
                compEvent.setParams({
                    "selectedServiceReport" : resp});
                compEvent.fire();
                component.set("v.showSpinner", false);
                helper.updateSelecedAcc(component, event, helper);
            } else if (response.getState() === "ERROR") {
                component.set("v.showSpinner", false);
                component.set("v.errorMessage",'No service reports completed for this location');
                component.set("v.showError",true);
                document.body.style.overflowY = 'scroll';
                helper.updateSelecedAcc(component, event, helper);
            }
        });
        $A.enqueueAction(getServiceDetails);
    },
    
    updateFirstSelecedAcc: function(component,firstAccount) {
        //enable body scroll bar on close
        document.body.style.overflowY = 'scroll';
        //var selectedAccount = event.getParam("eventShipToAccount");
 		component.set("v.selectedAccount", firstAccount);
        component.set("v.effectiveAccountId", firstAccount.ID);
        component.set("v.effectiveAccountName",firstAccount.Name);
        var accAddress = (firstAccount.ShippingAddress).replace(/(<([^>]+)>)/gi, " ");
        component.set("v.effectiveAccountAddress",accAddress);
        component.set("v.isModalOpen", false);
        component.set("v.showSpinner", false);
        $('.fixed-date-picklist').addClass('show-list');
    },

    updateSelecedAcc: function(component, event, helper) {
        //enable body scroll bar on close
        document.body.style.overflowY = 'scroll';
        var selectedAccount = event.getParam("eventShipToAccount");
 		component.set("v.selectedAccount", selectedAccount);
        component.set("v.effectiveAccountId", selectedAccount.ID);
        component.set("v.effectiveAccountName",selectedAccount.Name);
        var accAddress = (selectedAccount.ShippingAddress).replace(/(<([^>]+)>)/gi, " ");
        component.set("v.effectiveAccountAddress",accAddress);
        component.set("v.isModalOpen", false);
        component.set("v.showSpinner", false);
        $('.fixed-date-picklist').addClass('show-list')
    },

	openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        //component.set("v.isModalOpen", true);
        helper.fetchAccounts(component, event, helper);
        //hide body scroll bar on open
        document.body.style.overflowY = 'hidden';
    },

	sortAccountsDisplay : function(component, event){
        var newAccList = [], remAccList = [];
        var accountList = component.get("v.accountListMap");

        for (var i = 0; i < accountList.length; i++) {
            if(accountList[i].value[0].ID == component.get("v.effectiveAccountId")){
                newAccList.push(accountList[i]);
            } else {
                remAccList.push(accountList[i]);
            }
        }

        remAccList.sort((a,b) => (a.ParentAccName > b.ParentAccName) ? 1 : ((b.ParentAccName > a.ParentAccName) ? -1 : 0));
        remAccList.forEach(function(element) {
            newAccList.push(element);
        });

        component.set("v.accountListMap", newAccList);
    }
})