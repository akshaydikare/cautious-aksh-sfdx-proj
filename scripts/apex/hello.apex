// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

AccountContactController.getContacts('001Hp00002f3epXIAQ');

ObjectC__c obcC = new ObjectC__c(text_sample__c='ObjectC record inserting_3', EMaill__c='ababab@gmail.com');
Database.insert(obcC, false);
Database.SaveResult[] srList = Database.insert(obcC, false);

for (Database.SaveResult sr : srList) {
    if (sr.isSuccess()) {
        // Operation was successful, so get the ID of the record that was processed
        System.debug('Successfully inserted ObjectC__c. ObjectC__c ID: ' + sr.getId());
    }
    else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('ObjectC__c fields that affected this error: ' + err.getFields());
        }
    }
}