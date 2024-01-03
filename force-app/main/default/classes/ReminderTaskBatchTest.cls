@isTest
private class ReminderTaskBatchTest {

    @TestSetup
    static void setup() {
        // Create two accounts
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{testAccount1, testAccount2};

        // Create a 'Call' task for the second account
        Task callTaskForAccount2 = new Task(
            WhatId = testAccount2.Id,
            Subject = 'Call',
            Status = 'Completed',
            Priority = 'Normal',
            Type = 'Call'
        );
        insert callTaskForAccount2;

        // Create a different type of task for the first account
        Task nonCallTaskForAccount1 = new Task(
            WhatId = testAccount1.Id,
            Subject = 'Email',
            Status = 'Completed',
            Priority = 'Normal'
        );
        insert nonCallTaskForAccount1;
    }

    @isTest
    static void testBatchCreatesTasksForAccounts() {
        Test.startTest();
        ReminderTaskBatch batch = new ReminderTaskBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Assert that a new 'Call' task is created for the first account
        List<Task> tasksForAccount1 = [SELECT Id FROM Task WHERE WhatId = :[SELECT Id FROM Account WHERE Name = 'Test Account 1'].Id AND Subject = 'Call'];
        System.assertEquals(1, tasksForAccount1.size(), 'There should be a new Call task for the first account.');

        // Assert that no new 'Call' task is created for the second account
        List<Task> tasksForAccount2 = [SELECT Id FROM Task WHERE WhatId = :[SELECT Id FROM Account WHERE Name = 'Test Account 2'].Id AND Subject = 'Call'];
        System.assertEquals(1, tasksForAccount2.size(), 'No new Call task should be created for the second account.');
    }
}
