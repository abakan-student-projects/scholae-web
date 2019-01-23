package view;

import js.html.Console;
import utils.RemoteDataHelper;
import view.UserProfileView.UserProfileViewProps;
import action.ScholaeAction;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.RouterLocation.RouterAction;

class UserProfileScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, UserProfileViewProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<UserProfileView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): UserProfileViewProps {
        if (state.scholae.auth.loggedIn) {
            Main.store.dispatch(ScholaeAction.GetProfile);
        }
        return
            {
                codeforcesId: state.scholae.auth.codeforcesHandle,
                firstName: state.scholae.auth.firstName,
                lastName: state.scholae.auth.lastName,
                update: function(codeforcesId, name, lastname) {
                    dispatch(ScholaeAction.UpdateProfile(codeforcesId, name, lastname));
                },
                cancel: function() {
                    props.router.goBack();
                }
            }
    }
}
