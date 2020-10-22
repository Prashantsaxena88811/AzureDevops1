({
    // fetch order list
    fetchOrders: function (component, helper) {
      var orders;
      var checkPayerConfigs = component.get("c.checkPayerPermission");
        checkPayerConfigs.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
            var ret = response.getReturnValue();
            console.log("checkPayerConfigs1:"+ret)
            component.set("v.isEligibleForPaymentPortal", ret);
            }
        });
        $A.enqueueAction(checkPayerConfigs);
      var isAthenaEnabled = false;
      component.set("v.isAthenaEnabled", false);
      var actionAthenaSwitch = component.get("c.getAthenaSwitchSetting");
      actionAthenaSwitch.setCallback(this, function (response) {
          if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
              var ret = response.getReturnValue();
              isAthenaEnabled = ret;
              console.log("isAthenaEnabled1:"+ret)
              component.set("v.isAthenaEnabled", ret);
          }
      if(isAthenaEnabled){
          var action = component.get("c.getAthenaPastOrders");
          action.setStorable();
      } else {
          var action = component.get("c.getPastOrder");
      }
      action.setCallback(this, function (response) {
          if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
              var ret = response.getReturnValue();
              var orderLength = ret.length;
              component.set("v.ordersCount", orderLength);
              if (ret.length) {
                  component.set("v.emptyOrderList", true);
              } else {
                  var cmpTarget = component.find('orderListEmptyWrapper');
                  $A.util.removeClass(cmpTarget, 'slds-hide');
              }
              orders = ret;
              if(isAthenaEnabled){
                  var respObj = JSON.parse(ret);
                  orders = respObj.orders;
              }
              orders.forEach(function (item) {
                  if(isAthenaEnabled){
                    item["shipToAddress"] = "";
                    if (item.orderShiptoAddress.hasOwnProperty("orderShipToStreet")) {
                        item.shipToAddress += item.orderShiptoAddress["orderShipToStreet"];
                    }
                    if (item.orderShiptoAddress.hasOwnProperty("orderShipToCity")) {
                        item.shipToAddress += "<br/>" + item.orderShiptoAddress["orderShipToCity"];
                    }
                    if (item.orderShiptoAddress.hasOwnProperty("orderShipToState")) {
                        item.shipToAddress += ", " + item.orderShiptoAddress["orderShipToState"];
                    }
                    if (item.orderShiptoAddress.hasOwnProperty("orderShipToCountry")) {
                        item.shipToAddress += ", " + item.orderShiptoAddress["orderShipToCountry"];
                    }
                    if (item.orderShiptoAddress.hasOwnProperty("orderShipToPostalCode")) {
                        item.shipToAddress += ", " + item.orderShiptoAddress["orderShipToPostalCode"];
                    }
                  } else {
                    item["shipToAddress"] = "";
                    if (item.hasOwnProperty("shipToLine1")) {
                        item.shipToAddress += item["shipToLine1"];
                    }
                    if (item.hasOwnProperty("shipToLine2")) {
                        item.shipToAddress += "<br/>" + item["shipToLine2"];
                    }
                    if (item.hasOwnProperty("shipToLine3")) {
                        item.shipToAddress += "<br/>" + item["shipToLine3"];
                    }
                    if (item.hasOwnProperty("shipToRestAdd")) {
                        item.shipToAddress += "<br/>" + item["shipToRestAdd"];
                    }

                    item["billToAddress"] = "";
                    if (item.hasOwnProperty("billToLine1")) {
                        item.billToAddress += item["billToLine1"];
                    }
                    if (item.hasOwnProperty("billToLine2")) {
                        item.billToAddress += "<br/>" + item["billToLine2"];
                    }
                    if (item.hasOwnProperty("billToLine3")) {
                        item.billToAddress += "<br/>" + item["billToLine3"];
                    }
                    if (item.hasOwnProperty("shipToRestAdd")) {
                        item.billToAddress += "<br/>" + item["billToRestAdd"];
                    }
                  }
              });
              var orderTypeMaster = [];
              if (isAthenaEnabled) {
                component.set("v.sortBy", 'orderCreationDate|DSC');
              }
              var sortBy = component.get("v.sortBy").split("|");
              orders = orders.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));


              orders.forEach(function (item) {
                  if(isAthenaEnabled) {
                    //Get status value names
                    var orderManagementStatus = $A.get("$Label.c.EC_AthenaOrderStatus_OrderManagement");
                    var lineOrderManagementStatus = $A.get("$Label.c.EC_AthenaOrderStatus_LineOrderManagement");
                    var commercialIssuesStatus = $A.get("$Label.c.EC_AthenaOrderStatus_CommercialIssues");
                    var stockAvailabilityStatus = $A.get("$Label.c.EC_AthenaOrderStatus_StockAvailability");
                    var prepShipStatus = $A.get("$Label.c.EC_AthenaOrderStatus_PreparingToShip");
                    var inTransitStatus = $A.get("$Label.c.EC_AthenaOrderStatus_InTransit");
                    var deliveredStatus = $A.get("$Label.c.EC_AthenaOrderStatus_Delivered");
                    var inProgressStatus = $A.get("$Label.c.EC_AthenaOrderStatus_InProgress");
                    var statusNotAvailable = $A.get("$Label.c.EC_AthenaOrderStatus_StatusNotAvailable");
                    var orderProcessing = $A.get("$Label.c.EC_AthenaOrderStatus_OrderProcessing");

                    // Setting orderLineStatuses attribute to an array of each line item status
                    var lineItems = item.orderLineItems;
                    var lineStatuses = [];
                    if (lineItems != null) {
                        lineItems.forEach(function (lineItem) {
                            var lineStatus = statusNotAvailable;
                            if (lineItem.orderLineStage != null) {
                                if (lineItem.orderLineStage == "Order Management") {
                                    lineStatus = orderProcessing;
                                }
                                else if (lineItem.orderLineStage == "Commercial Issues") {
                                    lineStatus = commercialIssuesStatus;
                                }

                                else if (lineItem.orderLineStage == "Stock Availability") {
                                    lineStatus = stockAvailabilityStatus;
                                }
                            }
                            else if (lineItem.deliveries != null) {
                                var deliveryItems = lineItem.deliveries;
                                var numPreparing = 0;
                                var numInTransit = 0;
                                var numDelivered = 0;
                                deliveryItems.forEach(function (delItem) {
                                    if (delItem.deliveryStage == "Preparing To Ship") {
                                        numPreparing++;
                                    }
                                    else if (delItem.deliveryStage == "In Transit") {
                                        numInTransit++;
                                    }
                                    else if (delItem.deliveryStage == "Delivered") {
                                        numDelivered++;
                                    }
                                });
                                if (numPreparing == lineItem.deliveryLineCount) {
                                    lineStatus = prepShipStatus;
                                }
                                else if (numInTransit == lineItem.deliveryLineCount) {
                                    lineStatus = inTransitStatus;
                                }
                                else if (numDelivered == lineItem.deliveryLineCount) {
                                    lineStatus = deliveredStatus;
                                }
                                else {
                                    lineStatus = inProgressStatus;
                                }
                            }
                            lineItem.orderLineStage = lineStatus;
                            lineStatuses.push(lineStatus);
                        });
                    }
                    item.lineStatuses = lineStatuses;
                    // Calculating overall order status based on line item statuses
                    var orderStage = item.orderStage;
                    var status = statusNotAvailable;
                    if (lineStatuses.includes(commercialIssuesStatus) || orderStage == "Commercial Issues") {
                        status = commercialIssuesStatus;
                    }
                    else if (lineStatuses.includes(stockAvailabilityStatus)) {
                        status = stockAvailabilityStatus;
                    }
                    else if (lineStatuses.includes(prepShipStatus) || lineStatuses.includes(inProgressStatus) || lineStatuses.includes(lineOrderManagementStatus)) {
                        status = orderProcessing;
                    }
                    else if(lineStatuses.includes(inTransitStatus)){
                        var allInTransit = true;
                        lineStatuses.forEach(function (lineStat) {
                            if(lineStat != inTransitStatus) {
                                allInTransit = false;
                            }
                        });
                        if (allInTransit) {
                            status = inTransitStatus;
                        }
                        else {
                            status = orderProcessing;
                        }
                    }
                    else if(lineStatuses.includes(deliveredStatus)) {
                        var allDelivered = true;
                        lineStatuses.forEach(function (lineStat) {
                            if(lineStat != deliveredStatus && lineStat != statusNotAvailable) {
                                allDelivered = false;
                            }
                        });
                        if (allDelivered) {
                            status = deliveredStatus;
                        }
                        else {
                            status = inProgressStatus;
                        }
                    }
                    else if (lineStatuses.includes(lineOrderManagementStatus)) {
                        status = orderManagementStatus;
                    }
                    item.orderStage = status;
                    orderTypeMaster.push(status);
                    // orderTypeMaster.push(item.orderDeliveryBlockDesc);
                  } else {
                    orderTypeMaster.push(item.orderStatus);
                  }
              });
              orderTypeMaster = orderTypeMaster.filter(function (v, i, self) {
                  return i == self.indexOf(v);
              });
              var orderTypes = [];
              orderTypes.push({ id: "", label: 'All', selected: true });
              orderTypeMaster.forEach(function (item) {
                  var obj = {};
                  obj.id = item.toLocaleLowerCase();
                  obj.label = item;
                  orderTypes.push(obj);
              });
              var paginatedData = helper.paginateData(orders, component.get("v.currentPage"), component.get("v.pageSize"), helper);
              console.log("page :",paginatedData);
              component.set("v.ordersMasterList", orders);
              console.log("orders are: "+JSON.stringify(orders));
              component.set('v.searchTypeOptions', orderTypes);
              component.set("v.pagination", paginatedData);
              component.set("v.Orders", paginatedData.data);
          }
      });
      $A.enqueueAction(action);
      });
      $A.enqueueAction(actionAthenaSwitch);
  },
  // show and hide data spinner
  showSpinner: function (component) {
      var spinnerMain = component.find("Spinner");
      $A.util.removeClass(spinnerMain, "slds-hide");
  },
  hideSpinner: function (component) {
      var spinnerMain = component.find("Spinner");
      $A.util.addClass(spinnerMain, "slds-hide");
  },
  // pagination of order list data
  paginateData: function (items, page, per_page, helper) {
      var pageNo = page || 1,
          per_pageNo = per_page || 10,
          offset = (pageNo - 1) * per_pageNo,

          paginatedItems = items.slice(offset).slice(0, per_pageNo),
          total_pages = Math.ceil(items.length / per_pageNo),
          pageOptions = (total_pages === 1 ? [1] : helper.genOptions(pageNo, total_pages));
      return {
          page: pageNo,
          per_page: per_pageNo,
          pre_page: pageNo - 1 ? pageNo - 1 : null,
          next_page: (total_pages > pageNo) ? pageNo + 1 : null,
          pre_action: page - 1 ? false : true,
          next_action: (total_pages > pageNo) ? false : true,
          total: items.length,
          total_pages: total_pages,
          data: paginatedItems,
          pageOptions: pageOptions
      };
  },
  genOptions: function (startPage, maxPage) {
      var delta = 2,
          range = [],
          rangeWithDots = [],
          dots;

      if (startPage > 1) {
          delta = 1;
      } else if (maxPage === 1) {
          delta = 0;
      }

      range.push(1);

      for (var i = startPage - delta; i <= startPage + delta; i++) {
          if (i < maxPage && i > 1) {
              range.push(i);
          }
      }
      range.push(maxPage);

      for (var _i = 0, _range = range; _i < _range.length; _i++) {
          var _i2 = _range[_i];

          if (dots) {
              if (_i2 - dots === 2) {
                  rangeWithDots.push(dots + 1);
              } else if (_i2 - dots !== 1) {
                  rangeWithDots.push('...');
              }
          }

            rangeWithDots.push(_i2);
            dots = _i2;
        }
        return rangeWithDots;
    },
    // order list sort dynamic option selection
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
    // order lsit component visibility check
    isCompVisible: function (component) {
        var action = component.get("c.compVisible");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                var ret = response.getReturnValue();
                var i;
                for (i = 0; i < ret.length; i++) {

                    if (ret[i].permName == $A.get("$Label.c.EC_View_Invoices")) {
                        component.set("v.viewInvoice", ret[i].permVal);
                    }
                    else if (ret[i].permName == $A.get("$Label.c.EC_Buy_Online")) {
                        component.set("v.buyOnline", ret[i].permVal);
                    }
                    else if (ret[i].permName == $A.get("$Label.c.EC_View_Price")) {
                        component.set("v.viwPrice", ret[i].permVal);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    // filter order list data
    filterData: function (data, criteria) {
        var results = data;
        if (criteria.orderStatus.trim().length > 0) {
            results = results.filter(function (item) {
                return (item.orderStage === undefined ? "" : item.orderStage).toLocaleLowerCase() === criteria.orderStatus.toLocaleLowerCase();
            });
        }
        if (criteria.poNumber.trim().length > 0) {
            results = results.filter(function (item) {
                return ((item.orderCustomerPO === undefined ||  item.orderCustomerPO == null) ? "" : item.orderCustomerPO).toString().toLocaleLowerCase() === criteria.poNumber.toLocaleLowerCase();
            });
        }
        if (criteria.accountNumber.trim().length > 0) {
            results = results.filter(function (item) {
                return ((item.orderShipToNumber === undefined ||  item.orderShipToNumber == null) ? "" : item.orderShipToNumber).toString().toLocaleLowerCase() === criteria.accountNumber.toLocaleLowerCase();
            });
        }
        if (!!criteria.orderDateFrom && !!criteria.orderDateTo && criteria.orderDateFrom.trim().length > 0 && criteria.orderDateTo.trim().length > 0) {
            var fromDate = new Date(criteria.orderDateFrom);
            fromDate = new Date(fromDate.getFullYear(), fromDate.getMonth(), fromDate.getDate());
            var toDate = new Date(criteria.orderDateTo);
            toDate = new Date(toDate.getFullYear(), toDate.getMonth(), toDate.getDate());
            if (fromDate <= toDate) {
                results = results.filter(function (item) {
                    var itemDate = new Date(item.orderCreationDate);
                    itemDate = new Date(itemDate.getFullYear(), itemDate.getMonth(), itemDate.getDate());
                    return itemDate >= fromDate && itemDate <= toDate;
                });
            }
        }
        return results;
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
    },
    // reset search criteria
    resetSearch: function (component, event, helper) {
        var data = component.get("v.ordersMasterList");
        var sortBy = component.get("v.sortBy").split("|");
        var sortedData = data.sort(helper.dynamicSort(sortBy[0], "date", sortBy[1]));
        var paginatedData = helper.paginateData(sortedData, 1, component.get("v.pageSize"), helper);
        component.set("v.pagination", paginatedData);
        component.set("v.Orders", paginatedData.data);
        component.set("v.ordersMasterList", sortedData);
    }
})