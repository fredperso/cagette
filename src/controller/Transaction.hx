package controller;

/**
 * ...
 * @author fbarbut
 */
class Transaction extends controller.Controller
{

	@tpl('form.mtt')
	public function doInsertPayment(user:db.User){
		
		if (!app.user.isContractManager()) throw "accès interdit";
		
		var t = new db.Transaction();
		t.user = user;
		t.date = Date.now();
		
		
		var f = new sugoi.form.Form("payement");
		f.addElement(new sugoi.form.elements.StringInput("name", "Libellé", null, true));
		f.addElement(new sugoi.form.elements.FloatInput("amount", "Montant", null, true));
		f.addElement(new sugoi.form.elements.DatePicker("date", "Date", Date.now(), true));
		var data = [
		{label:"Espèces",value:"cash"},
		{label:"Chèque",value:"check"},
		{label:"Virement",value:"transfer"}		
		];
		f.addElement(new sugoi.form.elements.StringSelect("Mtype", "Moyen de paiement", data, null, true));
		
		if (f.isValid()){
			f.toSpod(t);
			t.type = db.Transaction.TransactionType.TTPayment(f.getValueOf("Mtype"),null,null);
			t.group = app.user.amap;
			t.user = user;
			t.insert();
			
			db.Transaction.updateUserBalance(user, app.user.amap);
			
			throw Ok("/member/payments/" + user.id, "Paiement enregistré");
			
		}
		
		view.title = "Saisir un paiement pour " + user.getCoupleName();
		view.form = f;		
	}
	
	/**
	 * payement entry page
	 * @param	distribKey
	 */
	@tpl("transaction/pay.mtt")
	public function doPay(distribKey:String){
		
		var debt = db.Transaction.findVOrderTransactionFor(distribKey, app.user, app.user.amap);
		
		view.debt = debt;
		view.ua = db.UserAmap.get(app.user, app.user.amap);
		view.paymentTypes = db.Transaction.getPaymentTypes(app.user.amap);
		
	}
	
	
}