({
    doInit: function (component, event, helper) {
        helper.openModel(component, event, helper);
    },
	openModel: function(component, event, helper) {
        helper.openModel(component, event, helper);
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.searchAccountKey", '');
        component.set("v.NoSearchResults", false);
        component.set("v.isModalOpen", false);
        //enable body scroll bar on close
        document.body.style.overflowY = 'scroll';
    },
    onAccountSelect: function(component, event, helper) {
        var selectedAccount = event.getParam("eventShipToAccount");
        component.set("v.effectiveAccountNumber", selectedAccount.accountNumber);
        component.set("v.searchAccountKey", '');
        helper.getServiceDates(component, event, helper, null);
    },
    dateSelected: function(component, event, helper) {
        console.log('date selected '+event.currentTarget.dataset.value);
        component.set("v.selectedDate", event.currentTarget.dataset.value);
        helper.getServiceDetails(component, event, helper);
        $('.date-pick').removeClass('show-dropdown');
        $('.date-pick-dropdown').slideUp();
        $('.fixed-date-picklist').removeClass('show-list');
        $('.report-box').removeClass('expanded');
        $('.report-box-bottom').slideUp();
        $('.tile-box').removeClass('expanded');
        $('.tile-lineitems').removeClass('collapsed');
    },
    searchAccounts: function(component, event, helper){
        component.set("v.NoSearchResults", false);
        helper.fetchAccounts(component, event, helper);
    },
    closeErrorModel: function(component, event, helper) {
        component.set("v.showError", false);
        $('.fixed-date-picklist').removeClass('show-list');
        document.body.style.overflowY = 'scroll';
    }
})