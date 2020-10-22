({
    fetchSDSDocs: function (component, helper) {
        var sdsDocs;

        var url = window.location.href;
        var valueEntered = /term=([^&]+)/.exec(url)[1];
        valueEntered = decodeURIComponent(valueEntered);
        var decodedValue = valueEntered.replace(/\+/g, '%20');
        decodedValue = decodeURIComponent(decodedValue);

        component.set("v.SearchText", decodedValue);
        var action = component.get("c.getDocsSearchResultsAura");

        action.setParams({
            searchText: valueEntered
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                sdsDocs = ret;
                var doclength = 0;
                sdsDocs.forEach(function (element) {
                    doclength += element.lstGroupedSDSBean.length;
                })

                if (ret.length === 0) {
                    component.set("v.emptyDocumentsWrapper", true);
                }
                var sortBy = component.get("v.documentsSortBy").split("|");
                sdsDocs = sdsDocs.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
                component.set("v.documentsMasterList", sdsDocs);
                var paginatedData = helper.paginateData(sdsDocs, component.get("v.currentProductPage"), component.get("v.pageSize"), helper);
                component.set("v.documentsPagination", paginatedData);
                component.set("v.sdsDocsList", paginatedData.data);

            }
        });
        $A.enqueueAction(action);
    },
    clearAll: function (component, event) {
        // this method set all tabs to hide and inactive
        var getAllLI = document.getElementsByClassName("customClassForTab");
        var getAllDiv = document.getElementsByClassName("customClassForTabData");
        for (var i = 0; i < getAllLI.length; i++) {
            getAllLI[i].className = "slds-tabs--scoped__item slds-text-title--caps customClassForTab";
            getAllDiv[i].className = "slds-tabs--scoped__content slds-hide customClassForTabData";
        }
    },
    fetchProduct: function (component, event, helper) {
        var products;
        var prodLength;

        var url = window.location.href;

        var valueEntered = /term=([^&]+)/.exec(url)[1];

        var decodedValue = valueEntered.replace(/\+/g, '%20');

        decodedValue = decodeURIComponent(decodedValue)

        valueEntered = decodeURIComponent(valueEntered);
        var action = component.get("c.getProdSearchResultsAura");
        action.setParams({
            searchText: valueEntered
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                products = ret;

                component.set("v.SearchTextField", decodedValue);
                if (ret.length) {
                    component.set("v.emptyList", true);
                } else {
                    var cmpTarget = component.find('showEmptyProductList');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
                if(window.matchMedia("(min-width: 768px) and (max-width:1365px)").matches) {
                    products.forEach(function (prod) {
                        prod.Name = prod.Name.replace(/(.{37})..+/, "$1…");
                    });    
                } else {
                products.forEach(function (prod) {
                    prod.Name = prod.Name.replace(/(.{48})..+/, "$1…");
                });
            }
                var sortBy = component.get("v.productSortBy").split("|");
                products = products.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
                component.set("v.productsMasterList", products);
                var paginatedData = helper.paginateData(products, component.get("v.currentProductPage"), component.get("v.pageSize"), helper);
                component.set("v.productPagination", paginatedData);
                component.set("v.productsList", paginatedData.data);
            }
        });
        $A.enqueueAction(action);
    },
    getQuickList: function (component, event, helper) {

        var url = window.location.href;
        var valueEntered = /term=([^&]+)/.exec(url)[1];
        valueEntered = decodeURIComponent(valueEntered);
        var decodedValue = valueEntered.replace(/\+/g, '%20');
        decodedValue = decodeURIComponent(decodedValue);
        var action = component.get("c.getQuickListAura");
        action.setParams({
            searchText: valueEntered
        });

        component.set("v.SearchQuickList", decodedValue);
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                if (Object.keys(ret).length) {
                    component.set("v.emptyQuickList", true);
                }
                console.log('Return value in the sample component is +++++++++' + JSON.stringify(ret));
                var quickLists = [];
                var count = 0;
                for (var key in ret) {
                    count += ret[key].length;
                    var remain = ret[key].length % 3;
                    quickLists.push({ classLength: ret[key].length > 3 ? ret[key].length - remain : 0, value: ret[key], key: key });
                }
                var retLength = count;

                component.set("v.quicklistMasterList", quickLists);
                var paginatedData = helper.paginateData(quickLists, component.get("v.currentQuickListPage"), component.get("v.pageSize"), helper);
                component.set("v.quicklistPagination", paginatedData);
                component.set("v.QuickList", paginatedData.data);
            }
        });
        $A.enqueueAction(action);
    },
    fetchOrders: function (component, helper) {
        var orders;

        var url = window.location.href;
        var valueEntered = /term=([^&]+)/.exec(url)[1];
        valueEntered = decodeURIComponent(valueEntered);
        var decodedValue = valueEntered.replace(/\+/g, '%20');
        decodedValue = decodeURIComponent(decodedValue);
        component.set("v.SearchTextField", decodedValue);
        var action = component.get("c.getOrderSearchResultsAura");

        action.setParams({
            searchText: valueEntered
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                if (Object.keys(ret).length) {
                    component.set("v.emptyOrderList", true);
                }
                orders = ret;
                orders.forEach(function (item) {
                    item["shipToAddress"] = "";
                    if (item.hasOwnProperty("shipToLine1")) {
                        item.shipToAddress += item["shipToLine1"]
                    }
                    if (item.hasOwnProperty("shipToLine2")) {
                        item.shipToAddress += "<br/>" + item["shipToLine2"]
                    }
                    if (item.hasOwnProperty("shipToLine3")) {
                        item.shipToAddress += "<br/>" + item["shipToLine3"]
                    }
                    if (item.hasOwnProperty("shipToRestAdd")) {
                        item.shipToAddress += "<br/>" + item["shipToRestAdd"]
                    }
                    
                    item["billToAddress"] = "";
                    if (item.hasOwnProperty("billToLine1")) {
                        item.billToAddress += item["billToLine1"]
                    }
                    if (item.hasOwnProperty("billToLine2")) {
                        item.billToAddress += "<br/>" + item["billToLine2"]
                    }
                    if (item.hasOwnProperty("billToLine3")) {
                        item.billToAddress += "<br/>" + item["billToLine3"]
                    }
                    if (item.hasOwnProperty("shipToRestAdd")) {
                        item.billToAddress += "<br/>" + item["billToRestAdd"]
                    }
                });
                var sortBy = component.get("v.ordersSortBy").split("|");
                orders = orders.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
                component.set("v.ordersMasterList", orders);
                var paginatedData = helper.paginateData(orders, component.get("v.currentOrdersPage"), component.get("v.pageSize"), helper);
                component.set("v.ordersPagination", paginatedData);
                component.set("v.Orders", paginatedData.data);
            }
        });
        $A.enqueueAction(action);
    },
    isCompVisible: function (component) {

        var action = component.get("c.compVisible");
        
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                
                var ret = response.getReturnValue();
                var i;
                for (i = 0; i < ret.length; i++) {
                    if (ret[i].permName == $A.get("$Label.c.EC_Search_Except_Quicklist")) {
                       
                        component.set("v.searchExceptQuicklist", ret[i].permVal);
                    }

                }

            }
        });
       $A.enqueueAction(action);
    },
    paginateData: function (items, page, per_page, helper) {
        var page = page || 1,
            per_page = per_page || 10,
            offset = (page - 1) * per_page,

            paginatedItems = items.slice(offset).slice(0, per_page),
            total_pages = Math.ceil(items.length / per_page),
            pageOptions = (total_pages === 1 ? [1] : helper.genOptions(page, total_pages)),
            mobilePageOptions = helper.genMobilePageOptions(page, total_pages);
        return {
            page: page,
            per_page: per_page,
            pre_page: page - 1 ? page - 1 : null,
            next_page: (total_pages > page) ? page + 1 : null,
            pre_action: page - 1 ? false : true,
            next_action: (total_pages > page) ? false : true,
            total: items.length,
            total_pages: total_pages,
            data: paginatedItems,
            pageOptions: pageOptions,
            mobPageOptions: mobilePageOptions,
        };
    },
    genMobilePageOptions: function (c, m) {
        var delta = 1,
            rangeOptions = [],
            start = ((c - delta <= 0) ? 1 : c - delta),
            end = ((start + 7 <= m) ? start + 7 : m) + 1;
        if (m > 7 && start + 7 > m) {
            start = start - ((start + 7) - m);
            end = start + 7 + 1;

        }
        if (m < 7) {
            start = 1;
        }
        for (let i = start; i < end; i++) {
            rangeOptions.push(i);
        }
        return rangeOptions;
    },
    genOptions: function (c, m) {
        var delta = 2,
            range = [],
            rangeWithDots = [],
            l;
        if (c > 1) {
            delta = 1;
        } else if (m === 1) {
            delta = 0;
        }

        range.push(1)
        for (let i = c - delta; i <= c + delta; i++) {
            if (i < m && i > 1) {
                range.push(i);
            }
        }
        range.push(m);

        for (let i of range) {
            if (l) {
                if (i - l === 2) {
                    rangeWithDots.push(l + 1);
                } else if (i - l !== 1) {
                    rangeWithDots.push('...');
                }
            }
            rangeWithDots.push(i);
            l = i;
        }

        return rangeWithDots;
    },
    dynamicSort: function (property, type, order) {
        var sortOrder = order === "ASC" ? 1 : -1;
        if (type === "string") {
            return function (a, b) {
                if (sortOrder == -1) {
                    return b[property].localeCompare(a[property]);
                } else {
                    return a[property].localeCompare(b[property]);
                }
            }
        } else if (type === "date") {
            return function (a, b) {
                if (sortOrder == -1) {
                    return new Date(b[property]) - new Date(a[property]);
                } else {
                    return new Date(a[property]) - new Date(b[property]);
                }
            }
        }
    },

outageHelper : function(component){
        var action = component.get("c.outageRedirect");
         action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                var ret = response.getReturnValue();
                if(!ret){
                    var outageURL = $A.get("$Label.c.EC_OutageRedirect");
                    window.open(outageURL, "_self"); 
                } else {
                    component.set("v.showSpinner", false);
                }
            } 
        });
        
         $A.enqueueAction(action);
    
    }

})