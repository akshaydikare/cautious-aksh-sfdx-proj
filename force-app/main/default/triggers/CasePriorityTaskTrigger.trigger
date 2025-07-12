trigger CasePriorityTaskTrigger on Case (after insert, after update) {

    List<Task> tasksToCreate = new List<Task>();

    // Iterate through new or updated Cases
    for (Case c : Trigger.new) {
        // Only create a task if the case is not already high priority
        // and has an owner.
        // We're checking if the Priority field is NOT 'High' to avoid
        // creating redundant tasks if the case is already marked High.
        if (c.OwnerId != null && c.Priority != 'High') {
            Task newTask = new Task(
                Subject = 'Prioritize Case: ' + c.CaseNumber,
                WhatId = c.Id, // Relate the task to the Case
                WhoId = c.OwnerId, // Assign the task to the Case Owner
                ActivityDate = Date.today().addDays(1), // Due tomorrow
                Status = 'Open',
                Priority = 'High',
                Description = 'This case requires immediate attention. Please review and set the priority to "High" if appropriate.'
            );
            tasksToCreate.add(newTask);
        }
    }

    if (!tasksToCreate.isEmpty()) {
        try {
            insert tasksToCreate;
        } catch (DMLException e) {
            System.debug('Error creating tasks: ' + e.getMessage());
            // Optionally, add error handling like logging to a custom object
            // or sending an email to an administrator.
        }
    }
}