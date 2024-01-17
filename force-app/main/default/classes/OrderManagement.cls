public class OrderManagement {

    /**
     * Handles the deletion of Orders and updates related Account records.
     * Specifically, this method sets the 'Active__c' field of associated Accounts to false
     * if all their related Orders are deleted.
     *
     * @param deletedOrderIds A set of IDs representing the Orders that have been deleted.
     */
    public static void handleOrderDeletion(Set<Id> deletedOrderIds) {
        // Check if there are any deleted order IDs to process.
        // If the set is null or empty, there's nothing to process, so return immediately.
        if (deletedOrderIds == null || deletedOrderIds.isEmpty()) {
            System.debug('No deleted orders to handle.');
            return;
        }

        // Retrieve all Orders that have been deleted along with their linked Account IDs.
        // This is necessary to identify which Accounts need to be updated.
        List<Order> ordersWithAccounts = [SELECT Id, AccountId FROM Order WHERE Id IN :deletedOrderIds];

        // Initialize a set to store unique Account IDs.
        // This set will only include IDs of Accounts linked to the deleted Orders.
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : ordersWithAccounts) {
            // Add the Account ID to the set if it's not null.
            if (ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }

        // Log the IDs of deleted Orders and their associated Account IDs for debugging.
        System.debug('Deleted Order IDs: ' + deletedOrderIds);
        System.debug('Associated Account IDs: ' + accountIds);

        // If there are no associated Accounts, there's nothing to update, so return.
        if (accountIds.isEmpty()) {
            System.debug('No associated accounts to handle.');
            return;
        }

        // Query for Accounts that are linked to the deleted Orders.
        // Exclude Accounts that still have Orders not included in the deletedOrderIds.
        // The goal is to identify Accounts that no longer have any Orders.
        List<Account> accountsToUpdate = [SELECT Id, Active__c FROM Account 
                                          WHERE Id IN :accountIds 
                                          AND Id NOT IN (SELECT AccountId FROM Order WHERE Id IN :deletedOrderIds)];

        // Iterate through the list of Accounts that need updating.
        for (Account acc : accountsToUpdate) {
            System.debug('Updating Account: ' + acc.Id);
            // Set the 'Active__c' field to false, indicating these Accounts no longer have Orders.
            acc.Active__c = false;
        }

        // Perform a bulk update on the Accounts if there are any to update.
        if (!accountsToUpdate.isEmpty()) {
            System.debug('Updating Accounts: ' + accountsToUpdate);
            update accountsToUpdate;
        }
    }
}
