trigger ObjectCtrigger on ObjectC__C (before insert) {
    system.debug('Before Insert trigger ::' + Trigger.New);
    for (ObjectC__C obj_c : Trigger.New) {
        obj_c.Contact__c = '003Hp00002vzjHMIAY';
    }
}