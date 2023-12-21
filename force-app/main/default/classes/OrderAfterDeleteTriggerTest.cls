@isTest
private class OrderAfterDeleteTriggerTest {

    @TestSetup
    static void setup() {
        // Create and insert necessary test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Order testOrder = new Order(Name = 'Test Order', AccountId = testAccount.Id, EffectiveDate = Date.today(), Status = 'Draft');
        insert testOrder;

        // Create additional test data as required...
        // Ensure that you create Orders that can be deleted in the test method
    }

    @isTest
    static void testOrderDeletion() {
        // Query for an Order to delete
        Order testOrder = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        delete testOrder;
        Test.stopTest();

        // Assertions to check the result of deletion
        // For example, you can verify if related records are updated or deleted as expected
    }
}
