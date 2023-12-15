trigger OrderAfterDelete on Order (after delete) {
    OrderManagement.handleOrderDeletion(Trigger.oldMap.keySet());
}
