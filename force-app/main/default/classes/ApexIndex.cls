public with sharing class ApexIndex {
    public ApexIndex() {

    }

    public static void getOpportunities(){
        system.debug('Returning Opties');
        List<Opportunity> optyList = [SELECT ID FROM Opportunity];
    }

}