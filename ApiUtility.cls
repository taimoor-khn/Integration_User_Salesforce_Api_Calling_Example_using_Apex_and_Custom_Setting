@RestResource(urlMapping='/Account/*')

global with sharing class ApiUtility {
    @HttpPost
    global static void doPost() {
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            system.debug(requestMap); 
            String accountId =string.valueOf(requestMap.get('accId'));
            
            list<OpportunityLineItem> oppLineItemList=[SELECT Id,OpportunityId,Opportunity.AccountId FROM OpportunityLineItem WHERE Opportunity.AccountId =:accountId];
            if(oppLineItemList.size()>0)
            {
                system.debug('oppLineItemList-->>'+oppLineItemList);
                list<OpportunityLineItemSchedule> oppLineItemSch=[SELECT Id, OpportunityLineItemId,Quantity  FROM OpportunityLineItemSchedule where OpportunityLineItemId IN: oppLineItemList];
                
                system.debug('oppLineItemSch-->>'+oppLineItemSch);
                if(oppLineItemSch.size()>0)
                {
                    for(OpportunityLineItemSchedule temp:oppLineItemSch)
                    {
                        temp.Quantity= 5;
                    }
                    update oppLineItemSch;
                    gen.writeStringField('success', 'true');
                    gen.writeObjectField('data',oppLineItemSch);
                    res.statuscode=200;  
                    
                    // return oppLineItemSch;
                }
                else
                {
                    gen.writeStringField('success', 'false');
                    gen.writeStringField('error','OpportunityLineItemSchedule Not Available');
                    res.statuscode=400;  
                }
            }
            else
            {
                gen.writeStringField('success', 'false');
                gen.writeStringField('error','OpportunityLineItem Not Available');
                res.statuscode=400; 
            }
            
            gen.writeEndObject();
            String pretty = gen.getAsString();
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(pretty);
        }
        catch (Exception e) {
            RestResponse res = RestContext.response;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('success', 'false');
            gen.writeStringField('error','BAD_REQUEST :' + e.getmessage()+'   '+e.getlineNumber());
            gen.writeEndObject();
            String pretty = gen.getAsString();
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(pretty);
            res.statuscode=500; 
        }
    }
    
}