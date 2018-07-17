package view.teacher;

import action.TeacherAction;
import view.teacher.TeacherDashboardView;
import action.ScholaeAction;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import react.ReactComponent;
import react.ReactMacro.jsx;

using utils.RemoteDataHelper;

class TeacherDashboardScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, TeacherDashboardProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<TeacherDashboardView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): TeacherDashboardProps {

        if (state.teacher.groups == null || state.teacher.groups.shouldInitiate()) {
            haxe.Timer.delay(function() {
                dispatch(TeacherAction.LoadGroups);
            }, 10);
            return { groups: [], showNewGroupView: false };
        } else {
            return {
                groups: if(state.teacher.groups.loaded) Lambda.array(state.teacher.groups.data) else [],
                showNewGroupView: state.teacher.showNewGroupView
            };
        }
    }
}
