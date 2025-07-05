public with sharing class FormDataWrapper {
    // Account fields
    @AuraEnabled public String accountName { get; set; }
    @AuraEnabled public String accountEmail { get; set; }
    @AuraEnabled public String accountPhone { get; set; }
    @AuraEnabled public String accountIndustry { get; set; }
    @AuraEnabled public String accountRating { get; set; }
    
    // Contact fields
    public String contactFirstName { get; set; }
    @AuraEnabled public String contactLastName { get; set; }
    @AuraEnabled public String contactEmail { get; set; }
    @AuraEnabled public String contactPhone { get; set; }
    @AuraEnabled public String contactTitle { get; set; }
    
    // Opportunity fields
    @AuraEnabled public String opportunityName { get; set; }
    @AuraEnabled public String opportunityStage { get; set; }
    @AuraEnabled public Date opportunityCloseDate { get; set; }
    @AuraEnabled public Decimal opportunityAmount { get; set; }
    @AuraEnabled public String opportunityEmail { get; set; }
    @AuraEnabled public String opportunityPhone { get; set; }
}