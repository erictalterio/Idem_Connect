@isTest
private class OrderBeforeUpdateTriggerTest {

    // This method is used to set up the necessary data for the tests.
    // It runs once before any test methods are executed.
    @TestSetup
    static void setup() {
        // Create a new Account record and insert it into the database
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a new Product record and insert it into the database
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        // Retrieve the ID of the standard pricebook in Salesforce
        Id standardPricebookId = Test.getStandardPricebookId();

        // Create a new PricebookEntry record linking the product to the standard pricebook and insert it
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert standardPricebookEntry;

        // Create a new Order record and insert it into the database
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebookId
        );
        insert testOrder;

    }

    // Test method to verify successful update of an Order with associated OrderItems
    @isTest
    static void testOrderUpdateWithProducts() {
        // Retrieve the test Order and related PricebookEntry
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry standardPricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];

        // Create an OrderItem for the test Order
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = standardPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.0
        );
        insert testOrderItem;

        // Update the Order status and assert the update is successful
        testOrder.Status = 'Activated';
        Test.startTest();
        update testOrder;
        Test.stopTest();

        // Reload the order from the database and verify the status
        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals('Activated', updatedOrder.Status, 'Order should be activated with associated products.');
    }

    // Test method to ensure updating an Order without associated OrderItems fails
    @isTest
    static void testOrderUpdateWithoutProducts() {
        // Retrieve the test Order
        Order testOrder = [SELECT Id FROM Order LIMIT 1];

        // Attempt to update the Order status and expect an exception
        testOrder.Status = 'Activated';
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            update testOrder; // This update should fail due to trigger validation
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // Assert that an exception was thrown
        System.assert(exceptionThrown, 'An exception should be thrown when activating an order without products.');
    }
}
