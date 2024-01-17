@isTest
private class ReminderTaskSchedulerTest {

    // This test method verifies the functionality of the execute method in the ReminderTaskScheduler class.
    @isTest
    static void testExecuteMethod() {
        // Prepare a schedulable context mock, if necessary
        // This step is optional and depends on whether your execute method uses the context
        
        Test.startTest();
        // Instantiate the schedulable class and manually execute the execute method
        ReminderTaskScheduler scheduler = new ReminderTaskScheduler();
        scheduler.execute(null); // Passing null since SchedulableContext is not typically used
        Test.stopTest();

        // Add any assertions here if there are specific results or changes to be validated
    }

    // This test method verifies the functionality of the schedule method in the ReminderTaskScheduler class.
    @isTest
    static void testScheduleMethod() {
        Test.startTest();
        ReminderTaskScheduler.schedule();
        Test.stopTest();

        // Assert that the job is scheduled with the correct CRON expression
        List<CronTrigger> jobs = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'Weekly Reminder Task'];
        System.assertNotEquals(0, jobs.size(), 'Job should be scheduled.');
        System.assertEquals('0 0 2 ? * MON', jobs[0].CronExpression, 'The cron expression should match the expected value.');
    }
}
