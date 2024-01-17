global class ReminderTaskScheduler implements Schedulable {
    
    // This method is executed when the scheduled job runs.
    global void execute(SchedulableContext ctx) {
        // Create an instance of the ReminderTaskBatch and execute it as a batch job.
        ReminderTaskBatch batch = new ReminderTaskBatch();
        Database.executeBatch(batch);
    }

    // This method schedules the ReminderTaskScheduler to run at a specified time.
    public static void schedule() {
        // Define the Cron expression for scheduling the job (e.g., 2 AM every Monday)
        String cronExpr = '0 0 2 ? * MON'; 
        
        // Create an instance of the ReminderTaskScheduler
        ReminderTaskScheduler scheduler = new ReminderTaskScheduler();
        
        // Schedule the job with a unique name ('Weekly Reminder Task') and the specified Cron expression.
        System.schedule('Weekly Reminder Task', cronExpr, scheduler);
    }
}
