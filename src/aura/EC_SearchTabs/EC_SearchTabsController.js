({
    init: function (component, event, helper) {
        helper.outageHelper(component);
        var searchTypeOptions = [
            { id: "orderBy", label: 'Order Number', selected: true },
            { id: "dateRange", label: 'Date Range' }
        ];
        component.set('v.searchTypeOptions', searchTypeOptions);
        component.set('v.loaded', false);
        component.set('v.totalProducts', 10);
        var totalProds = component.find('prods');

        helper.isCompVisible(component);
        helper.fetchSDSDocs(component, helper);
        helper.fetchProduct(component, event, helper);
        helper.fetchOrders(component, helper);
        helper.getQuickList(component, event, helper);


    },
    productTab: function (component, event, helper) {
        var tab1 = component.find('productsId');
        var TabOnedata = component.find('productsDataId');

        var tab2 = component.find('OrdersId');
        var TabTwoData = component.find('ordersDataId');

        var tab3 = component.find('quickListId');
        var TabThreeData = component.find('quickListDataId');

        var tab4 = component.find('sdsId');
        var TabFourData = component.find('sdsDataId');

        //show and Active products tab
        $A.util.addClass(tab1, 'slds-active');
        $A.util.addClass(TabOnedata, 'slds-show');
        $A.util.removeClass(TabOnedata, 'slds-hide');
        // Hide and deactivate others tab
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');

        $A.util.removeClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-show');
        $A.util.addClass(TabThreeData, 'slds-hide');

        $A.util.removeClass(tab4, 'slds-active');
        $A.util.removeClass(TabFourData, 'slds-show');
        $A.util.addClass(TabFourData, 'slds-hide');
    },
    orderTab: function (component, event, helper) {

        component.set("v.ordersSelected", true);

        var tab1 = component.find('productsId');
        var TabOnedata = component.find('productsDataId');

        var tab2 = component.find('OrdersId');
        var TabTwoData = component.find('ordersDataId');

        var tab3 = component.find('quickListId');
        var TabThreeData = component.find('quickListDataId');

        var tab4 = component.find('sdsId');
        var TabFourData = component.find('sdsDataId');

        //show and Active vegetables Tab
        $A.util.addClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-hide');
        $A.util.addClass(TabTwoData, 'slds-show');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');

        $A.util.removeClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-show');
        $A.util.addClass(TabThreeData, 'slds-hide');

        $A.util.removeClass(tab4, 'slds-active');
        $A.util.removeClass(TabFourData, 'slds-show');
        $A.util.addClass(TabFourData, 'slds-hide');
    },
    quicklistTab: function (component, event, helper) {

        component.set("v.quicklistSelected", true);

        var tab1 = component.find('productsId');
        var TabOnedata = component.find('productsDataId');

        var tab2 = component.find('OrdersId');
        var TabTwoData = component.find('ordersDataId');

        var tab3 = component.find('quickListId');
        var TabThreeData = component.find('quickListDataId');

        var tab4 = component.find('sdsId');
        var TabFourData = component.find('sdsDataId');

        //show and Active vegetables Tab
        $A.util.addClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-hide');
        $A.util.addClass(TabThreeData, 'slds-show');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');

        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');

        $A.util.removeClass(tab4, 'slds-active');
        $A.util.removeClass(TabFourData, 'slds-show');
        $A.util.addClass(TabFourData, 'slds-hide');
    },
    sdsTab: function (component, event, helper) {

        component.set("v.sdsSelected", true);

        var tab1 = component.find('productsId');
        var TabOnedata = component.find('productsDataId');

        var tab2 = component.find('OrdersId');
        var TabTwoData = component.find('ordersDataId');

        var tab3 = component.find('quickListId');
        var TabThreeData = component.find('quickListDataId');

        var tab4 = component.find('sdsId');
        var TabFourData = component.find('sdsDataId');

        //show and Active vegetables Tab
        $A.util.addClass(tab4, 'slds-active');
        $A.util.removeClass(TabFourData, 'slds-hide');
        $A.util.addClass(TabFourData, 'slds-show');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');

        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');

        $A.util.removeClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-show');
        $A.util.addClass(TabThreeData, 'slds-hide');
    },
    handleApplicationEvent: function (component, event) {
        var message = event.getParam("searchedData");
        console.log("$$$$$$$$$$$");
        console.log(message);
        // set the handler attributes based on event data
        component.set("v.searchedStringValue", message);

    },
    toggleDropDown: function (component, event, helper) {
        event.target.parentElement.getElementsByTagName("ul")[0].classList.toggle("toggle");
    },
    selectSortOption: function (component, event, helper) {
        var nodes = event.target.parentElement.childNodes;
        nodes.forEach(function (node) {
            node.classList.remove("selected");
        });
        event.target.classList.add("selected");
        event.target.parentElement.parentElement.getElementsByTagName("span")[0].innerText = event.target.innerText;
        event.target.parentElement.classList.toggle("toggle");
        var chosenSortBy = event.target.innerText.trim();
        var currentTab = event.target.closest(".slds-tabs--default__content").getAttribute("aria-labelledby");
        var currentTab = currentTab.split("_")[0].toLocaleLowerCase().trim(),
            data = [],
            pageSelected = 1;
        switch (currentTab) {
            case 'product':
                if (chosenSortBy.toLocaleLowerCase() === "last purchased") {
                    component.set("v.productSortBy", "purchasedOn|DESC");
                } else {
                    component.set("v.productSortBy", "purchasedOn|ASC");
                }
                var sortBy = component.get("v.productSortBy").split("|");
                data = component.get("v.productsMasterList");
                data = data.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
                var paginatedData = helper.paginateData(data, pageSelected, component.get("v.pageSize"), helper);
                component.set("v.currentProductPage", pageSelected);
                component.set("v.productPagination", paginatedData);
                component.set("v.productsList", paginatedData.data);
                break;
            case 'orders':
            component.set("v.ordersSortBy", "orderDate|DESC");
               
                var sortBy = component.get("v.ordersSortBy").split("|");
                data = component.get("v.ordersMasterList");
                data = data.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
                var paginatedData = helper.paginateData(data, pageSelected, component.get("v.pageSize"), helper);
                component.set("v.currentOrdersPage", pageSelected);
                component.set("v.ordersPagination", paginatedData);
                component.set("v.Orders", paginatedData.data);
                break;

            default:
                break;
        }
    },
    changePage: function (component, event, helper) {
        var currentTab = event.target.closest(".slds-tabs--default__content").getAttribute("aria-labelledby");
        var currentTab = currentTab.split("_")[0].toLocaleLowerCase(),
            currentPage = 1,
            data = [],
            actionRequired = true,
            pageSelected = event.target.getAttribute("data-value");
        switch (currentTab) {
            case "product":
                currentPage = component.get("v.currentProductPage");
                if (!isNaN(parseInt(parseInt(pageSelected)))) {
                    pageSelected = parseInt(pageSelected);
                } else {
                    if (event.target.parentElement.classList.contains("disabled")) {
                        actionRequired = false;
                    }
                    pageSelected = pageSelected === "prev" ? currentPage - 1 : currentPage + 1;
                }
                if (actionRequired) {
                    data = component.get("v.productsMasterList");
                    var paginatedData = helper.paginateData(data, pageSelected, component.get("v.pageSize"), helper);
                    component.set("v.currentProductPage", pageSelected);
                    component.set("v.productPagination", paginatedData);
                    component.set("v.productsList", paginatedData.data);
                }
                break;
            case "orders":
                currentPage = component.get("v.currentOrdersPage");
                if (!isNaN(parseInt(parseInt(pageSelected)))) {
                    pageSelected = parseInt(pageSelected);
                } else {
                    if (event.target.parentElement.classList.contains("disabled")) {
                        actionRequired = false;
                    }
                    pageSelected = pageSelected === "prev" ? currentPage - 1 : currentPage + 1;
                }
                if (actionRequired) {
                    data = component.get("v.ordersMasterList");
                    var paginatedData = helper.paginateData(data, pageSelected, component.get("v.pageSize"), helper);
                    component.set("v.currentOrdersPage", pageSelected);
                    component.set("v.ordersPagination", paginatedData);
                    component.set("v.Orders", paginatedData.data);
                }
                break;
            case "quicklist":
                currentPage = component.get("v.currentQuickListPage");
                if (!isNaN(parseInt(parseInt(pageSelected)))) {
                    pageSelected = parseInt(pageSelected);
                } else {
                    if (event.target.parentElement.classList.contains("disabled")) {
                        actionRequired = false;
                    }
                    pageSelected = pageSelected === "prev" ? currentPage - 1 : currentPage + 1;
                }
                if (actionRequired) {
                    data = component.get("v.quicklistMasterList");
                    var paginatedData = helper.paginateData(data, pageSelected, component.get("v.pageSize"), helper);
                    component.set("v.currentQuickListPage", pageSelected);
                    component.set("v.quicklistPagination", paginatedData);
                    component.set("v.QuickList", paginatedData.data);
                }
                break;
            case "sds":
                currentPage = component.get("v.currentDocumentPage");
                if (!isNaN(parseInt(parseInt(pageSelected)))) {
                    pageSelected = parseInt(pageSelected);
                } else {
                    if (event.target.parentElement.classList.contains("disabled")) {
                        actionRequired = false;
                    }
                    pageSelected = pageSelected === "prev" ? currentPage - 1 : currentPage + 1;
                }
                if (actionRequired) {
                    data = component.get("v.documentsMasterList");
                    var paginatedData = helper.paginateData(data, pageSelected, component.get("v.pageSize"), helper);
                    component.set("v.currentDocumentPage", pageSelected);
                    component.set("v.documentsPagination", paginatedData);
                    component.set("v.sdsDocsList", paginatedData.data);
                }
                break;
            default:
                break;
        }

    },
    //To Be used if count of attributes required on active tabs
    /*  setAttributeValue: function(component, event, helper){
          var eventValue = event.getParam("attributeValue");
          var prodeventValue = event.getParam("prodattributeValue");
          var ordereventValue = event.getParam("orderattributeValue");
          var quicklisteventValue = event.getParam("quicklistattributeValue");
          var sdseventValue = event.getParam("sdsDocattributeValue");
          var activeTab = event.getParam("activeTab");
          
         // if(activeTab == "product"){
              var ordCountElement = document.getElementById("prdCount");
              ordCountElement.classList.remove("slds-hide");
              component.set("v.productsCount", component.get("v.productsCount"));
         // }else if(activeTab == "order"){
              var ordCountElement = document.getElementById("ordCount");
              ordCountElement.classList.remove("slds-hide");
              component.set("v.totalOrderCount", ordereventValue);
        // }else if(activeTab == "quicklist"){
              var ordCountElement = document.getElementById("qcCount");
              ordCountElement.classList.remove("slds-hide");
              component.set("v.totalQuickListCount", quicklisteventValue);
        //  }else if(activeTab == "document"){
              var ordCountElement = document.getElementById("docCount");
              ordCountElement.classList.remove("slds-hide");
              component.set("v.totalDocumentCount", component.get("v.DocCount"));
         //  }
      }*/
})