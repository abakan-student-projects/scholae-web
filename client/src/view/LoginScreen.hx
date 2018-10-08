package view;

import router.RouterLocation.RouterAction;
import action.ScholaeAction;
import react.ReactComponent.ReactElement;
import redux.react.IConnectedComponent;
import view.LoginView;
import router.RouteComponentProps;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactMacro.jsx;

import utils.TimerHelper.defer;

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
            trace(state);
            if (state.scholae != null && state.scholae.auth.loggedIn && state.scholae.auth.returnPath != null) {
                var returnPath = state.scholae.auth.returnPath;
                defer(function() {
                    props.router.replace(
                        {
                            pathname: returnPath,
                            search: null,
                            state: null,
                            action: RouterAction.REPLACE,
                        });
                    dispatch(ScholaeAction.PreventLoginRedirection);
                 });
            }

        return
            {
                signIn: function(email, password) {
                    dispatch(ScholaeAction.Authenticate(email, password));
                }
            };
    }
}
