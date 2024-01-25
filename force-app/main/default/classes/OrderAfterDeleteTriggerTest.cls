@isTest
private class OrderAfterDeleteTriggerTest
{
    /**
     * Sets up the necessary test data for the tests.
     * This method runs before each test method and is used to prepare a consistent state for testing.
     */
    @TestSetup
    static void setup()
    {
        // Create an Account record for testing
        Account testAccount = new Account(Name = 'Test Account', Active__c = true);
        insert  testAccount;

        // Create an Order associated with the test Account
        // This order will be used to test delete operation in the trigger
        Order testOrder = new Order(
            Name          = 'Test Order',
            AccountId     = testAccount.Id,
            EffectiveDate = Date.today(),
            Status        = 'Draft'
            );
        insert testOrder;
    }

    /**
     * Tests the behavior of the Order trigger after an Order is deleted.
     * This method is intended to verify that the trigger correctly handles Order deletions.
     */
    @isTest
    static void testOrderDeletion()
    {
        // Retrieve an Order to delete for testing the trigger
        Order testOrder = [SELECT Id, AccountId FROM Order LIMIT 1];

        // Retrieve the related Account record before deletion
        Account relatedAccountBeforeDeletion = [SELECT Id, Active__c FROM Account WHERE Id = : testOrder.AccountId];

        // Assert that the Active__c field is true before deletion
        System.assertEquals(true, relatedAccountBeforeDeletion.Active__c, 'Active__c should initially be true');

        // Perform the test in a test execution context
        Test.startTest();
        Set<Id> setIds = new Set<Id> {
            testOrder.Id
        };
        OrderManagement.handleOrderDeletion(setIds); // Deleting the Order to trigger the after delete logic
        Test.stopTest();

        System.debug('Test Order Deleted ' + testOrder);

        // Retrieve the related Account record after deletion
        Account relatedAccountAfterDeletion = [SELECT Id, Active__c FROM Account WHERE Id = : testOrder.AccountId];

        // Assert that the Active__c field of the account is false after deletion
        System.assertEquals(false, relatedAccountAfterDeletion.Active__c, 'Active__c should be false after the order is deleted');
    }
}