package view.teacher;

import utils.RemoteDataHelper;
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

        TeacherViewsHelper.ensureGroupsLoaded(state);
        RemoteDataHelper.ensureRemoteDataLoaded(state.teacher.lastLearnerAttempts, TeacherAction.LoadLastLearnerAttempts);

        return {
            groups: if(state.teacher.groups.loaded) Lambda.array(state.teacher.groups.data) else [],
            showNewGroupView: if(state.teacher.groups.loaded) state.teacher.showNewGroupView else false,
            lastAttempts: state.teacher.lastLearnerAttempts.data
        }
    }
}
