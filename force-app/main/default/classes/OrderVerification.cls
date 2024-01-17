public class OrderVerification {

    /**
     * Verifies if Orders have associated products before being marked as activated.
     * This method is critical for ensuring that Orders are not activated unless they meet the business criteria,
     * which in this case is having at least one associated product (OrderItem).
     *
     * @param orders A list of Order records to be verified.
     */
    public static void verifyOrderHasProducts(List<Order> orders) {
        // A set to store the IDs of orders that are being activated.
        Set<Id> activatedOrderIds = new Set<Id>();
        
        // Loop through each order to check if its status is 'Activated'.
        // Add the IDs of activated orders to the set.
        for (Order ord : orders) {
            if (ord.Status == 'Activated') {
                activatedOrderIds.add(ord.Id);
            }
        }

        // Proceed only if there are orders being activated.
        if (!activatedOrderIds.isEmpty()) {
            // Query for OrderItem records related to the activated orders.
            List<OrderItem> orderItems = [
                SELECT Id, OrderId FROM OrderItem WHERE OrderId IN :activatedOrderIds
            ];

            // Map to associate each order with its corresponding OrderItems.
            // This helps in quickly checking if an order has associated products.
            Map<Id, List<OrderItem>> orderToProductsMap = new Map<Id, List<OrderItem>>();
            for (OrderItem item : orderItems) {
                // If the order is already in the map, add the item to its list.
                // Otherwise, create a new list with the item.
                if (orderToProductsMap.containsKey(item.OrderId)) {
                    orderToProductsMap.get(item.OrderId).add(item);
                } else {
                    orderToProductsMap.put(item.OrderId, new List<OrderItem>{item});
                }
            }

            // Check each order in the original list.
            // If an activated order does not have associated products, add an error to it.
            for (Order ord : orders) {
                if (activatedOrderIds.contains(ord.Id)) {
                    if (!orderToProductsMap.containsKey(ord.Id) || orderToProductsMap.get(ord.Id).isEmpty()) {
                        ord.addError('An Order must have at least one associated product before being activated.');
                    }
                }
            }
        }
    }

    /**
     * Activates Orders if they have associated products and are not already activated.
     * This method changes the status of eligible orders to 'Activated'.
     *
     * @param orders A list of Order records that may need to be activated.
     */
    public static void activateOrder(List<Order> orders) {
        // List to hold orders that need to be activated.
        List<Order> ordersToUpdate = new List<Order>();
        
        // Loop through the list of orders.
        // If an order is not already activated and has associated products, prepare it for update.
        for (Order ord : orders) {
            if (ord.Status != 'Activated' && orderHasProducts(ord.Id)) {
                ordersToUpdate.add(new Order(Id = ord.Id, Status = 'Activated'));
            }
        }

        // Perform a bulk update to activate the orders.
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    /**
     * Checks if a specific Order has associated products (OrderItems).
     * This method performs a SOQL query to count the number of OrderItems linked to the Order.
     *
     * @param orderId The ID of the Order to check.
     * @return Boolean indicating whether the Order has associated products.
     */
    private static Boolean orderHasProducts(Id orderId) {
        // Return true if there are one or more OrderItems associated with the Order.
        return ([SELECT count() FROM OrderItem WHERE OrderId = :orderId] > 0);
    }
}
