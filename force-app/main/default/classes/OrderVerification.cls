public class OrderVerification {
    // Method to verify if an Order has associated products before being activated
    public static void verifyOrderHasProducts(List<Order> orders) {
        // Prepare a set to hold the Ids of Orders that need verification
        Set<Id> orderIds = new Set<Id>();
        for (Order ord : orders) {
            // Check if the status is being set to 'Active'
            if (ord.Status == 'Active') {
                orderIds.add(ord.Id);
            }
        }
        
        // Query for Order Products related to the Orders being activated
        List<OrderItem> orderItems = [
            SELECT Id, OrderId 
            FROM OrderItem 
            WHERE OrderId IN :orderIds
        ];
        
        // Create a map to associate Orders with their Order Items
        Map<Id, List<OrderItem>> orderToProductsMap = new Map<Id, List<OrderItem>>();
        for (OrderItem item : orderItems) {
            // If the Order already exists in the map, add to its List of OrderItems
            if (orderToProductsMap.containsKey(item.OrderId)) {
                orderToProductsMap.get(item.OrderId).add(item);
            } else {
                // Otherwise, create a new List and add the item
                orderToProductsMap.put(item.OrderId, new List<OrderItem>{item});
            }
        }
        
        // Loop through the Orders to check for associated Order Items
        for (Order ord : orders) {
            // If the Order does not have any associated Order Items, add an error
            if (!orderToProductsMap.containsKey(ord.Id) || orderToProductsMap.get(ord.Id).isEmpty()) {
                ord.addError('An Order must have at least one associated product before being activated.');
            }
        }
    }
}
