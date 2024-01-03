public class OrderTriggerHandler {

    public static void beforeUpdate(List<Order> newOrders) {
            // Call the OrderVerification class method to verify if Orders have associated products
            OrderVerification.verifyOrderHasProducts(newOrders);
    }

    public static void afterDelete(Map<Id, Order> oldOrdersMap) {
        OrderManagement.handleOrderDeletion(oldOrdersMap.keySet());
    }

}