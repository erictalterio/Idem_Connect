/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OrderVerificationTest {

    @TestSetup
    static void setup() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test product
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        // Create a pricebook entry for the standard pricebook
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert standardPricebookEntry;

        // Create a test order
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;

        // Create a test order item
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = standardPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.0
        );
        insert testOrderItem;

        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = testOrder.id;
        lineItem.Quantity = 1;
        lineItem.UnitPrice = 100.0;
        lineItem.Product2id = testProduct.id;
        lineItem.PricebookEntryId = standardPricebookEntry.id;
    insert lineItem;

    }

    @isTest
static void testOrderActivationWithProduct() {
    Order testOrder = [SELECT Id, Active__c FROM Order WHERE Active__c = false LIMIT 1];
    List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :testOrder.Id];
    System.assert(!orderItems.isEmpty(), 'There should be at least one associated OrderItem.');

    testOrder.Active__c = true;

    Test.startTest();
    update testOrder; // Attempt to activate the Order
    Test.stopTest();

    // Reload the order and add debug statement
    testOrder = [SELECT Active__c FROM Order WHERE Id = :testOrder.Id];
    System.debug('Order Active__c after update: ' + testOrder.Active__c);

    System.assertEquals(true, testOrder.Active__c, 'Order should be active as it has associated products.');
}
    
    @isTest
    static void testOrderActivationWithoutProduct() {
        Order testOrder = [SELECT Id, Active__c FROM Order WHERE Active__c = false LIMIT 1];
        testOrder.Active__c = true;
        
        // Remove associated OrderItems
        delete [SELECT Id FROM OrderItem WHERE OrderId = :testOrder.Id];

        Test.startTest();
        Boolean isExceptionThrown = false;
        try {
            update testOrder; // This should fail as there are no OrderItems
        } catch (DmlException e) {
            isExceptionThrown = true;
        }
        Test.stopTest();

        System.assert(isExceptionThrown, 'An exception should be thrown when activating an order without products.');
    }
}