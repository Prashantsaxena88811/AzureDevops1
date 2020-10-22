({
    // initialize on page load
    init: function (component, event, helper) {
        helper.outageHelper(component);
        component.set('v.loaded', false);
        helper.fetchOrders(component, helper);
        helper.isCompVisible(component);
    },
    // view invoice
    viewInvoice: function (component, event, helper) {
        var eUrl = $A.get("e.force:navigateToURL");
        eUrl.setParams({
            "url": "invoice"
        });
        eUrl.fire();
    },
    // change page
    changePage: function (component, event, helper) {
        var current = component.get("v.currentPage");
        var pageSelected = event.target.getAttribute("data-value");
        var orders,
            actionRequired = true;
        if (!component.get("v.isFilterApplied")) {
            orders = component.get("v.ordersMasterList");
        } else {
            orders = component.get("v.filteredOrderMasterLst");
        }
        if (!isNaN(parseInt(parseInt(pageSelected)))) {
            pageSelected = parseInt(pageSelected);
        } else {
            if (event.target.parentElement.classList.contains("disabled")) {
                actionRequired = false;
            }
            pageSelected = pageSelected === "prev" ? current - 1 : current + 1;
        }
        if (actionRequired) {
            var paginatedData = helper.paginateData(orders, pageSelected, component.get("v.pageSize"), helper);
            component.set("v.currentPage", pageSelected);
            component.set("v.pagination", paginatedData);
            component.set("v.Orders", paginatedData.data);
        }
    },
    // toggle option dropdown
    toggleDropDown: function (component, event, helper) {
        event.target.parentElement.getElementsByTagName("ul")[0].classList.toggle("toggle");
    },
    // select option to sort products
    selectSortOption: function (component, event, helper) {
        var nodes = event.target.parentElement.childNodes;
        nodes.forEach(function (node) {
            node.classList.remove("selected");
        });
        event.target.classList.add("selected");
        event.target.parentElement.parentElement.getElementsByTagName("span")[0].innerText = event.target.innerText;
        event.target.parentElement.classList.toggle("toggle");
        var chosenSortBy = event.target.innerText;
        var sortByValue = component.get("v.sortBy").split("|");
        if (chosenSortBy.toLocaleLowerCase() === "last purchased") {
            component.set("v.sortBy", "orderDate|DESC");
        } else {
            component.set("v.sortBy", "orderDate|ASC");
        }
        var orders = [];
        if (!component.get("v.isFilterApplied")) {
            orders = component.get("v.ordersMasterList");
        } else {
            orders = component.get("v.filteredOrderMasterLst");
        }
        var sortBy = component.get("v.sortBy").split("|");
        var sortedData = orders.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
        var paginatedData = helper.paginateData(sortedData, 1, component.get("v.pageSize"), helper);
        component.set("v.pagination", paginatedData);
        component.set("v.Orders", paginatedData.data);
    },
    // function call after page render
	doneRendering: function(component, event, helper) {
    	var phfromDate = component.find("fromDateField");
        var phtoDate = component.find("toDateField");
        phfromDate.set('v.placeholder','DD/MM/YYYY');
        phtoDate.set('v.placeholder','DD/MM/YYYY');
	},
    // filter option change
    filterChange: function (component, event, helper) {
        var selectElem = component.find("searchType").getElement();
        var statusType = selectElem.value.trim(),
            poNum = component.find("poNumber").get("v.value").trim(),
            accNum = component.find("accNumber").get("v.value").trim(),
            fromDate = component.find("fromDateField").get("v.value"),
            toDate = component.find("toDateField").get("v.value");
		   /* Validate Date format */
        var fromdateFormat = component.find("fromDateField").get("v.value");
        var todateFormat = component.find("toDateField").get("v.value");
        var pattern = /^([0-9]{4})-([0-9]{2})-([0-9]{2})$/;

        if(statusType.length > 9) {
            selectElem.parentElement.parentElement.parentElement.classList.add("resize-select");
        } else {
            selectElem.parentElement.parentElement.parentElement.classList.remove("resize-select");
        }
        if (!!fromDate && !!toDate) {
            var fromDate = new Date(fromDate);
            fromDate = new Date(fromDate.getFullYear(), fromDate.getMonth(), fromDate.getDate());
            var toDate = new Date(toDate);
            toDate = new Date(toDate.getFullYear(), toDate.getMonth(), toDate.getDate());


			if ((fromDate <= toDate) && ((pattern.test(fromdateFormat)) && (pattern.test(todateFormat)))){
                component.set("v.isDateInputError", false);
            } else {
                component.set("v.isDateInputError", true);
            }
        }
        if ((statusType !== "" || poNum !== "" || accNum !== "" || !!fromDate || !!toDate) && !component.get("v.isDateInputError")) {
            component.set("v.searchDisable", false);
        } else {
            component.set("v.searchDisable", true);
            helper.resetSearch(component, event, helper);
        }
    },
    // perform search
    performSearch: function (component, event, helper) {
        component.set("v.isFilterApplied", true);
        component.set("v.NoOrdersMatch", false);
        var obj = {};
        obj.orderStatus = component.find("searchType").getElement().value.trim();
        obj.poNumber = component.find("poNumber").get("v.value").trim();
        obj.accountNumber = component.find("accNumber").get("v.value").trim();
        obj.orderDateFrom = component.find("fromDateField").get("v.value");
        obj.orderDateTo = component.find("toDateField").get("v.value");

        if (!!obj.orderDateFrom && !!obj.orderDateTo) {
            var fromDate = new Date(obj.orderDateFrom);
            fromDate = new Date(fromDate.getFullYear(), fromDate.getMonth(), fromDate.getDate());
            var toDate = new Date(obj.orderDateTo);
            toDate = new Date(toDate.getFullYear(), toDate.getMonth(), toDate.getDate());

        if (fromDate <= toDate) {
                component.set("v.isDateInputError", false);
            } else {
                component.set("v.isDateInputError", true);
            }
        }
        if (!component.get("v.isDateInputError")) {
            var filteredData = helper.filterData(component.get("v.ordersMasterList"), obj);
            if (component.get("v.isFilterApplied")) {
                component.set("v.filteredOrderMasterLst", filteredData);
            }
            var paginatedData = helper.paginateData(filteredData, 1, component.get("v.pageSize"), helper);
            component.set("v.pagination", paginatedData);
            var sortBy = component.get("v.sortBy").split("|");
            var model = paginatedData.data.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
            if(model.length <= 0){
                component.set("v.NoOrdersMatch", true);
            }
            component.set("v.Orders", model);
        }
    },
    // clear search criteria
    clearSearch: function (component, event, helper) {
        component.find("searchType").getElement().options[0].selected = 'selected';
        component.find("searchType").getElement().dispatchEvent(new Event('change'));
        component.find("poNumber").set("v.value", "");
        component.find("accNumber").set("v.value", "");
        component.find("fromDateField").set("v.value", "");
        component.find("toDateField").set("v.value", "");
        component.set("v.searchDisable", true);
        component.set("v.isFilterApplied", false);
        component.set("v.isDateInputError", false);
        helper.resetSearch(component, event, helper);
    },
    // error url redirect
    openBillTrust : function (cmp, event, helper) {
        var errorURL = $A.get("$Label.c.EC_PaymetPortalLink") ;
        window.open(errorURL);
    }
})