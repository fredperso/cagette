package service;
import Common;
import tink.core.Error;

/**
 * Order Service
 * @author web-wizard
 */
class OrderService
{
	/**
	 *  Delete an order
	 */
	public static function delete(order:db.UserContract) {
		var t = sugoi.i18n.Locale.texts;

		if(order==null) throw new Error(t._("This order has already been deleted."));
		
		order.lock();
		
		if (order.quantity == 0) {

			var contract = order.product.contract;
			var user = order.user;

			//Amap Contract
			if ( contract.type == db.Contract.TYPE_CONSTORDERS ) {

				order.delete();

				if( contract.amap.hasPayments() )
				{
					var orders = contract.getUserOrders(user);
					if( orders.length == 0 ){
						var operation = db.Operation.findCOrderTransactionFor(contract, user);
						if(operation!=null) operation.delete();
					}
				}

			}
			else { //Variable orders contract

				order.delete();

				if( contract.amap.hasPayments() )
				{

					//Get the basket for this user
					var place = order.distribution.place;
					var basket = db.Basket.get(user, place, order.distribution.date);

					//Get all the orders for this basket
					var orders = basket.getOrders();

					//Check there is no orders left to delete the related operation
					if( orders.length == 0 )
					{
						var operation = db.Operation.findVOrderTransactionFor(order.distribution.getKey(), user, place.amap);
						if(operation!=null) operation.delete();
					}

				}
			}
		}
		else {
			throw new Error(t._("Deletion not possible: quantity is not zero."));
		}

	}
	



	/**
	 *  Send an order-by-products report to the coordinator
	 */
	public static function sendOrdersByProductReport(d:db.Distribution){
		
		var m = new sugoi.mail.Mail();
		m.addRecipient(d.contract.contact.email , d.contract.contact.getName());
		m.setSender(App.config.get("default_email"),"Cagette.net");
		m.setSubject('[${d.contract.amap.name}] Distribution du ${App.current.view.dDate(d.date)} (${d.contract.name})');
		var orders = db.UserContract.getOrdersByProduct({distribution:d});

		var html = App.current.processTemplate("mail/ordersByProduct.mtt", { 
			contract:d.contract,
			distribution:d,
			orders:orders,
			formatNum:App.current.view.formatNum,
			currency:App.current.view.currency,
			dDate:App.current.view.dDate,
			hHour:App.current.view.hHour,
			group:d.contract.amap
		} );
		
		m.setHtmlBody(html);
		App.sendMail(m);					

	}


	/**
	 *  Order summary for a member
	 *  WARNING : its for one distrib, not for a whole basket !
	 */
	public static function sendOrderSummaryToMembers(d:db.Distribution){

		var title = '[${d.contract.amap.name}] Votre commande pour le ${App.current.view.dDate(d.date)} (${d.contract.name})';

		for( user in d.getUsers() ){

			var m = new sugoi.mail.Mail();
			m.addRecipient(user.email , user.getName(),user.id);
			if(user.email2!=null) m.addRecipient(user.email2 , user.getName(),user.id);
			m.setSender(App.config.get("default_email"),"Cagette.net");
			m.setSubject(title);
			var orders = db.UserContract.prepare(d.contract.getUserOrders(user,d));

			var html = App.current.processTemplate("mail/orderSummaryForMember.mtt", { 
				contract:d.contract,
				distribution:d,
				orders:orders,
				formatNum:App.current.view.formatNum,
				currency:App.current.view.currency,
				dDate:App.current.view.dDate,
				hHour:App.current.view.hHour,
				group:d.contract.amap
			} );
			
			m.setHtmlBody(html);
			App.sendMail(m);
		}
		
	}
}