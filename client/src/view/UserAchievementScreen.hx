package view;

import action.ScholaeAction;
import utils.RemoteDataHelper;
import view.UserAchievementView.UserAchievementViewProps;
import js.html.Console;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.RouterLocation.RouterAction;

class UserAchievementScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, UserAchievementViewProps>
    implements IConnectedComponent {

    public function new(props: RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<UserAchievementView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): UserAchievementViewProps {
        if(state.scholae.auth.loggedIn) {
            RemoteDataHelper.ensureRemoteDataLoaded(state.scholae.achievements, ScholaeAction.GetAchievements);
        }
        trace(state.scholae.achievements);
        return
            {
                achievements: state.scholae.achievements.data
            };
    }
}
