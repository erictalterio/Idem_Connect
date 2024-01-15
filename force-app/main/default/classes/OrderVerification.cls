public class OrderVerification
{
    public static void verifyOrderHasProducts(List<Order> orders)
    {
        Set<Id> activatedOrderIds = new Set<Id>();
        for (Order ord : orders) {
            if (ord.Status == 'Activated')
            {
                activatedOrderIds.add(ord.Id);
            }
        }

        if (!activatedOrderIds.isEmpty())
        {
            List<OrderItem> orderItems = [
                SELECT Id, OrderId
                FROM OrderItem
                WHERE OrderId IN : activatedOrderIds
            ];

            Map<Id, List<OrderItem> > orderToProductsMap = new Map<Id, List<OrderItem> >();
            for (OrderItem item : orderItems) {
                if (orderToProductsMap.containsKey(item.OrderId))
                {
                    orderToProductsMap.get(item.OrderId).add(item);
                }
                else
                {
                    orderToProductsMap.put(item.OrderId, new List<OrderItem> {item});
                }
            }

            for (Order ord : orders) {
                if (activatedOrderIds.contains(ord.Id))
                {
                    if (!orderToProductsMap.containsKey(ord.Id) || orderToProductsMap.get(ord.Id).isEmpty())
                    {
                        ord.addError('An Order must have at least one associated product before being activated.');
                    }
                }
            }
        }
    }

    public static void activateOrder(List<Order> orders)
    {
        List<Order> ordersToUpdate = new List<Order>();
        for (Order ord : orders) {
            if (ord.Status != 'Activated' && orderHasProducts(ord.Id))
            {
                ordersToUpdate.add(new Order(Id = ord.Id, Status = 'Activated'));
            }
        }

        if (!ordersToUpdate.isEmpty())
        {
            update ordersToUpdate;
        }
    }

    private static Boolean orderHasProducts(Id orderId)
    {
        return([SELECT count() FROM OrderItem WHERE OrderId = : orderId] > 0);
    }
}