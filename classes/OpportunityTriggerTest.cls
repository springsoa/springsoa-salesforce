@isTest 
public class OpportunityTriggerTest {
    
    static Account testAccountData(boolean isInsert) {
        Account account = new Account(Name = 'Test Account');
        if(isInsert){
            insert account;
        }
        return account;
    }
    
    static Contact testContactData(Id accountId, boolean isInsert) {
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = accountId);
        if(isInsert){
            insert contact;
        }
        return contact;
    }
    
    static Opportunity testOpportunityData(String opportunityStatus, boolean isInsert) {
        Account account = testAccountData(true);
        Contact contact = testContactData(account.Id,true);
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = system.today(), StageName = opportunityStatus, AccountId = contact.accountId);
        if(isInsert){
            insert opportunity;
        }
        return opportunity;
    }
    
    /*@testSetup
    private static void testSetup() {
        testContactData(true);
    }*/
        
        
    @isTest
    private static void testInsert() {
        test.startTest();
        testOpportunityData('Closed Won',true);
        test.stopTest();
    }
    
    @isTest 
    private static void testUpdate() {
        test.startTest();
        Opportunity opportunity = testOpportunityData('Prospecting', true);
        opportunity.StageName = 'Closed Won';
        update opportunity;
        test.stopTest();
    }
    
}