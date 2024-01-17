// Apex trigger named 'OrderTrigger' on the 'Order' object.
// This trigger is designed to handle events that occur before an Order record is updated
// and after an Order record is deleted.
trigger OrderTrigger on Order (before update, after delete) {

    // Check if the trigger is being executed in the context of a 'before update' event.
    // Trigger.isBefore checks if the trigger is executed before the database save operation,
    // and Trigger.isUpdate checks if the trigger is executed due to an update operation.
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Invoke the 'beforeUpdate' method of the 'OrderTriggerHandler' class.
        // This method is responsible for handling any logic that needs to be executed
        // before Order records are updated.
        // 'Trigger.new' provides the list of new, updated Order records that are about to be saved.
        OrderTriggerHandler.beforeUpdate(Trigger.new);
    }

    // Check if the trigger is being executed in the context of an 'after delete' event.
    // Trigger.isAfter checks if the trigger is executed after the database save operation,
    // and Trigger.isDelete checks if the trigger is executed due to a delete operation.
    if (Trigger.isAfter && Trigger.isDelete) {
        // Invoke the 'afterDelete' method of the 'OrderTriggerHandler' class.
        // This method is responsible for handling any logic that needs to be executed
        // after Order records have been deleted.
        // 'Trigger.oldMap' provides a map of the deleted Order records by their IDs.
        // This allows for processing or referencing the deleted records in the handler.
        OrderTriggerHandler.afterDelete(Trigger.oldMap);
    }
}
