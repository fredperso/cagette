package react.order;
import react.ReactDOM;
import react.ReactComponent;
import react.ReactMacro.jsx;
import Common;
import utils.HttpUtil;
import react.router.HashRouter;
import react.router.Route;
import react.router.Switch;
import react.router.Link;
import react.order.redux.reducers.OrderBoxReducer;
import react.order.redux.actions.thunk.OrderBoxThunk;

// typedef OrderBoxState = {

// 	var error : String;
// 	var users : Null<Array<UserInfo>>;
// };

typedef OrderBoxProps = {

	var userId : Int;
	var multiDistribId : Int;
	var contractId : Int;
	var contractType : Int;
	var date : String;
	var place : String;
	var userName : String;
	var callbackUrl : String;
	var currency : String;
	var orders : Array<UserOrder>;
	var fetchMultiDistribUserOrders : Int -> Int -> Int -> Void;
	var saveMultiDistribUserOrders : Int -> Int -> String -> Void; 
};

//Julie class OrderBox extends react.ReactComponentOfPropsAndState<OrderBoxProps,OrderBoxState>
/**
 * A box to edit/add orders of a member
 * @author fbarbut
 */
@:connect
class OrderBox extends react.ReactComponentOfProps<OrderBoxProps>
{

	public function new(props) 
	{
		super(props);	
		// state = { orders : [], error : null, users : null };
	}
	
	override function componentDidMount() {
		
		props.fetchMultiDistribUserOrders( props.userId, props.multiDistribId, props.contractId );		
	}

	/**
	 *  load user list when contract is constant orders
	 */
	//  Julie
	// function loadUsers(){
	// 	HttpUtil.fetch("/api/user/getFromGroup/", GET, {}, PLAIN_TEXT)
	// 	.then(function(data:String) {

	// 		var data : {users:Array<UserInfo>} = tink.Json.parse(data);
	// 		setState({users:data.users, error:null});

	// 	}).catchError(function(data) {

	// 		var data = Std.string(data);
	// 		if(data.substr(0,1)=="{"){
	// 			//json error from server
	// 			var data : ErrorInfos = haxe.Json.parse(data);
	// 			setState( cast {error:data.error.message} );
	// 		}else{
	// 			//js error
	// 			setState( cast {error:data} );
	// 		}
	// 	});
	// }
	
	override public function render(){
		//edit orders 
		var renderOrders = props.orders.map(function(o){
			var k :String = if(o.id!=null) {
				Std.string(o.id);
			} else {
				o.product.id + "-" + Std.random(99999);
			};
			return jsx('<Order key=${k} order=${o} currency=${props.currency} contractType=${props.contractType} />')	;
		}  );


		var delivery = 	if(props.date == null) {
							null;
						} else {
							jsx('<p>Pour la livraison du <b>${props.date}</b> à <b>${props.place}</b></p>');
						}

		var validateButton = jsx('<a onClick=${props.saveMultiDistribUserOrders.bind( props.userId, props.multiDistribId, props.callbackUrl )} className="btn btn-primary">
									<i className="icon icon-chevron-right"></i> Valider
								 </a>');
		

		//Julie <Error error=${state.error} />
		var renderOrderBox = function(props:react.router.RouteRenderProps):react.ReactFragment { 
			return jsx('
				<div onKeyPress=${onKeyPress}>
					<h3>Commandes de ${this.props.userName}</h3>
					$delivery								
					<hr/>
					<div className="row tableHeader">
						<div className="col-md-4">Produit</div>
						<div className="col-md-1">Ref.</div>
						<div className="col-md-1">Prix</div>
						<div className="col-md-2">Qté</div>
						${ this.props.contractType == 0 ? jsx('<div className="col-md-3">Alterné avec</div>') : null }
					</div>
					${renderOrders}	
					<div>
						${validateButton}						
						&nbsp;
						<Link className="btn btn-default" to="/insert"><i className="icon icon-plus"></i> Ajouter un produit</Link>
					</div>
				</div>			
			');
		}

		
		

		//Julie
		// var onProductSelected = function(uo:UserOrder) {
		// 	var existingOrder = Lambda.find(state.orders,function(x) return x.product.id == uo.product.id );
		// 	if(existingOrder != null) {
		// 		existingOrder.quantity += uo.quantity;
		// 		this.setState(this.state);
		// 	} else {
		// 		this.state.orders.push(uo);
		// 		this.setState(this.state);
		// 	}
		// };

		//insert product box
		var renderInsertBox = function(props:react.router.RouteRenderProps):react.ReactFragment {
			return jsx('<InsertOrder contractId=${this.props.contractId} userId=${this.props.userId} multiDistribId=${this.props.multiDistribId} />');
		} 

		return jsx('
			<HashRouter>
				<Switch>
					<Route path="/" exact=$true render=$renderOrderBox	 />
					<Route path="/insert" exact=$true render=$renderInsertBox />
				</Switch>
			</HashRouter>
		');
	}	
	
	/**
	 * submit updated orders to the API
	 */
	// function saveOrders(?_) {
		
	// 	var data = new Array<{id:Int,productId:Int,qt:Float,paid:Bool,invertSharedOrder:Bool,userId2:Int}>();
	// 	for ( o in state.orders) data.push({id:o.id, productId : o.product.id, qt: o.quantity, paid : o.paid, invertSharedOrder:o.invertSharedOrder, userId2:o.userId2});
		
	// 	var req = { orders:data };
		
	// 	var p = HttpUtil.fetch("/api/order/update/"+props.userId+"?distributionId="+props.distributionId+"&contractId="+props.contractId, POST, req, JSON);
	// 	p.then(function(data:Dynamic) {

	// 		if (props.onValidate != null) props.onValidate();

	// 	}).catchError(function(data) {

	// 		var data = Std.string(data);
	// 		if(data.substr(0,1)=="{"){
	// 			//json error from server
	// 			var data : ErrorInfos = haxe.Json.parse(data);
	// 			setState( cast {error:data.error.message} );
	// 		}else{
	// 			//js error
	// 			setState( cast {error:data} );
	// 		}
	// 	});		
	// }

	function onKeyPress(e:js.html.KeyboardEvent){
		//Julie
		// if(e.key=="Enter") saveOrders();
	}


	static function mapStateToProps( state: react.order.redux.reducers.OrderBoxReducer.OrderBoxState, ownProps: OrderBoxProps ): react.Partial<OrderBoxProps> {		

		return { orders: Reflect.field(state, "orderBox").orders };
	}

	static function mapDispatchToProps( dispatch : redux.Redux.Dispatch ) : react.Partial<OrderBoxProps> {
				
		return { 
			
			fetchMultiDistribUserOrders : function( userId : Int, multiDistribId : Int, contractId : Int ) {
				return dispatch( OrderBoxThunk.fetchMultiDistribUserOrders( userId, multiDistribId, contractId ) );
			},
			saveMultiDistribUserOrders : function( userId : Int, multiDistribId : Int, callbackUrl : String ) {
				return dispatch( OrderBoxThunk.saveMultiDistribUserOrders( userId, multiDistribId, callbackUrl ) );
			}
		}

	}	
	
}