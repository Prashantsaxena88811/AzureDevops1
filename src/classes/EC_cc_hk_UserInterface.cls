/* Class Name      :EC_cc_hk_UserInterface
* Description      :Hook class for UserInterface
* Created By       :Venkatesh Paladugu
* Created On       :06-04-2020

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Venkatesh Paladugu       06-04-2020                              Initial version (added GA&GTM script to <head> tag)
*
*/
global without sharing class EC_cc_hk_UserInterface extends ccrz.cc_hk_UserInterface.v004{
/*
*   Method name -   headContent
*   Parameters  -   Map<String,Object> inputData
*   Description -   method overrides/modifies headContent of cloud craze pages
*/
    global override Map<String,Object> headContent(Map<String,Object> inputData){
        Map<String,Object>  retData = new Map<String,Object>();
        ccrz.cclog.log('EC_cc_hk_UserInterface:headContent-->'+inputData.get(ccrz.cc_hk_UserInterface.HEAD_CONTENT ));
        if(!Test.isRunningTest()){
            retData = super.headContent(inputData);
        }
        
        Global_Static__c globalSettings = Global_Static__c.getValues('GA&GTM');
        String GA_ID = globalSettings.GA_ID__c;
        String GTM_AUTH = globalSettings.GTM_AUTH__c;
        String GTM_ENV = globalSettings.GTM_ENV__c;
        String GTM_ID = globalSettings.GTM_ID__c;
        
        ccrz.cclog.log('EC_cc_hk_UserInterface:retData:first-->'+retData);
        String objectFields = (String)retData.get(ccrz.cc_hk_UserInterface.HEAD_CONTENT);
        ccrz.cclog.log('objectFields-->'+objectFields);
        String gaScript = '<!-- Google Analytics --><script async="async" src="https://www.googletagmanager.com/gtag/js?id='+GA_ID+'"></script>';
        
        String gtmScript = '<script>window.dataLayer = window.dataLayer || [];function gtag(){dataLayer.push(arguments);}gtag(\'js\', new Date());gtag(\'config\', \''+GA_ID+'\');</script><!-- End GA & Google Tag Manager -->';
        
        String gtmEnv = '<!-- Google Tag Manager --><script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({\'gtm.start\':new Date().getTime(),event:\'gtm.js\'});var f=d.getElementsByTagName(s)[0],j=d.createElement(s),dl=l!=\'dataLayer\'?\'&l=\'+l:\'\';j.async=true;j.src=\'https://www.googletagmanager.com/gtm.js?id=\'+i+dl+ \'&gtm_auth='+GTM_AUTH +'&gtm_preview='+GTM_ENV +'&gtm_cookies_win=x\';f.parentNode.insertBefore(j,f);})(window,document,\'script\',\'dataLayer\',\''+GTM_ID +'\');</script><!-- End Google Tag Manager -->';        
    
        String hotJar = '<!-- Hotjar Tracking Code for https://connect.ecolab.com --><script>(function(h,o,t,j,a,r){h.hj=h.hj||function(){(h.hj.q=h.hj.q||[]).push(arguments)};h._hjSettings={hjid:1428695,hjsv:6};a=o.getElementsByTagName(\'head\')[0];r=o.createElement(\'script\');r.async=1;r.src=t+h._hjSettings.hjid+j+h._hjSettings.hjsv;a.appendChild(r);})(window,document,\'https://static.hotjar.com/c/hotjar-\',\'.js?sv=\');</script>';
        
        String upTrends = '<!-- Uptrends Header Code --><script src="/commerce/resource/Uptrends"></script><!-- Uptrends Header Code -->';

        String walkMe = '<!-- WalkMe Header Code --><script src="/commerce/resource/WalkMeCommunity"></script><!-- WalkMe Header Code -->';
        
        objectFields += gaScript+ '' +gtmScript+ '' +gtmEnv + '' + hotJar + '' + upTrends+ '' +walkMe;
        retData.put(ccrz.cc_hk_UserInterface.HEAD_CONTENT,objectFields);  
        ccrz.cclog.log('retData:final-->'+retData);
        return retData;
    }
}