//  Flow component to assign a case team member to a case.
//  
//  The code checks to make sure that only one record is entered at a time.  To provide updates to multiple
//  cases, place this component inside a loop in flow builder.
//  
//  Returns a status string of either 'SUCCESS' or 'FAILURE'.  In case of FAILURE, a more detailed message
//  detailing the reason for failure is provided.
//
//  This code is provided AS IS, with no warranty or guarantee of suitability for use.
//  Contact: john.meyer@salesforce.com


global without sharing class CreateCaseTeamMember {
    
    global class CaseItem {
        @InvocableVariable(label='Case record ID' description='The record ID of the case to assign the team member' required=true) global Id caseId;       
        @InvocableVariable(label='Team member user ID' description='The user ID of the team member' required=true) global Id userId;
        @InvocableVariable(label='Case team role name' description='The name of the role to assign to the case team member' required=true) global String teamRole;
    }
    
    global class ResultStatus {
        @InvocableVariable(label='Status ("SUCCESS" or "FAILURE")' description='Return status from the team member assignment, either "SUCCESS" or "FAILURE"') global String status;
        @InvocableVariable(label='Error message' description='If Status is "FAILURE", contains a descriptive error message') global String message;
    }    
    
    @InvocableMethod(label='Create Case Team Member' description='Adds a user to a case\'s case team')  
    global static List<ResultStatus> createCaseTeamMember (List<CaseItem> caseRecords) {
        
        ResultStatus result = new ResultStatus();
        
        if (caseRecords == null || caseRecords.isEmpty()) {
            result.status = 'FAILURE';
            result.message = 'Empty case record.';
        } else if (caseRecords.size() != 1) {
            result.status = 'FAILURE';
            result.message = 'You must pass only one case record at a time.';
        } else {
            CaseItem caseRecord = caseRecords[0]; 
            try {
                CaseTeamRole role = [SELECT Id, AccessLevel FROM CaseTeamRole WHERE Name = :caseRecord.teamRole LIMIT 1];
                insert new CaseTeamMember (ParentId = caseRecord.caseId, MemberId = caseRecord.userId, TeamRoleId = role.Id);
                try {
                    insert new CaseShare (CaseId = caseRecord.caseId, UserOrGroupId = caseRecord.userId, CaseAccessLevel = role.AccessLevel);
                } catch (DMLException e) {
                    // If the access level is the same as the org-wide level, this will throw a field integrity exception. Just ignore it.
                }
                result.status = 'SUCCESS';
                result.message = null;
            } catch (QueryException e) {
                result.status = 'FAILURE';
                result.message = 'Invalid case team role: "' + caseRecord.teamRole + '".';
            } catch (DMLException e) {
                result.status = 'FAILURE';
                result.message = 'Could not create team member for user Id = "' + caseRecord.userId + '" on case Id = "' + caseRecord.caseId +
                    ' with role = "' + caseRecord.teamRole + '": ' + e.getMessage();
            }
        }
        
        return new List<ResultStatus> {result};
    }
}