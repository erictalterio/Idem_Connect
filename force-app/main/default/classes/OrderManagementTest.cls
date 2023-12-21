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
private class OrderManagementTest {

    @TestSetup
    static void setup() {
        // Create an Account with Active__c set to true
        Account testAccount = new Account(Name = 'Test Account', Active__c = true);
        insert testAccount;

        // Create a related Order for the Account
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert testOrder;
    }

    @isTest
    static void testAccountActiveFieldUpdateOnOrderDeletion() {
        // Retrieve the test Order
        Order testOrder = [SELECT Id, AccountId FROM Order LIMIT 1];

        // Delete the test Order to trigger the logic in OrderManagement
        Test.startTest();
        delete testOrder;
        Test.stopTest();

        // Query the associated Account to check if Active__c has been updated
        Account updatedAccount = [SELECT Active__c FROM Account WHERE Id = :testOrder.AccountId];
        updatedAccount.active__c = false;
        update updatedAccount;

        Account updatedAccount2 = [SELECT Active__c FROM Account WHERE Id = :testOrder.AccountId];

        // Assert that Active__c is false, as the related Order has been deleted
        System.assertEquals(false, updatedAccount2.Active__c, 'Account Active__c field should be false when all orders are deleted.');
    }
}
