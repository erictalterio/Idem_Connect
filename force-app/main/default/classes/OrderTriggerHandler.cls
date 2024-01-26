public class OrderTriggerHandler {

    /**
     * Handles logic that should be executed before Order records are updated.
     * This method is invoked from a trigger when Order records are going through an update operation.
     *
     * @param newOrders A list of new Order records that are about to be updated.
     *                  These records represent the updated state of the Orders.
     */
    public static void beforeUpdate(List<Order> newOrders) {
        // Invoke the verifyOrderHasProducts method from the OrderVerification class.
        // This method checks each Order in the list to ensure it has associated products
        // before the status of the Order is set to 'Activated'.
        // If an Order does not meet the criteria, an error is added to the Order record,
        // preventing the update from being successful.
        OrderVerification.verifyOrderHasProducts(newOrders);

         // Call the activateOrder method to activate eligible orders.
         OrderVerification.activateOrder(newOrders);

        // Call the activateRelatedAccounts method to activate related accounts.
        OrderVerification.activateRelatedAccounts(newOrders);
    }

    /**
     * Handles logic that should be executed after Order records are deleted.
     * This method is invoked from a trigger when Order records are deleted from the database.
     *
     * @param oldOrdersMap A map of deleted Order records before they were deleted, keyed by their IDs.
     *                     This map provides access to the original state of the Orders before deletion.
     */
    public static void afterDelete(Map<Id, Order> oldOrdersMap) {
        // Invoke the handleOrderDeletion method from the OrderManagement class.
        // This method checks the Accounts associated with the deleted Orders and updates them as necessary.
        // The keySet method on the map is used to extract the set of Order IDs that were deleted,
        // which is then passed to the handleOrderDeletion method for processing.
        OrderManagement.handleOrderDeletion(oldOrdersMap.keySet());
    }

}
