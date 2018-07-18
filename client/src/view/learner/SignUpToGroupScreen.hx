package view.learner;

import router.RouterLocation.RouterAction;
import action.LearnerAction;
import view.learner.SignUpToGroupView;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import utils.TimerHelper.defer;

using utils.RemoteDataHelper;

class SignUpToGroupScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, SignUpToGroupProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<SignUpToGroupView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): SignUpToGroupProps {
        if (state.learner.signup.redirectTo != null) {
            defer(function() {
                props.router.push({
                    pathname: state.learner.signup.redirectTo,
                    search: null,
                    state: null,
                    action: RouterAction.PUSH,
                });
                defer(function() {
                    dispatch(LearnerAction.SignUpRedirect(null));
                });
            });
        }
        return {};
    }
}
