public with sharing class ParentAccountController {
   
    public class AuraHandledException extends Exception {}

    @AuraEnabled
    public static String createRecords(FormDataWrapper wrapper) {
        System.debug('Received wrapper: ' + wrapper);
        if (wrapper == null) {
            throw new AuraHandledException('No data provided');
        }
        
        try {
            Account acc = new Account(
                Name = wrapper.accountName,
                Email__c = wrapper.accountEmail,
                Phone = wrapper.accountPhone,
                Industry = wrapper.accountIndustry,
                Rating = wrapper.accountRating
            );
            insert acc;
            System.debug('Account created: ' + acc);
            Contact con = new Contact(
                FirstName = wrapper.contactFirstName,
                LastName = wrapper.contactLastName,
                Email = wrapper.contactEmail,
                Phone = wrapper.contactPhone,
                Title = wrapper.contactTitle,
                AccountId = acc.Id
            );
            insert con;
            
            Opportunity opp = new Opportunity(
                Name = wrapper.opportunityName,
                StageName = wrapper.opportunityStage,
                CloseDate = wrapper.opportunityCloseDate,
                Amount = wrapper.opportunityAmount,
                Email__c = wrapper.opportunityEmail,
                Phone__c = wrapper.opportunityPhone,
                AccountId = acc.Id
            );
            

            insert opp;
            return acc.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating records: ' + e.getMessage());
        }
    }
}