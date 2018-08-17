package view;

import view.ForgetLoginView.ForgetLoginViewProps;
import view.ForgetLoginView.ForgetLoginViewProps;
import action.ScholaeAction;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.RouterLocation.RouterAction;
import utils.TimerHelper.defer;
import view.LoginView;

class ForgetLoginScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, ForgetLoginViewProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<ForgetLoginView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): ForgetLoginViewProps {

        return {

            renewPassword: function (email:String) {

                props.router.push(
                    {
                    pathname: "renewpasswordresponse",//тут тоже в мэйне поменять название ссылки
                    search:null,
                    state:null,
                    action:RouterAction.PUSH
                    });
                dispatch (ScholaeAction.RenewPassword(email));
            }
        }
    }

}
