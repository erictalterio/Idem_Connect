trigger OrderBeforeUpdate on Order (before update) {
    // Call the OrderVerification class method to verify if Orders have associated products
    OrderVerification.verifyOrderHasProducts(Trigger.new);
}
