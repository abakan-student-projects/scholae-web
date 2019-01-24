package view;

import action.ProfileAction;
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
            RemoteDataHelper.ensureRemoteDataLoaded(state.profile.data, ProfileAction.GetProfile);
        }
        return
            {
                profile:  state.profile.data.data,
                update: function(codeforcesId, name, lastname) {
                    dispatch(ProfileAction.UpdateProfile(codeforcesId, name, lastname));
                    dispatch(ScholaeAction.UpdateAutenticationData);
                },
                cancel: function() {
                    props.router.goBack();
                }
            }
    }
}
