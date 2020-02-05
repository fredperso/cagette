package test;
import Common;
import service.DistributionService;
import service.OrderService;
import service.SubscriptionService;
import service.SubscriptionService.SubscriptionServiceError;
import utest.Assert;

/**
 * Test subscriptions
 * 
 * @author web-wizard
 */
class TestSubscriptions extends utest.Test
{
	
	public function new(){
		super();
	}
	
	var catalog : db.Catalog;
	var micheline : db.User;
	var botteOignons : db.Product;
	var panierAmap : db.Product;
	var soupeAmap : db.Product;
	var bob : db.User;
	
	/**
	 * get a contract + a user + a product + empty orders
	 */
	function setup(){

		TestSuite.initDB();
		TestSuite.initDatas();

		catalog = TestSuite.CONTRAT_AMAP;

		botteOignons = TestSuite.BOTTE_AMAP;
		panierAmap = TestSuite.PANIER_AMAP_LEGUMES;
		soupeAmap = TestSuite.SOUPE_AMAP;

		micheline = db.User.manager.get(1);
		bob = TestSuite.FRANCOIS;
		
		DistributionService.create( catalog, DateTools.delta( Date.now(), 1000.0 * 60 * 60 * 24 * 14 ), new Date(2030, 5, 1, 20, 0, 0), TestSuite.PLACE_DU_VILLAGE.id, new Date(2030, 4, 1, 20, 0, 0), new Date(2030, 4, 30, 20, 0, 0) );
		DistributionService.create( catalog, new Date(2030, 6, 1, 19, 0, 0), new Date(2030, 6, 1, 20, 0, 0), TestSuite.PLACE_DU_VILLAGE.id, new Date(2030, 5, 1, 20, 0, 0), new Date(2030, 5, 30, 20, 0, 0) );		


	}

	public function testDeleteSubscription() {

		var ordersData = new Array< { productId : Int, quantity : Float, invertSharedOrder : Bool, userId2 : Int } >();
		ordersData.push( { productId : panierAmap.id, quantity : 1, invertSharedOrder : false, userId2 : null } );
		var subscription : db.Subscription = null;
		var error = null;

		//-----------------------------------------------
		//Test case : There are orders for past distribs
		//-----------------------------------------------
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, catalog.startDate, catalog.endDate, ordersData, false );
			subscription.isValidated = true;
			subscription.update();
			SubscriptionService.deleteSubscription( subscription );
		}
	    catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.data, PastOrders );
		Assert.isTrue( subscription != null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 1 );
		Assert.equals( SubscriptionService.getSubscriptionOrders( subscription ).length, 1 );

		//No error for a pending subscription
		//------------------------------------
		subscription.isValidated = false;
		subscription.update();
		error = null;
		try {

			SubscriptionService.deleteSubscription( subscription );
		}
	    catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 0 );
		Assert.equals( SubscriptionService.getSubscriptionOrders( subscription ).length, 0 );


		//---------------------------------------
		//Test case : There are no past distribs
		//---------------------------------------
		error = null;
		subscription = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, Date.now(), catalog.endDate, ordersData );
			SubscriptionService.deleteSubscription( subscription );
		}
	    catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 0 );
		Assert.equals( SubscriptionService.getSubscriptionOrders( subscription ).length, 0 );


	}

	// Test subscription creation and cases that generate errors
	// @author web-wizard
	function testCreateSubscription() {

		var ordersData = new Array< { productId : Int, quantity : Float, invertSharedOrder : Bool, userId2 : Int } >();
		ordersData.push( { productId : panierAmap.id, quantity : 1, invertSharedOrder : false, userId2 : null } );
		var subscription : db.Subscription = null;
		var error = null;
		//----------------------------------------
		//Test case : Start and end dates are null
		//----------------------------------------
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, null, null, ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.message, 'La date de début et de fin de la souscription doivent être définies.' );
		Assert.equals( subscription, null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 0 );

		//--------------------------------------------------------------
		//Test case : Start date is outside catalog start and end dates
		//--------------------------------------------------------------
		error = null;
		subscription = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, new Date(2000, 5, 1, 19, 0, 0), catalog.endDate, ordersData  );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.message, 'La date de début de la souscription doit être comprise entre les dates de début et de fin du catalogue.' );
		Assert.equals( subscription, null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 0 );

		//No error for a pending subscription
		//------------------------------------
		error = null;
		subscription = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, new Date(2000, 5, 1, 19, 0, 0), catalog.endDate, ordersData, false  );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.isTrue( subscription != null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 1 );
		SubscriptionService.deleteSubscription( subscription );

		//-----------------------------------------------------------
		//Test case : End date is outside catalog start and end dates
		//-----------------------------------------------------------
		error = null;
		subscription = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, catalog.startDate, new Date(2036, 5, 1, 19, 0, 0), ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.message, 'La date de fin de la souscription doit être comprise entre les dates de début et de fin du catalogue.' );
		Assert.equals( subscription, null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 0 );

		//No error for a pending subscription
		//------------------------------------
		error = null;
		subscription = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, catalog.startDate, new Date(2036, 5, 1, 19, 0, 0), ordersData, false );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.isTrue( subscription != null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 1 );
		SubscriptionService.deleteSubscription( subscription );
		
		//----------------------------
		//Test case : User 2 not found
		//----------------------------
		error = null;
		subscription = null;
		ordersData = [ { productId : panierAmap.id, quantity : 1, invertSharedOrder : false, userId2 : 999999 } ];
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, new Date(2019, 5, 1, 19, 0, 0), catalog.endDate, ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.message, "Unable to find user #999999" );
		Assert.equals( subscription, null );
		SubscriptionService.deleteSubscription( db.Subscription.manager.select( $user == bob ) );

		//-----------------------
		//Test case : Same User 2
		//-----------------------
		error = null;
		subscription = null;
		ordersData = [ { productId : panierAmap.id, quantity : 1, invertSharedOrder : false, userId2 : bob.id } ];
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, new Date(2019, 5, 1, 19, 0, 0), catalog.endDate, ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.message, 'Both selected accounts must be different ones' );
		Assert.equals( subscription, null );
		SubscriptionService.deleteSubscription( db.Subscription.manager.select( $user == bob ) );

		//------------------------------------------------------------
		//Test case : Creating a subscription with past distributions
		//------------------------------------------------------------
		error = null;
		subscription = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, catalog.startDate, catalog.endDate, ordersData );
		}
	    catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.data, PastDistributionsWithoutOrders );
		Assert.equals( subscription, null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 0 );


		//------------------------------------------------
		//Test case : Successfully creating a subscription
		//------------------------------------------------
		var error = null;
		var ordersData = new Array< { productId : Int, quantity : Float, invertSharedOrder : Bool, userId2 : Int } >();
		ordersData.push( { productId : botteOignons.id, quantity : 3, invertSharedOrder : false, userId2 : null } );
		ordersData.push( {  productId : panierAmap.id, quantity : 2, invertSharedOrder : false, userId2 : null } );
		try {

			subscription = SubscriptionService.createSubscription( bob, catalog, new Date(2019, 5, 1, 19, 0, 0), catalog.endDate, ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.isTrue( subscription != null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 1 );

		var subscriptionDistributions = SubscriptionService.getSubscriptionDistributions( subscription );
		var subscriptionAllOrders = SubscriptionService.getSubscriptionAllOrders( subscription );
		Assert.equals( subscriptionAllOrders.length, 2 * subscriptionDistributions.length );
		for ( distribution in subscriptionDistributions ) {

			var distribOrders = db.UserOrder.manager.search( $user == bob && $subscription == subscription && $distribution == distribution, false );
			Assert.equals( distribOrders.length, 2 );
			var order1 = Lambda.array( distribOrders )[0];
			var order2 = Lambda.array( distribOrders )[1];
			Assert.equals( order1.product.id, botteOignons.id );
			Assert.equals( order1.quantity, 3 );
			Assert.equals( order2.product.id, panierAmap.id );
			Assert.equals( order2.quantity, 2 );
			var distribOrders2 = subscriptionAllOrders.filter( function ( order ) return order.distribution.id == distribution.id );
			Assert.equals( distribOrders2.length, 2 );
			var otherOrder1 = Lambda.array( distribOrders2 )[0];
			var otherOrder2 = Lambda.array( distribOrders2 )[1];
			Assert.equals( otherOrder1.product.id, botteOignons.id );
			Assert.equals( otherOrder1.quantity, 3 );
			Assert.equals( otherOrder2.product.id, panierAmap.id );
			Assert.equals( otherOrder2.quantity, 2 );
		}

		var subscriptionOrders = SubscriptionService.getSubscriptionOrders( subscription );

		Assert.equals( subscriptionOrders.length, 2 );
		var order1 = Lambda.array( subscriptionOrders )[0];
		var order2 = Lambda.array( subscriptionOrders )[1];
		Assert.equals( order1.product.id, botteOignons.id );
		Assert.equals( order1.quantity, 3 );
		Assert.equals( order2.product.id, panierAmap.id );
		Assert.equals( order2.quantity, 2 );

	}

	// Test subscription update and cases that generate errors
	// @author web-wizard
	function testUpdateSubscription() {

		var ordersData = new Array< { productId : Int, quantity : Float, invertSharedOrder : Bool, userId2 : Int } >();
		ordersData.push( { productId : botteOignons.id, quantity : 3, invertSharedOrder : false, userId2 : null } );
		ordersData.push( {  productId : panierAmap.id, quantity : 2, invertSharedOrder : false, userId2 : null } );
		var subscription1 = SubscriptionService.createSubscription( bob, catalog, new Date(2019, 5, 1, 19, 0, 0), catalog.endDate, ordersData );
	
		//-----------------------------------------------------------------------------------------------------------
		//Test case : Moving the subscription start date to an earlier date when there are already past distributions
		//-----------------------------------------------------------------------------------------------------------
		var error = null;
		try {

			SubscriptionService.updateSubscription( subscription1, catalog.startDate, catalog.endDate, ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.data, PastDistributionsWithoutOrders );


		//--------------------------------------------------------------------------------------------------
		//Test case : Moving the subscription start date to a later date when there are already past orders
		//--------------------------------------------------------------------------------------------------
		var subscription = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, catalog.startDate, catalog.endDate, ordersData, false );
			subscription.isValidated = true;
			subscription.update();
			SubscriptionService.updateSubscription( subscription, Date.now(), catalog.endDate, ordersData );
		}
	    catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.data, PastOrders );


		//--------------------------------------------------------------------------------------------------
		//Test case : Moving the subscription end date to an earlier date when there are already future orders
		//--------------------------------------------------------------------------------------------------
		for ( subscription in db.Subscription.manager.search( $user == bob ) ) {

			subscription.delete();
		}
		error = null;
		try {
			
			subscription = SubscriptionService.createSubscription( bob, catalog, catalog.startDate, catalog.endDate, ordersData, false );
			subscription.isValidated = true;
			subscription.update();
			SubscriptionService.updateSubscription( subscription, subscription.startDate, new Date(2029, 5, 1, 19, 0, 0), null );
		}
	    catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.equals( service.SubscriptionService.getSubscriptionNbDistributions( subscription ), 2 );
		var subscriptionDistributions = SubscriptionService.getSubscriptionDistributions( subscription );
		var subscriptionAllOrders = SubscriptionService.getSubscriptionAllOrders( subscription );
		Assert.equals( subscriptionAllOrders.length, 2 * subscriptionDistributions.length );

	}

	// Test subscription overlap
	// @author web-wizard
	function testSubscriptionsOverlap() {

		var ordersData = new Array< { productId : Int, quantity : Float, invertSharedOrder : Bool, userId2 : Int } >();
		ordersData.push( { productId : botteOignons.id, quantity : 3, invertSharedOrder : false, userId2 : null } );
		ordersData.push( {  productId : panierAmap.id, quantity : 2, invertSharedOrder : false, userId2 : null } );
		var subscription = SubscriptionService.createSubscription( bob, catalog, new Date(2019, 5, 1, 19, 0, 0), catalog.endDate, ordersData );

		Assert.isTrue( subscription != null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 1 );

		SubscriptionService.updateSubscription( subscription, new Date(2019, 5, 1, 19, 0, 0), new Date(2025, 5, 1, 19, 0, 0), null );
		Assert.equals( db.Subscription.manager.get( subscription.id ).endDate.toString(), "2025-06-01 23:59:59" );

		//----------------------------------------------------------------------
		//Test case : When creating an overlapping subcription there is an error
		//----------------------------------------------------------------------
		var subscription2 = null;
		var error = null;
		try {

			subscription2 = SubscriptionService.createSubscription( bob, catalog, new Date(2025, 4, 1, 19, 0, 0), catalog.endDate, ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error.data, OverlappingSubscription );
		Assert.equals( subscription2, null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 1 );

		//No error for a pending subscription
		//------------------------------------
		subscription2 = null;
		error = null;
		try {

			subscription2 = SubscriptionService.createSubscription( bob, catalog, new Date(2025, 4, 1, 19, 0, 0), catalog.endDate, ordersData, false );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.isTrue( subscription2 != null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 2 );

		//------------------------------------------------------------------------------------------------------
		//Test case : Successfully creating another subscription that is after the current subscription period
		//------------------------------------------------------------------------------------------------------
		subscription2 = null;
		error = null;
		try {

			subscription2 = SubscriptionService.createSubscription( bob, catalog, new Date(2025, 5, 2, 19, 0, 0), catalog.endDate, ordersData );
		}
		catch( e : tink.core.Error ) {

			error = e;
		}
		Assert.equals( error, null );
		Assert.isTrue( subscription2 != null );
		Assert.equals( db.Subscription.manager.count( $user == bob ), 3 );

	}


}