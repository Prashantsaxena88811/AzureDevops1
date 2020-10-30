@isTest
public class EC_PowerBICalloutMock implements HttpCalloutMock {
    String Endpoint;
    string PBIOAuthToken_V1 = '{"access_token":"sjfsfksfsp4oi9882-24202fkmfslkkjfdsf"}';
    string PBIOAuthToken_V2 = '{}';
    string PBIOAuthToken_V3 = '{"access_token":true}';
    string PBIDataSet_V1 = '{"IsEffectiveIdentityRequired":true,"IsOnPremGatewayRequired":true,"IsRefreshable":false}';
    string PBIDataSet_V2 = '{"IsEffectiveIdentityRequired":false,"IsOnPremGatewayRequired":true,"IsRefreshable":false}';
    string PBIDataSet_V3 = '{"IsEffectiveIdentityRequired":true,"IsOnPremGatewayRequired":false,"IsRefreshable":true}';
    string PBIDataSet_V4 = '{}';
    string PBIDataSet_V5 = '{"IsEffectiveIdentityRequired":true}';
    string PBIEmbedToken_V1 = '{"@odata.context":"http://wabi-us-north","token":"H4sIAAAAAAAEAB2Tt66EVgAF_-W1WCInSy7IsOS4QEcOu-R0wfK_-9n9FEczOn","tokenId":"c7f9ced4-d001-4476-9","expiration":"2020-09-23T10:17:11Z"}';
    string PBIEmbedToken_V2 = '{}';
    string PBIEmbedToken_V3 = '{"token":true}';

    Map<String, String> rtnMap = new Map<string, String> {
        'PBIOAuthToken_V1' => PBIOAuthToken_V1,
        'PBIOAuthToken_V2' => PBIOAuthToken_V2,
        'PBIOAuthToken_V3' => PBIOAuthToken_V3,
        'PBIDataSet_V1' => PBIDataSet_V1,
        'PBIDataSet_V2' => PBIDataSet_V2,
        'PBIDataSet_V3' => PBIDataSet_V3,
        'PBIDataSet_V4' => PBIDataSet_V4,
        'PBIDataSet_V5' => PBIDataSet_V5,
        'PBIEmbedToken_V1' => PBIEmbedToken_V1,
        'PBIEmbedToken_V2' => PBIEmbedToken_V2,
        'PBIEmbedToken_V3' => PBIEmbedToken_V3
    };

    public EC_PowerBICalloutMock(String Endpoint) {
        this.Endpoint = Endpoint;
    }
    
    public HttpResponse respond(HttpRequest request) {

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody(rtnMap.get(Endpoint));

        if(Endpoint == 'PBIOAuthToken_V2' || Endpoint == 'PBIDataSet_V4' || Endpoint == 'PBIEmbedToken_V2') {
            response.setStatusCode(500);
        }

        return response;
    }

}