@isTest
public class OrderManagementTest
{
    // Declare test data at the class level
    static List<Account> testAccounts;
    static List<Product2> testProducts;
    static List<PricebookEntry> testPricebookEntries;
    static List<Order> testOrders;
    static List<OrderItem> testOrderItems;

    @isTest
    static void testHandleOrderDeletion()
    {
        // Create test data - Accounts
        testAccounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i, Active__c = true));
        }
        insert testAccounts;

        // Create test data - Products
        testProducts = new List<Product2>();
        for (Integer i = 0; i < 3; i++) {
            testProducts.add(new Product2(
                                 Name     = 'Test Product ' + i,
                                 IsActive = true
                                 ));
        }
        insert testProducts;

        // Create test data - PricebookEntry records associated with Products
        testPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProducts) {
            testPricebookEntries.add(new PricebookEntry(
                                         Pricebook2Id = Test.getStandardPricebookId(),
                                         Product2Id   = prod.Id,
                                         UnitPrice    = 100.00,
                                         IsActive     = true
                                         ));
        }
        insert testPricebookEntries;

        // Create test data - Orders associated with Accounts and Products
        testOrders     = new List<Order>();
        testOrderItems = new List<OrderItem>();
        for (Integer i = 0; i < 3; i++) {
            Order testOrder = new Order(
                AccountId     = testAccounts[i].Id,
                Status        = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id  = Test.getStandardPricebookId()
                );

            testOrders.add(testOrder);
            insert testOrder;

            testOrderItems.add(new OrderItem(
                                   OrderId          = testOrders[i].Id,
                                   PricebookEntryId = testPricebookEntries[i].Id,
                                   Quantity         = 1,
                                   UnitPrice        = 100.00
                                   ));
        }
        insert testOrderItems;

        // Set up the test by deleting some orders
        Set<Id> deletedOrderIds = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            deletedOrderIds.add(testOrders[i].Id);
        }

        // Scenario 1: No deleted orders
        Test.startTest();
        OrderManagement.handleOrderDeletion(new Set<Id>());

        // Assertions for Scenario 1
        System.assertEquals(3, testAccounts.size(), 'No accounts should be updated');
        for (Account acc : testAccounts) {
            System.assertEquals(true, acc.Active__c, 'Account should remain active');
        }

        // Scenario 2: All orders are deleted
        Set<Id> allDeletedOrderIds = new Set<Id>();
        for (Order ord : testOrders) {
            allDeletedOrderIds.add(ord.Id);
        }

        // Reset the test accounts to their original state
        testAccounts = [SELECT Id, Active__c FROM Account WHERE Id IN : testAccounts];
        OrderManagement.handleOrderDeletion(allDeletedOrderIds);

        // Assertions for Scenario 2
        testAccounts = [SELECT Id, Active__c FROM Account WHERE Id IN : testAccounts];
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Active__c = true], 'All accounts should be inactive');

        // Scenario 3: Some orders are deleted, but some still exist
        Set<Id> partialDeletedOrderIds = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            partialDeletedOrderIds.add(testOrders[i].Id);
        }

        // Query the test accounts before handling order deletion
        List<Account> originalAccounts = [SELECT Id, Active__c FROM Account WHERE Id IN : testAccounts];

        // Reset the test accounts to their original state
        OrderManagement.handleOrderDeletion(partialDeletedOrderIds);
        Test.stopTest();

        // Assertions for Scenario 3
        List<Account> updatedAccounts = [SELECT Id, Active__c FROM Account WHERE Id IN : testAccounts];
        System.assertEquals(originalAccounts.size(), updatedAccounts.size(), 'Number of accounts should remain the same');

        for (Integer i = 0; i < originalAccounts.size(); i++) {
            System.assertEquals(originalAccounts[i].Active__c, updatedAccounts[i].Active__c, 'Account status should remain the same');
        }
    }
}