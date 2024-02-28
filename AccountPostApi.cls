public class AccountPostApi {
    
    public void postApi()
    {
        Integration_User_Access_Token__c  Access_Token_Custom_Setting = Integration_User_Access_Token__c.getValues('Integration User Credentials');
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();        
        request.setEndpoint( URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/Account/');
        String bodyString = '{"accId":"001H4000004dkGiIAI"}';
        system.debug('Reqeust Body -->  '+ bodyString);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + Access_Token_Custom_Setting.Access_Token__c);
        //  request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());       
        //  request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        
        
        request.setBody(bodyString);
        HttpResponse response = http.send(request);
        system.debug('Responsee--->   ' + response);  
        system.debug('response.getBody()--->   ' + response.getBody());  
    }
    @future(callout=true) 
    public static void callOutUpdateAccessToken()
    {
        Integration_User_Access_Token__c mc = Integration_User_Access_Token__c.getValues('Integration User Credentials');
        system.debug(mc);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();        
        request.setEndpoint( URL.getOrgDomainUrl().toExternalForm()+'/services/oauth2/token');
        String bodyString = 'grant_type='+mc.Grant_Type__c+'&client_id='+mc.Client_Id__c+'&client_secret='+mc.Client_Secret__c;
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(bodyString);
        HttpResponse response = http.send(request);
        
        system.debug(response.getBody());
        map<string,string> temp=new  map<string,string> ();
        temp=(map<string,string>)System.JSON.deserialize(response.getBody(), map<string,string>.class);
        system.debug(temp.get('access_token'));
        mc.Access_Token__c=temp.get('access_token');
        update mc;
    }
}