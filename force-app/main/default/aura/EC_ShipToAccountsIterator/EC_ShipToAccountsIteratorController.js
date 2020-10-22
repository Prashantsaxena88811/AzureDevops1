({
    doInit: function (component, event, helper) {
        var effAccDivision = '';
        if(component.get("v.ShipToaccount.EC_Division__c")){
            effAccDivision = component.get("v.ShipToaccount.EC_Division__c");
        }  
        var nalcoDivisions = $A.get("$Label.c.EC_DivisionValueNACLO");
        if(effAccDivision.length > 0 && nalcoDivisions.toLowerCase().includes(effAccDivision.toLowerCase())) {
            component.set("isNalco", true);
        } 
    },
    
	onRowSelect: function(component, event, helper) {
        var accmap=component.get("v.accListMap");
		$A.util.removeClass('selected');        
        for(var key in accmap){
            var acc=accmap[key].value;   
            if (acc != undefined && acc != null && acc != '') {
                for(var i=0; i<acc.length; i++ ){
                    var accId=acc[i].ID;               
                    component.set("v.accId",accId);
                    var divId=document.getElementById(component.get("v.accId"));
                    divId.closest('.sta-body').classList.remove('selected');
                    divId.closest('.acc-item-wrapper').classList.remove('selected');                
                    $A.util.addClass(divId, 'slds-hide');
                }
            }         
        }
		console.log('effectiveAccount',component.get("v.effectiveAccount"));        
        var accId=component.get("v.ShipToaccount.ID");
        var divId=document.getElementById(component.get("v.ShipToaccount.ID"));
        $A.util.removeClass(divId, 'slds-hide');
        divId.closest('.sta-body').classList.add('selected');
		divId.closest('.acc-item-wrapper').classList.add('selected');        
    },
    onAccountSelect: function(component, event, helper) {        
        var compEvent = component.getEvent("selectedShipTo");
		var name=component.get("v.ShipToaccount.Name");
        var number=component.get("v.ShipToaccount.AccountNumber");
		var accid=component.get("v.ShipToaccount.ID");        
        var address=component.get("v.ShipToaccount.ShippingAddress");
        var soldTo=component.get("v.ShipToaccount.ParentAccountNumber");
        if (soldTo == undefined || soldTo == null || soldTo == '') {
            soldTo = number;
        }
        var allDetails='';
        var selaccmap = { Name: name, accountNumber:number , ID:accid, accDetails: allDetails, soldTo: soldTo, ShippingAddress:address};
        
        compEvent.setParams({ 
          "eventShipToAccount" : selaccmap});
        console.log('reg event');
		compEvent.fire();         
    },
})