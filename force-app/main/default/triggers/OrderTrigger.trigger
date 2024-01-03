trigger OrderTrigger on Order (before update, after delete) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderTriggerHandler.beforeUpdate(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        OrderTriggerHandler.afterDelete(Trigger.oldMap);
    }
}
