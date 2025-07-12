public with sharing class ApexIndex {
    public ApexIndex() {

    }

    public static void getOpportunities(){
        system.debug('Returning Opties');
        List<Opportunity> optyList = [SELECT ID FROM Opportunity];
    }

    @AuraEnabled
    public static string createOpportunity(String name, String stageName, Date closeDate, Decimal amount){
        if (String.isBlank(name) || String.isBlank(stageName) || closeDate == null) {
            throw new AuraHandledException('Name, Stage, and Close Date are required.');
        }

        try {
            Opportunity newOpp = new Opportunity(
                Name = name,
                StageName = stageName,
                CloseDate = closeDate,
                Amount = amount
            );
            
            // Insert the new opportunity
            insert newOpp;
            
            // Return the new record's ID on success
            return newOpp.Id;

        } catch (DmlException e) {
            // In a real-world scenario, log this error
            System.debug('Error creating opportunity: ' + e.getMessage());
            // Throw a user-friendly error
            throw new AuraHandledException('An error occurred while creating the opportunity: ' + e.getMessage());
        }catch (Exception e) {
            throw new AuraHandledException('Some Generic Error : ' + e.getMessage());
        }
    }


}