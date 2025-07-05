public with sharing class PropertySearchController {
    
    public class AuraHandledException extends Exception {}

    @AuraEnabled
    public static Map<String, Object> searchProperties(Map<String, Object> wrapperData) {
        Map<String, Object> response = new Map<String, Object>();
        String jsonString = JSON.serialize(wrapperData);
        AddressRequestWrapper address = (AddressRequestWrapper) JSON.deserialize(jsonString, AddressRequestWrapper.class);

        try {
            HttpRequest req = buildHttpRequest(address);
            HttpResponse res = new Http().send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> apiResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<PropertyInfo> properties = parseProperties(apiResponse);
                response.put(Constants.DATA, properties);
                response.put(Constants.TOTAL, properties.size());
            } else {
                throw new AuraHandledException(Constants.API_ERROR_PREFIX + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException(Constants.ERROR_SEARCHING_PROPERTIES_PREFIX + e.getMessage());
        }
        return response;
    }

    private static HttpRequest buildHttpRequest(AddressRequestWrapper address) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Constants.PROPERTY_SEARCH_ENDPOINT);
        req.setMethod('POST');
        req.setHeader(Constants.CONTENT_TYPE_HEADER, Constants.CONTENT_TYPE_JSON);
        req.setHeader(Constants.AUTHORIZATION_HEADER, Constants.AUTHORIZATION_TOKEN);
        req.setBody(JSON.serialize(address));
        return req;
    }

    private static List<PropertyInfo> parseProperties(Map<String, Object> apiResponse) {
        List<PropertyInfo> properties = new List<PropertyInfo>();
        if (apiResponse == null) return properties;
        Map<String, Object> results = (Map<String, Object>)apiResponse.get(Constants.RESULTS);
        if (results == null) return properties;
        List<Object> propertyList = (List<Object>) results.get(Constants.PROPERTIES);
        if (propertyList == null) return properties;

        for (Object obj : propertyList) {
            Map<String, Object> result = (Map<String, Object>)obj;
            PropertyInfo pi = mapToPropertyInfo(result);
            properties.add(pi);
        }
        return properties;
    }

    private static PropertyInfo mapToPropertyInfo(Map<String, Object> result) {
        PropertyInfo pi = new PropertyInfo();
        pi.id = (String) result.get(Constants.ID);
        Map<String, Object> address = (Map<String, Object>) result.get(Constants.ADDRESS);
        if (address != null) {
            pi.street = (String) address.get(Constants.STREET);
            pi.city = (String) address.get(Constants.CITY);
            pi.state = (String) address.get(Constants.STATE);
            pi.zip = (String) address.get(Constants.ZIP);
        }
        pi.address = pi.street + ', ' + pi.city + ', ' + pi.state + ' ' + pi.zip;

        Map<String, Object> general = (Map<String, Object>) result.get(Constants.GENERAL);
        if (general != null) {
            pi.propertyType = (String) general.get(Constants.PROPERTY_TYPE_DETAIL); 
        }

        Map<String, Object> building = (Map<String, Object>) result.get(Constants.BUILDING);
        if (building != null) {
            pi.yearBuilt = (Integer) building.get(Constants.YEAR_BUILT);
            pi.squareFeet = (Integer) building.get(Constants.LIVING_AREA_SQFT);
        }

        Map<String, Object> valuation = (Map<String, Object>) result.get(Constants.VALUATION);
        if (valuation != null) {
            pi.estimatedValue = (Decimal) valuation.get(Constants.ESTIMATED_VALUE);
        }

        List<Object> mortgages = (List<Object>) result.get(Constants.MORTGAGE_HISTORY);
        if (mortgages != null && !mortgages.isEmpty()) {
            Map<String, Object> mortgage = (Map<String, Object>) mortgages[0];
            pi.lenderName = (String) mortgage.get(Constants.LENDER_NAME);
            pi.loanAmount = (Decimal) mortgage.get(Constants.LOAN_AMOUNT);
            pi.interestRate = (Decimal) mortgage.get(Constants.INTEREST_RATE);
        }
        return pi;
    }
    
    @AuraEnabled
    public static List<String> saveProperties(List<Map<String, Object>> properties) {
        List<String> savedIds = new List<String>();
        List<Property__c> propertiesToInsert = new List<Property__c>();
        List<Mortgage__c> mortgagesToInsert = new List<Mortgage__c>();
        
        try {
            for (Map<String, Object> propertyData : properties) {
                Property__c prop = new Property__c();
                prop.API_Property_ID__c = (String) propertyData.get(Constants.PROP_API_ID);
                prop.Address__c = (String) propertyData.get(Constants.PROP_ADDRESS);
                prop.City__c = (String) propertyData.get(Constants.PROP_CITY);
                prop.State__c = (String) propertyData.get(Constants.PROP_STATE);
                prop.Zip_Code__c = (String) propertyData.get(Constants.PROP_ZIP);
                prop.Property_Type__c = (String) propertyData.get(Constants.PROP_TYPE);
                prop.Year_Built__c = (Decimal) propertyData.get(Constants.PROP_YEAR_BUILT);
                prop.Square_Feet__c = (Decimal) propertyData.get(Constants.PROP_SQFT);
                prop.Estimated_Value__c = (Decimal) propertyData.get(Constants.PROP_EST_VAL);
                
                propertiesToInsert.add(prop);
            }
            
            Database.SaveResult[] srList = Database.insert(propertiesToInsert, false);
            
            for (Integer i = 0; i < propertiesToInsert.size(); i++) {
                Database.SaveResult sr = srList[i];
                if (sr.isSuccess()) {
                    savedIds.add(sr.getId());
                    
                    Map<String, Object> propertyData = properties[i];
                    if (propertyData.containsKey(Constants.MORT_LENDER)) {
                        Mortgage__c mortgage = new Mortgage__c();
                        mortgage.Property__c = sr.getId();
                        mortgage.Lender_Name__c = (String) propertyData.get(Constants.MORT_LENDER);
                        mortgage.Loan_Amount__c = (Decimal) propertyData.get(Constants.MORT_LOAN_AMOUNT);
                        mortgage.Interest_Rate__c = (Decimal) propertyData.get(Constants.MORT_INTEREST_RATE);
                        mortgage.Monthly_Payment__c = (Decimal) propertyData.get(Constants.MORT_MONTHLY_PAYMENT);
                        
                        mortgagesToInsert.add(mortgage);
                    }
                }
            }
            
            if (!mortgagesToInsert.isEmpty()) {
                insert mortgagesToInsert;
            }
            
            return savedIds;
        } catch (Exception e) {
            throw new AuraHandledException(Constants.ERROR_SAVING_PROPERTIES_PREFIX + e.getMessage() + e.getStackTraceString());
        }
    }

    public class PropertyInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zip;
        @AuraEnabled public String address; 
        @AuraEnabled public String propertyType;
        @AuraEnabled public Integer yearBuilt;
        @AuraEnabled public Integer squareFeet;
        @AuraEnabled public Decimal estimatedValue;

        @AuraEnabled public String lenderName;
        @AuraEnabled public Decimal loanAmount;
        @AuraEnabled public Decimal interestRate;
    }

}