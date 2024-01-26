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
            if (ord.Status != 'Activated') {
                ordersToUpdate.add(new Order(Id = ord.Id, Status = 'Activated'));
            }
        }

        // Perform a bulk update to activate the orders.
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    public static void activateRelatedAccounts(List<Order> orders) {
        // Initialize a set to store unique Account IDs associated with the provided orders.
        Set<Id> accIds = new Set<Id>();
    
        // Loop through each order and add its associated Account ID to the set.
        // This avoids duplicate Account IDs and unnecessary processing.
        for(Order orderItem : [SELECT AccountId FROM Order WHERE Id In:orders]){
            accIds.add(orderItem.AccountId);
        }
    
        // Initialize a list to hold Account records that need to be updated.
        List<Account> acctoupdate = new List<Account>();
    
        // Retrieve the Accounts associated with the orders and check their Active__c field.
        // This loop only processes Accounts where Active__c is currently false.
        for (Account acc : [SELECT Active__c FROM Account WHERE Id IN:accIds]){
            if(!acc.Active__c){
                // Set the Active__c field to true for Accounts that are not active.
                acc.Active__c = true;
                // Add the modified Account to the list for bulk update.
                acctoupdate.add(acc);
            }
        }
    
        // Perform a bulk update on the Accounts to activate them.
        // This operation is efficient and minimizes the number of DML statements.
        update acctoupdate;
    }
    

}