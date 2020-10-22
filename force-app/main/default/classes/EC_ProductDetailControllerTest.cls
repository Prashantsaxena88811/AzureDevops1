@isTest
public without sharing class  EC_ProductDetailControllerTest {
    
    static testMethod void processMethod() {
        Set<String> ProdPkgCode = new Set<String>();
        ProdPkgCode.add('91');
        ProdPkgCode.add('36');
        String salesorg = '1001';
        Test.startTest();
        EC_ProductDetailController obj = new EC_ProductDetailController();
        system.debug('obj'+obj);
        Map<String,List<String>> resp = EC_ProductDetailController.getDeliveryTemplateCode(ProdPkgCode,salesorg);
        EC_ProductDetailController.isTankNumberApplicable(ProdPkgCode,salesorg);
        System.assert(null != resp);
        Test.stopTest();        
    }
}