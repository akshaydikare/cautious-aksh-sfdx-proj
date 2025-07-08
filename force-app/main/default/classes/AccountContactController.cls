public with sharing class AccountContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accountId) {
        // Basic security check to ensure the user has read access to the fields
        if (!Schema.sObjectType.Contact.isAccessible() ||
            !Schema.sObjectType.Contact.fields.Name.isAccessible() ||
            !Schema.sObjectType.Contact.fields.Title.isAccessible() ||
            !Schema.sObjectType.Contact.fields.Phone.isAccessible() ||
            !Schema.sObjectType.Contact.fields.Email.isAccessible()) {
            throw new AuraHandledException('You do not have permission to view contact fields.');
        }

        return [
            SELECT Id, Name, Title, Account.Name, Phone, Email
            FROM Contact
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY Name
            LIMIT 10
        ];
    }
}