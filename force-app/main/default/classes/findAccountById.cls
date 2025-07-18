public with sharing class findAccountById {
    public findAccountById() {

    }
    @AuraEnabled(cacheable=true)
public static Account findAccountById(String accountId) {
    if (String.isBlank(accountId)) {
        system.debug('Type is: ' + Type.forName(accountId));
        System.debug('Account ID was received as null or blank. Returning null.');
        // Return null immediately to prevent a malformed SOQL query.
        return null;
    }

    System.debug('Received Account ID: ' + accountId);

    List<Account> accounts = [
        SELECT Id, Name, Industry, Phone, Type
        FROM Account
        WHERE Id = :accountId
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];

    if (!accounts.isEmpty()) {
        return accounts[0];
    } else {
        return null;
    }
}
}