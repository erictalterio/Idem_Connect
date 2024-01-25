public class OrderManagement
{
    /**
     * Handles the deletion of Orders and updates related Account records.
     * This method sets the 'Active__c' field of associated Accounts to false
     * if all their related Orders are deleted.
     *
     * @param deletedOrderIds A set of IDs representing the Orders that have been deleted.
     */
    public static void handleOrderDeletion(Set<Id> deletedOrderIds)
    {
        // Check if there are any deleted orders to handle.
        if (deletedOrderIds == null || deletedOrderIds.isEmpty())
        {
            System.debug('No deleted orders to handle.');
            return;
        }

        // Query the Orders with associated Accounts.
        List<Order> ordersWithAccounts = [SELECT Id, AccountId FROM Order WHERE Id IN :deletedOrderIds];
        Set<Id> accountIds = new Set<Id>();

        // Extract Account IDs from the related Orders.
        for (Order ord : ordersWithAccounts) {
            if (ord.AccountId != null)
            {
                accountIds.add(ord.AccountId);
            }
        }

        // Delete the Orders.
        delete ordersWithAccounts;

        // Check if there are associated accounts to handle.
        if (accountIds.isEmpty())
        {
            System.debug('No associated accounts to handle.');
            return;
        }
        else
        {
            // Query the Accounts to be updated.
            List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds];

            // Update 'Active__c' field of associated Accounts.
            for (Account acc : accountsToUpdate) {
                acc.Active__c = false;
                System.debug('Updating Account: ' + acc.Id);
            }

            // Attempt to update the Accounts.
            if (!accountsToUpdate.isEmpty())
            {
                try {
                    update accountsToUpdate;
                    System.debug('Accounts updated successfully.');
                } catch (Exception e) {
                    System.debug('Error updating accounts: ' + e.getMessage());
                }
            }
        }
    }
}
