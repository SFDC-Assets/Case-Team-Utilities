//  Test class and methods for the CreateCaseTeamMember invocable Apex class.
//
//  This code is provided AS IS, with no warranty or guarantee of suitability for use.
//  Contact: john.meyer@salesforce.com

@isTest
private without sharing class CreateCaseTeamMemberTest {

    @testSetup
    static void setup () {
        insert new CaseTeamRole (Name = 'Test Role', AccessLevel = 'Edit', PreferencesVisibleInCSP = false);        
    }

    @isTest
    private static void run () {
        
        Test.startTest();
        
        Account a = new Account (Name = 'Test Account');
        insert a;
        Contact c = new Contact (FirstName = 'John', LastName = 'Meyer', AccountId = a.Id);
        insert c;
        Case cs = new Case (ContactId = c.Id, AccountId = a.Id, Status = 'New');
        insert cs;
        
        CreateCaseTeamMember.CaseItem item = new CreateCaseTeamMember.CaseItem();
        List<CreateCaseTeamMember.ResultStatus> result;
        
        result = CreateCaseTeamMember.createCaseTeamMember (null);
        System.assertEquals('FAILURE', result[0].status);
        System.assert(result[0].message.contains('Empty case record'));
        
        result = CreateCaseTeamMember.createCaseTeamMember (new List<CreateCaseTeamMember.CaseItem>());
        System.assertEquals('FAILURE', result[0].status);
        System.assert(result[0].message.contains('Empty case record'));
        
        item.caseId = cs.Id;
        item.userId = UserInfo.getUserId();
        item.teamRole = 'No such role';
        result = CreateCaseTeamMember.createCaseTeamMember (new List<CreateCaseTeamMember.CaseItem> {item});
        System.assertEquals('FAILURE', result[0].status);
        System.assert(result[0].message.contains('Invalid case team role'));

        item.teamRole = 'Test Role';
        result = CreateCaseTeamMember.createCaseTeamMember (new List<CreateCaseTeamMember.CaseItem> {item, item});
        System.assertEquals('FAILURE', result[0].status);
        System.assert(result[0].message.contains('You must pass only one case record at a time'));
        
        item.caseId = null;
        item.teamRole = 'Test Role';
        result = CreateCaseTeamMember.createCaseTeamMember (new List<CreateCaseTeamMember.CaseItem> {item});
        System.assertEquals('FAILURE', result[0].status);
        System.assert(result[0].message.contains('Could not create team member'));
        
        item.caseId = cs.Id;
        item.teamRole = 'Test Role';
        result = CreateCaseTeamMember.createCaseTeamMember (new List<CreateCaseTeamMember.CaseItem> {item});
        System.assertEquals('SUCCESS', result[0].status);
        System.assertEquals(null, result[0].message);
        
        Test.stopTest();
    }
}