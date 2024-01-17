@isTest
private class OrderAfterDeleteTriggerTest {

    /**
     * Sets up the necessary test data for the tests.
     * This method runs before each test method and is used to prepare a consistent state for testing.
     */
    @TestSetup
    static void setup() {
        // Create an Account record for testing
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create an Order associated with the test Account
        // This order will be used to test the delete operation in the trigger
        Order testOrder = new Order(
            Name = 'Test Order', 
            AccountId = testAccount.Id, 
            EffectiveDate = Date.today(), 
            Status = 'Draft'
        );
        insert testOrder;

    }

    /**
     * Tests the behavior of the Order trigger after an Order is deleted.
     * This method is intended to verify that the trigger correctly handles Order deletions.
     */
    @isTest
    static void testOrderDeletion() {
        // Retrieve an Order to delete for testing the trigger
        Order testOrder = [SELECT Id FROM Order LIMIT 1];

        // Perform the test in a test execution context
        Test.startTest();
        delete testOrder; // Deleting the Order to trigger the after delete logic
        Test.stopTest();
    }
}
