package view;

import router.RouterLocation.RouterAction;
import action.ScholaeAction;
import react.ReactComponent.ReactElement;
import redux.react.IConnectedComponent;
import view.LoginView;
import router.RouteComponentProps;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactMacro.jsx;
import router.ReactRouter;

class LoginScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, LoginViewProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<LoginView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): LoginViewProps {

        haxe.Timer.delay(function() {
            if (state.scholae != null && state.scholae.auth.loggedIn && state.scholae.auth.returnPath != null) {
                props.router.replace(
                    {
                        pathname: state.scholae.auth.returnPath,
                        search: null,
                        state: null,
                        action: RouterAction.REPLACE,
                    });
                dispatch(ScholaeAction.PreventLoginRedirection);
            }
        }, 10);

        return
            {
                signIn: function(email, password) {
                    dispatch(ScholaeAction.Authenticate(email, password));
                }
            };
    }
}
