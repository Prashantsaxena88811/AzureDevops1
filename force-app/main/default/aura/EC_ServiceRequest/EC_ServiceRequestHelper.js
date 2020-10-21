({
    MAX_FILE_SIZE: 5000000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.isDocError", false);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        if (fileInput != null && fileInput.length > 0) {
            var file = fileInput[0];
            var self = this;
            var fileTypes =  [];
            var action = component.get("c.getFileTypes");
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                    var ret = response.getReturnValue();
                    console.log("ret:"+ret)
                    fileTypes=ret;
                }
            var isFileTypeCompatible = fileTypes.indexOf(file.type) > -1;
            // check the selected file size, if select file size greter then MAX_FILE_SIZE,
            // then show a alert msg to user,hide the loading spinner and return from function  
            if(isFileTypeCompatible) {
                if (file.size > self.MAX_FILE_SIZE) {
                component.set("v.isDocError", true);
                component.set("v.isDocAvailable", false);
                component.set("v.isDocSuccess", false);
                component.set("v.isDocSuccessMessage", '');
                component.set("v.DocumentInitialName", 'File size cannot exceed 5MB. Selected file size is ' + (file.size/1000000).toFixed(1)+'MB');
                component.find('fileId').set('v.files', []);
                } else {
                    component.set("v.isDocAvailable", true);
                    component.set("v.isDocError", false);
                    component.set("v.isDocSuccess", true);
                    component.set("v.isDocSuccessMessage", 'File is currently being uploaded.');
                    setTimeout($A.getCallback(() => component.set("v.isDocSuccess", false)), 2000);
                }
            } else {
                component.set("v.isDocError", true);
                component.set("v.isDocAvailable", false);
                component.set("v.isDocSuccess", false);
                component.set("v.isDocSuccessMessage", '');
                component.set("v.DocumentInitialName", 'File format: '+ (file.type) +' is not supported.Please use a supported file format');
                component.find('fileId').set('v.files', []);
                
            }
           });
            $A.enqueueAction(action); 
        }
        return;
    },
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        if(attachId == undefined || attachId == null || file == undefined || file == null || fileContents == undefined || fileContents == null || attachId == '' || file == '' || fileContents == '' ){
            return;
        }
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: attachId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id 
            var state = response.getState();
            var rtnValue = response.getReturnValue();
            if (state === "SUCCESS") {
            	console.log("Saved successfully with ID: " + rtnValue)
            } else if (state === "INCOMPLETE") {
                console.log("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    createCase : function(AccValue,requestTypeValue,categoryValue,NoteValue,ConPhoneValue, soldTo, email, contactName, component,event,helper) {
        var action = component.get("c.createServiceRequestCase");
        var regMap = component.get("v.ServiceRegistrationMap");
        var docName = component.get("v.DocumentInitialName");
        var isDocAvailable = component.get("v.isDocAvailable");
        regMap["Account"]=AccValue;
        regMap["RequestType"]=requestTypeValue;
        regMap["Category"]=categoryValue; 
        regMap["Note"]=NoteValue; 
        regMap["Phone"]=ConPhoneValue; 
        regMap["soldTo"]=soldTo;
        regMap["email"]=email;
        regMap["contactName"] = contactName;      
        
        action.setParams({
            "registrationDetails": regMap
        });
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue.split('::')[0] == 'SUCCESS' && isDocAvailable && docName !== '' && docName !== null && docName !== undefined) {
                var caseId = rtnValue.split('::')[1];
                // $A.get('e.force:refreshView').fire();
                var fileInput = component.find("fileId").get("v.files");
                var objFileReader = new FileReader();
                var self = this;
                objFileReader.onload = $A.getCallback(function() {
                    var fileContents = objFileReader.result;
                    var base64 = 'base64,';
                    var dataStart = fileContents.indexOf(base64) + base64.length;
        
                    fileContents = fileContents.substring(dataStart);
                    // call the uploadProcess method 
                    var startPosition = 0;
                    // calculate the end size or endPostion using Math.min() function which is return the min. value   
                    var endPosition = Math.min(fileContents.length, startPosition + self.CHUNK_SIZE);

                    // start with the initial chunk, and set the (last parameter)is null in begin
                    self.uploadInChunk(component, file, fileContents, startPosition, endPosition, caseId);
                });
                // get the first file using array index[0]  
                if (fileInput  != undefined && fileInput != null && fileInput != '' && fileInput.length > 0) {
                    var file = fileInput[0];
                    objFileReader.readAsDataURL(file);
                }
            }
            
            var requestTabs = component.find('requestTabs');
            $A.util.toggleClass(requestTabs, 'slds-hide');

            var newServiceReq = component.find('newServiceRequest');
            $A.util.toggleClass(newServiceReq, 'slds-hide');

            var contactInfo = component.find('contactInfo');
            $A.util.toggleClass(contactInfo, 'slds-hide');
            
            var showSuccessMsg = component.find('successMsg');
            $A.util.toggleClass(showSuccessMsg, 'slds-hide');
        });
        
        $A.enqueueAction(action);
    },
    fetchPicklistValues: function(component,controllerField, dependentField) {
        
        var action = component.get("c.getDependentMap");
        action.setParams({
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        }); 
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var StoreResponse = response.getReturnValue();
                
                component.set("v.depnedentFieldMap",StoreResponse);
                
                var listOfkeys = []; 
                var ControllerField = []; 
                
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                   // ControllerField.push('');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                component.set("v.listControllingValues", ControllerField);

                //Need to remove once service request is available for all divisions
                var ListOfDependentFields = StoreResponse['INSTITUTIONAL'];
                if (ListOfDependentFields.length > 0) {
                    component.set("v.bDisabledDependentFld", false);
                    this.fetchDepValues(component, ListOfDependentFields);
                } else {
                    component.set("v.bDisabledDependentFld", true);
                    component.set("v.listDependingValues", ['']);
                }
                //Need to remove once service request is available for all divisions
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    fetchContactDetails : function(component,event,helper){
        var action = component.get("c.getContactName");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                component.set("v.ContactName",ret);
            }
        });
        $A.enqueueAction(action);
	},
    
    fetchDepValues: function(component, ListOfDependentFields) { 
        var dependentFields = [];
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        console.log(dependentFields);
        component.set("v.listDependingValues", dependentFields);
        
    },
    fillServiceForm : function(component,event,helper){
        
        component.set("v.account", '');
        component.set("v.isDocAvailable", false);
        component.set("v.notes", '');
        component.set("v.isDocError", false);
        component.set("v.DocumentInitialName", '');
        component.set("v.selectedAccount", '');
        component.set("v.objDetail", '');

        var actContactFirstName = component.get("v.actContactFirstName");
        var actContactLastName = component.get("v.actContactLastName");
        var actPhone = component.get("v.actPhone");
        var actUserEmail = component.get("v.actUserEmail");
        component.set("v.contactFirstName", actContactFirstName);
        component.set("v.contactLastName", actContactLastName);
        component.set("v.phone", actPhone);
        component.set("v.userEmail", actUserEmail);

        // if (typeof grecaptcha !== undefined && grecaptcha != null && grecaptcha != '') {
        //     grecaptcha.reset();
        // }
        var requestTabs = component.find('requestTabs');
        $A.util.toggleClass(requestTabs, 'slds-hide');
        
        var newServiceReq = component.find('newServiceRequest');
        $A.util.toggleClass(newServiceReq, 'slds-hide');

        var contactInfo = component.find('contactInfo');
        $A.util.toggleClass(contactInfo, 'slds-hide');

        var successMsg = component.find('successMsg');
        $A.util.addClass(successMsg, 'slds-hide');
        component.find('fileId').set('v.files', []);
    },
    newServiceRequest : function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/servicerequest"
        });
        urlEvent.fire();
    },
    cancelFile : function(component,event,helper) {
        var action = component.get("c.updateCancel");      
        action.setCallback(this, function(a){
            console.log('Cancel=='+a.getReturnValue());
        }) ;
        $A.enqueueAction(action);
    },
    fetchAccounts: function(component, event) {
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

        console.log('searchAccountKey',component.get("v.searchAccountKey"));

        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){                
                var acclistmap=response.getReturnValue();
                console.log("SF Accts:+++++ ", acclistmap);
                var accountList = [];
                var totalacc=0;
                for ( var key in acclistmap ) {
                    var objlist=acclistmap[key];
                    totalacc++;
                    for(var i=0; i<objlist.length; i++ ){
                        var accnumber = objlist[i].AccountNumber;
                        var parAccName = objlist[i].ParentAccountName; 
                        var parAccNumber = objlist[i].ParentAccountNumber;
                        var primaryRep = objlist[i].PrimaryRepName; //PBI-126181
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
                                console.log('obj',objlist[i]); 
                            }
                        }
                    }
                    accountList.push({key:key, value:acclistmap[key], ParentAccNumber:objlist[0].ParentAccountNumber, ParentAccName:objlist[0].ParentAccountName, PrimaryRep:objlist[0].PrimaryRepName});
                }
                component.set("v.accountListMap", accountList);
                this.sortAccountsDisplay(component, event); //PBI-128708
                component.set("v.TotalAccounts", totalacc);				                
                console.log("Accounts:+++++ ", component.get("v.accountListMap"));
                if ( totalacc == 0 && searchkey.length > 2){ 
                    component.set("v.NoSearchResults", true);                    
                }
            }
            else{
                console.log('Error occurred:+++++ ', response.getState());
            }  
        });
        $A.enqueueAction(action1);
    },

    //PBI-128708: To display Selected Account on top of the list
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
    },
})