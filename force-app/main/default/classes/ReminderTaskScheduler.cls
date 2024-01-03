global class ReminderTaskScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        ReminderTaskBatch batch = new ReminderTaskBatch();
        Database.executeBatch(batch);
    }

    public static void schedule() {
        String cronExpr = '0 0 2 ? * MON'; // Runs at 2 AM every Monday
        ReminderTaskScheduler scheduler = new ReminderTaskScheduler();
        System.schedule('Weekly Reminder Task', cronExpr, scheduler);
    }
}
