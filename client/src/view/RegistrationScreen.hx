package view;

import view.RegistrationView.RegistrationViewProps;
import action.ScholaeAction;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.RouterLocation.RouterAction;
import view.LoginView;

class RegistrationScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, RegistrationViewProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<RegistrationView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): RegistrationViewProps {

        haxe.Timer.delay(function() {
            if (state.scholae != null && state.scholae.registration.registered && state.scholae.registration.redirectPath != null) {
                props.router.replace(
                    {
                        pathname: state.scholae.registration.redirectPath,
                        search: null,
                        state: null,
                        action: RouterAction.PUSH,
                    });
                dispatch(ScholaeAction.PreventRegistrationRedirection);
            }
        }, 10);

        return
            {
                register: function(email, password, codeforcesId) {
                    dispatch(ScholaeAction.Register(email, password, codeforcesId));
                },
                cancel: function() {
                    props.router.goBack();
                }
            };
    }
}
