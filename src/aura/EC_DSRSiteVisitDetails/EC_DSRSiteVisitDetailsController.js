({
  doInit : function(component, event, helper) {
    var serviceDetails = component.get("v.serviceDetails");

    //service Comments
    var serviceCommentCount = 0;
		serviceDetails.service.findingConditions.findingCondition.forEach(function (item) {
      if (item.globalConditionCategoryId == $A.get("$Label.c.EC_DSR_Json_Other")) {
        serviceCommentCount += 1;
      }
    });
    if (serviceCommentCount > 0) { 
      component.set("v.showServicecomments", true);
      component.set("v.serviceCommentsLength", serviceCommentCount);
      if (serviceCommentCount > 3) {
        component.set("v.serviceCommentsminLength", '3');
      } else {
        component.set("v.serviceCommentsminLength", serviceCommentCount);
      }
    } else {
      component.set("v.showServicecomments", false);
    }

    //Material Used
    var allInterior = [];
    var allExterior = [];
    var int = 0;
    var ext = 0
    var allListarea = [];
    var allPesttype = [];
    var i = 0;
    var j = 0;
    serviceDetails.service.serviceProducts.serviceProduct.forEach(function (items) {
      items.serviceProductAreas.serviceProductArea.forEach(function (item) {
        if (item.proximityName == $A.get("$Label.c.EC_DSR_Json_Interior") || item.proximityName == $A.get("$Label.c.EC_DSR_Json_IntroductionPoint")) {
          allInterior[int] = item.areaName;
          int++;
        }
        if (item.proximityName == $A.get("$Label.c.EC_DSR_Json_Exterior")) {
          allExterior[ext] = item.areaName;
          ext++;
        }
        if (item.areaName) {
          allListarea[i] = item.areaName;
          i++;
        }
      });
      if (items.targetPestName) {
        allPesttype[j] = items.targetPestName;
        j++;
      }
    });
    if (int > 0 || ext > 0) {
      component.set("v.showMaterialTable", true);
    } else {
      component.set("v.showMaterialTable", false);
    }

    //Remove Duplicate item
    function getUnique(array){
      var uniqueArray = [];
      for(i=0; i < array.length; i++){
          if(uniqueArray.indexOf(array[i]) === -1) {
              uniqueArray.push(array[i]);
          }
      }
      return uniqueArray;
    }
    
    var uniqueInterior = getUnique(allInterior);
    component.set("v.interiorLength", uniqueInterior.length);

    var uniqueExterior = getUnique(allExterior);
    component.set("v.exteriorLength", uniqueExterior.length);

    component.set("v.materialLength", uniqueInterior.length + uniqueExterior.length);

    var uniqueArea = getUnique(allListarea);
    component.set("v.listArea", uniqueArea);

    var uniquePesttype = getUnique(allPesttype);
    component.set("v.listPesttype", uniquePesttype);

    //Jquery - Material Filter
    $("body").on("change", ".mat-filter select", function() {
      $(".mat-filter select").not(this).find('option:eq(0)').prop('selected', true);
      if ($(this).find("option:selected").index() > 0) {
        var value = $(this).val().toLowerCase();
        $(".mat-table .row-2").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
      } else {
        $(".mat-table .row-2").show();
      }
    });

    //Q and A
    var qaCount = 0;
    serviceDetails.service.serviceSurveyAnswers.serviceSurveyAnswer.forEach(function (item) {
      if (item.printFlag == true) {
        qaCount += 1;
      }
    });
    if (qaCount > 0) {
      component.set("v.qaLength", qaCount);
      component.set("v.showQandA", true);
    } else {
      component.set("v.showQandA", false);
    }

    //Regulatory Comments
    var regulatoryCount = 0;
    serviceDetails.reportConfigurations.reportConfiguration.forEach(function (item) {
      if (item.reportConfigurationTypeID == $A.get("$Label.c.EC_DSR_Json_RegulatoryComment")) {
        regulatoryCount += 1;
      }
    });
    if (regulatoryCount > 0) {
      component.set("v.regulatoryCommentsLength", regulatoryCount);
      component.set("v.showRegulatory", true);
      if (regulatoryCount > 2) {
        component.set("v.regulatoryCommentsminLength", '2');
      } else {
        component.set("v.regulatoryCommentsminLength", regulatoryCount);
      }
    } else {
      component.set("v.showRegulatory", false);
    }

    var jquery = component.get('c.jqueryInit');
    $A.enqueueAction(jquery);
  },
  //Pie Chart
  jqueryInit : function() {
    jQuery("document").ready(function(){
      function sliceSize(dataNum, dataTotal) {
          return (dataNum / dataTotal) * 360;
        }
        function addSlice(sliceSize, pieElement, offset, sliceID, color) {
          $(pieElement).append("<div class='slice "+sliceID+"'><span></span></div>");
          var offset = offset - 1;
          var sizeRotation = -179 + sliceSize;
          $("."+sliceID).css({
            "transform": "rotate("+offset+"deg) translate3d(0,0,0)"
          });
          $("."+sliceID+" span").css({
            "transform"       : "rotate("+sizeRotation+"deg) translate3d(0,0,0)",
            "background-color": color
          });
        }
        function iterateSlices(sliceSize, pieElement, offset, dataCount, sliceCount, color) {
          var sliceID = "s"+dataCount+"-"+sliceCount;
          var maxSize = 179;
          if(sliceSize<=maxSize) {
            addSlice(sliceSize, pieElement, offset, sliceID, color);
          } else {
            addSlice(maxSize, pieElement, offset, sliceID, color);
            iterateSlices(sliceSize-maxSize, pieElement, offset+maxSize, dataCount, sliceCount+1, color);
          }
        }
        function createPie(dataElement, pieElement) {
          var listData = [];
          $(dataElement+" span").each(function() {
            listData.push(Number($(this).html()));
          });
          var listTotal = 0;
          for(var i=0; i<listData.length; i++) {
            listTotal += listData[i];
          }
          var offset = 0;
          var color = [
            "#007AC9", 
            "#E5F0F7"
          ];
          for(var i=0; i<listData.length; i++) {
            var size = sliceSize(listData[i], listTotal);
            iterateSlices(size, pieElement, offset, i, 0, color[i]);
            $(dataElement+" li:nth-child("+(i+1)+")").css("border-color", color[i]);
            offset += size;
          }
        }
        createPie(".pieID.legend", ".pieID.pie");
    });
  }
})