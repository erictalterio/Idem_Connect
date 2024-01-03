@isTest
private class OrderManagementTest {

    static Account testAccountWithOrders;
    static Account testAccountWithoutOrders;

    @TestSetup
    static void setup() {
        // Create two accounts
        testAccountWithOrders = new Account(Name = 'Test Account With Orders', Active__c = true);
        testAccountWithoutOrders = new Account(Name = 'Test Account Without Orders', Active__c = true);
        insert new List<Account>{testAccountWithOrders, testAccountWithoutOrders};

        // Create orders only for the first account
        Order order = new Order(
            AccountId = testAccountWithOrders.Id,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert order;
    }

    @isTest
    static void testHandleOrderDeletionWithRemainingOrders() {
        // Test scenario where there are still remaining orders
        OrderManagement.handleOrderDeletion(new Set<Id>{});
        
        Account refreshedAccount = [SELECT Active__c FROM Account WHERE Id = :testAccountWithOrders.Id];
        System.assertEquals(true, refreshedAccount.Active__c, 'Active__c should remain true as there are still orders.');
    }

    @isTest
    static void testHandleOrderDeletionWithoutRemainingOrders() {
        // Retrieve all orders for the account with orders
        List<Order> orders = [SELECT Id FROM Order WHERE AccountId = :testAccountWithOrders.Id];
        Set<Id> orderIdsToDelete = new Set<Id>();
        for (Order ord : orders) {
            orderIdsToDelete.add(ord.Id);
        }

        // Delete the orders to trigger the logic in OrderManagement
        delete orders;

        // Call OrderManagement logic
        OrderManagement.handleOrderDeletion(orderIdsToDelete);

        // Query the account to check if Active__c has been updated
        Account updatedAccount = [SELECT Active__c FROM Account WHERE Id = :testAccountWithOrders.Id];
        System.assertEquals(false, updatedAccount.Active__c, 'Active__c should be false as the account no longer has any orders.');
    }
}
