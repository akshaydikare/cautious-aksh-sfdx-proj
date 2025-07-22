
public with sharing class AccountInfoController {

    /**
     * @description Returns a list of all accounts to populate the selection picklist.
     * @return List<Account> A list of accounts with Id and Name.
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        try {
            return [
                SELECT Id, Name
                FROM Account
                ORDER BY Name
                LIMIT 200
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Fetches the selected Account's Owner, related Contacts, and Opportunities.
     * @param accountId The ID of the selected Account.
     * @return Account The Account record with related data.
     */
    @AuraEnabled(cacheable=true)
    public static Account getRelatedInfo(String accountId) {
        // Basic validation
        if (String.isBlank(accountId)) {
            return null;
        }

        try {
            // Single, efficient query to get the account and its related records.
            // This approach is bulk-safe in principle as it uses a selective query.
            // Limits are added to subqueries to prevent excessive data retrieval.
            return [
                SELECT
                    Id, Name,
                    Owner.Name, Owner.Title, Owner.Email, Owner.Phone,
                    (SELECT Id, Name, Email, Phone FROM Contacts ORDER BY CreatedDate DESC LIMIT 10),
                    (SELECT Id, Name, StageName, Amount, CloseDate FROM Opportunities ORDER BY CreatedDate DESC LIMIT 10)
                FROM Account
                WHERE Id = :accountId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
