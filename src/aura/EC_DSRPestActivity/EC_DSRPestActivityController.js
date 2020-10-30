({
	doInit : function(component, event, helper) {
        var serviceDetails = component.get("v.serviceDetails");
        var pestActivityCount = 0;
        var structuralCount = 0;
        var sanitationCount = 0;
        var prepCount = 0
		serviceDetails.service.findingConditions.findingCondition.forEach(function (item) {
            if (item.globalConditionCategoryId == $A.get("$Label.c.EC_DSR_Json_PestActivity")) {
                pestActivityCount += 1;
            }
            if (item.globalConditionCategoryId == $A.get("$Label.c.EC_DSR_Json_Structural")) {
                structuralCount += 1;
            }
            if (item.globalConditionCategoryId == $A.get("$Label.c.EC_DSR_Json_Sanitation")) {
                sanitationCount += 1;
            }
            if (item.globalConditionCategoryId == $A.get("$Label.c.EC_DSR_Json_Prep")) {
                prepCount += 1;
            }
        });

        if (pestActivityCount > 0) {
            component.set("v.pestActivityLength", pestActivityCount);
            component.set("v.showPeastActivity", true);
        } else {
            component.set("v.pestActivityLength", "0");
            component.set("v.showPeastActivity", false);
        }

        if ((structuralCount + sanitationCount + prepCount) > 0) {
            component.set("v.actionItemLength", structuralCount + sanitationCount + prepCount);
            component.set("v.showActionItem", true);
        } else {
            component.set("v.actionItemLength", "0");
            component.set("v.showActionItem", false);
        }

        if (structuralCount > 0) {
            component.set("v.structuralLength", structuralCount);
            component.set("v.showStructural", true);
        } else {
            component.set("v.structuralLength", "0");
            component.set("v.showStructural", false);
        }

        if (sanitationCount > 0) {
            component.set("v.sanitationLength", sanitationCount);
            component.set("v.showSanitation", true);
        } else {
            component.set("v.sanitationLength", "0");
            component.set("v.showSanitation", false);
        }

        if (prepCount > 0) {
            component.set("v.prepLength", prepCount);
            component.set("v.showPrep", true);
        } else {
            component.set("v.prepLength", "0");
            component.set("v.showPrep", false);
        }       
	}
})