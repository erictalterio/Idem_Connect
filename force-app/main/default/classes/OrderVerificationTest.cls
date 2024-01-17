@isTest
public class OrderVerificationTest
{
    // This test method is used to verify the behavior of the 'activateOrder' method.
    @isTest
    static void testActivateOrder()
    {
        // Create test data: Accounts
        Account testAccount = new Account(Name = 'Test Account');
        insert  testAccount;

        // Create a Pricebook
        Id standardPricebookId = Test.getStandardPricebookId();

        // Create a Product
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert   testProduct;

        // Query for existing PricebookEntry or create a new one if not found
        PricebookEntry standardPricebookEntry;
        try {
            standardPricebookEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = : standardPricebookId AND Product2Id = : testProduct.Id LIMIT 1];
        } catch (QueryException e) {
            standardPricebookEntry = new PricebookEntry(
                Pricebook2Id       = standardPricebookId,
                Product2Id         = testProduct.Id,
                UnitPrice          = 100,
                IsActive           = true
                );
            insert standardPricebookEntry;
        }

        // Create test data: Orders with associated products
        List<Order> testOrders = new List<Order>();
        for (Integer i = 0; i < 2; i++) {
            Order  testOrder = new Order(Status = 'Draft', AccountId = testAccount.Id, EffectiveDate = System.today(), Pricebook2Id = standardPricebookId);
            insert testOrder;

            // Create associated products with PricebookEntryId and UnitPrice
            OrderItem testOrderItem = new OrderItem(
                OrderId          = testOrder.Id,
                Quantity         = 1,
                PricebookEntryId = standardPricebookEntry.Id,
                UnitPrice        = 100 // Provide a valid UnitPrice
                );
            insert testOrderItem;

            testOrders.add(testOrder);
        }

        // Call the method to be tested
        Test.startTest();
        OrderVerification.activateOrder(testOrders);
        Test.stopTest();

        // Re-query the orders to get the latest status
        List<Order> updatedOrders = [SELECT Id, Status FROM Order WHERE Id IN : testOrders];

        // Assert the results
        for (Order ord : updatedOrders) {
            // Check if the order status is activated after calling activateOrder
            System.assertEquals('Activated', ord.Status, 'Order status should be Activated.');
        }
    }
}
