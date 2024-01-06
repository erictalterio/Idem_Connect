public class OrderManagement
{
    public static void handleOrderDeletion(Set<Id> deletedOrderIds)
    {
        // Check if the set of deletedOrderIds is null or empty
        if (deletedOrderIds == null || deletedOrderIds.isEmpty())
        {
            System.debug('No deleted orders to handle.');
            return;
        }

        // Query to find all Accounts linked to the deleted orders
        List<Order> ordersWithAccounts = [SELECT Id, AccountId FROM Order WHERE Id IN : deletedOrderIds];

        // Extract non-null Account IDs from the Orders
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : ordersWithAccounts) {
            if (ord.AccountId != null)
            {
                accountIds.add(ord.AccountId);
            }
        }

        System.debug('Deleted Order IDs: ' + deletedOrderIds);
        System.debug('Associated Account IDs: ' + accountIds);

        // Check if the set of accountIds is empty
        if (accountIds.isEmpty())
        {
            System.debug('No associated accounts to handle.');
            return;
        }

        // Query to find Accounts with remaining Orders
        List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account WHERE Id IN : accountIds AND Id NOT IN(SELECT AccountId FROM Order WHERE Id IN : deletedOrderIds)];

        // Find Accounts that no longer have any Orders
        for (Account acc : accountsToUpdate) {
            System.debug('Updating Account: ' + acc.Id);
            acc.Active__c = false;
        }

        // Update Accounts if necessary
        if (!accountsToUpdate.isEmpty())
        {
            System.debug('Updating Accounts: ' + accountsToUpdate);
            update accountsToUpdate;
        }
    }
}