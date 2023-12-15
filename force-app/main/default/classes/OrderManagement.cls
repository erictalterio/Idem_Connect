public class OrderManagement {
    public static void handleOrderDeletion(Set<Id> deletedOrderIds) {
        // Query to find all Accounts linked to the deleted orders
        List<Order> ordersWithAccounts = [SELECT AccountId FROM Order WHERE Id IN :deletedOrderIds];

        // Extract Account IDs from the Orders
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : ordersWithAccounts) {
            if (ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }

        // Aggregate query to find Accounts with remaining Orders
        Map<Id, AggregateResult> ordersCountMap = new Map<Id, AggregateResult>(
            [SELECT AccountId, COUNT(Id) numOrders FROM Order WHERE AccountId IN :accountIds GROUP BY AccountId]
        );

        // Find Accounts that no longer have any Orders
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            AggregateResult ar = ordersCountMap.get(accId);
            if (ar == null || (Integer)ar.get('numOrders') == 0) {
                accountsToUpdate.add(new Account(Id = accId, Active__c = false));
            }
        }

        // Update Accounts if necessary
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
