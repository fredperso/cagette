package react.store;
// it's just easier with this lib
import classnames.ClassNames.fastNull as classNames;
import react.ReactComponent;
import react.ReactMacro.jsx;
import mui.CagetteTheme.CGColors;
import mui.core.Grid;
import mui.core.TextField;
import mui.core.FormControl;
import mui.core.form.FormControlVariant;
import mui.core.input.InputType;
import mui.core.styles.Classes;
import mui.core.styles.Styles;

import Common;

using Lambda;

typedef HeaderProps = {
	> PublicProps,
	var classes:TClasses;
};

private typedef PublicProps = {
    var order:OrderSimple;
	var addToCart:ProductInfo->Int->Void;
	var removeFromCart:ProductInfo->?Int->Void;
	var submitOrder:OrderSimple->Void;
}

private typedef TClasses = Classes<[
    cagWrap,
    cagNavInfo,
    searchField,
    cagFormContainer,
]>

@:publicProps(PublicProps)
@:wrap(Styles.withStyles(styles))
class Header extends react.ReactComponentOfProps<HeaderProps> {
	public static function styles(theme:mui.CagetteTheme):ClassesDef<TClasses> {
		return {
           cagWrap: {
				maxWidth: 1240,
                margin : "auto",
                padding: "0 10px",
			},

            cagNavInfo : {
                fontSize: "0.9rem",
                color: CGColors.Secondfont,
                padding: "10px 0",
                
                "& p" : {
                    margin: "0 0 0.2rem 0",// !important  hum...
                },

                "& a" : {
                    color : CGColors.Firstfont, // !important   hum....
                },

                "& i" : {
                    color : CGColors.Firstfont,
                    fontSize: "1.1em",
                    verticalAlign: "middle",//TODO replace later with proper externs enum
                    marginRight: "0.2rem",
                },
            },

            searchField : {
                width: 200,
                padding: '0.5em',
            },

            cagFormContainer : {
                fontSize: "1.2rem",
                fontWeight: "bold",//TODO use enum from externs when available
                display: "flex",
                alignItems: Center,
                justifyContent: Center,
            },
		}
	}

	public function new(props) {
		super(props);
	}

	override public function render() {
        var classes = props.classes;

        //TODO localization
        var textInfos1Link = jsx('<a href="#">Changer</a>');
        var textInfos3Link = jsx('<a href="#">Plus d\'infos></a>');
        var textInfos1 = jsx('120 rue Fondaudège, Bordeaux.');
        var textInfos2 = jsx('Distribution le vendredi 29 juin entre 18h et 20h. Commandez jusqu\'au 27 juin.');
        var textInfos3 = jsx('Paiement: CB, chèque ou espèces.');
		return jsx('
            <div className=${classes.cagWrap}>
            <Grid container spacing={8}>
                <Grid item xs={6}> 
                    <div className=${classes.cagNavInfo}> 
                        <p><i className="icon-euro_icon"></i>${textInfos1} ${textInfos1Link}</p>
                        <p><i className="icon-euro_icon"></i>${textInfos2}</p>
                        <p><i className="icon-euro_icon"></i>${textInfos3} ${textInfos3Link}</p>                     
                    </div>
                </Grid>
                <Grid item xs={3}>  
                    <div className=${classes.cagFormContainer}>
                        <FormControl>
                            <TextField                            
                                label="Search field"
                                variant=${Outlined}
                                type=${Search}  
                                className=${classes.searchField}
                            />                        
                        </FormControl>
                    </div>                                                        
                </Grid>
                <Cart   
                    order=${props.order}
                    addToCart=${props.addToCart}
                    removeFromCart=${props.removeFromCart}
                    submitOrder=${props.submitOrder}
                />
            </Grid>
            </div>
        ');
    }
}


