/**
* cshah on : 03-12-2020
* */
public class OpportunityTriggerHandler {
    @TestVisible private static final String stageName = 'Closed Won';
    @TestVisible private static final String role = 'Family Member';

    public static void afterInsert(list<Opportunity> opportunity,boolean isInsert) {
        addContactRoles(opportunity, null,isInsert);
    }

    public static void afterUpdate(list<Opportunity> opportunity, map<Id, Opportunity> oldMap) {
        addContactRoles(opportunity, oldMap, false);
    }

    @TestVisible
    private static map<Id, list<Id>> findAccountIdToContactIds(list<Opportunity> opportunity) {
        map<Id, list<Id>> accountIdToContactIds = new map<Id, list<Id>>();
        for (Opportunity opportunityObj : opportunity) {
            System.debug('OpportunityTriggerHandler.findAccountIdToContactIds opportunityObj.AccountId : ' + opportunityObj.AccountId);
            if (opportunityObj.StageName == stageName && opportunityObj.AccountId != null) {
                accountIdToContactIds.put(opportunityObj.AccountId, null);
            }
        }
        if (accountIdToContactIds != null) {
            System.debug('OpportunityTriggerHandler.findAccountIdToContactIds accountIdToContactIds : ' + accountIdToContactIds);
            for (Contact contact : [Select Id,AccountId from Contact WHERE accountId IN: accountIdToContactIds.keySet()]) {
                if (accountIdToContactIds.get(contact.AccountId) != null && accountIdToContactIds.containsKey(contact.AccountId)) {
                    System.debug('OpportunityTriggerHandler.findAccountIdToContactIds accountIdToContactIds : ' + accountIdToContactIds.get(contact.AccountId));
                    accountIdToContactIds.get(contact.AccountId).add(contact.Id);
                    //accountIdToContactIds.put(contact.AccountId, contactIds);
                } else {
                    accountIdToContactIds.put(contact.AccountId, new List<Id>{contact.Id});
                }
            }
        }
        return accountIdToContactIds;
    }

    public static void insertContactRoles(Opportunity opportunityObj,Id contactId) {
        list<OpportunityContactRole> opportunityContactRole = new list<OpportunityContactRole>();
        OpportunityContactRole opportunityContactRoleObj = new OpportunityContactRole();
        opportunityContactRoleObj.ContactId = contactId;
        opportunityContactRoleObj.OpportunityId = opportunityObj.Id;
        opportunityContactRoleObj.IsPrimary = true;
        opportunityContactRoleObj.Role = role;
        opportunityContactRole.add(opportunityContactRoleObj);
        try {
            insert opportunityContactRole;
        } catch (Exception exp) {
            System.debug('AddContactRolesHandler.addContactRolesInsert Exception : ' + exp);
        }
    }

    @TestVisible
    private static void addContactRoles(list<Opportunity> opportunity, map<Id, Opportunity> oldMap, boolean isInsert) {

        for (Opportunity opportunityObj : opportunity) {
            /**
            * This logic is not final yet this is just prototype until we got which contact to add
            **/
            list<Id> contactIdsAssign = findAccountIdToContactIds(opportunity).get(opportunityObj.AccountId);
            if (opportunityObj.AccountId != null  && contactIdsAssign != null && opportunityObj.StageName == stageName) {
                System.debug('OpportunityTriggerHandler.addContactRoles contactIdsAssign : ' + contactIdsAssign);
                for (Id contactId : contactIdsAssign) {
                    if(contactId != null) {
                        if (oldMap != null && opportunityObj.StageName != oldMap.get(opportunityObj.Id).StageName) {
                            insertContactRoles(opportunityObj, contactId);
                        } else if(isInsert) {
                            insertContactRoles(opportunityObj, contactId);
                        }
                    }
                }
            }
        }
    }
}