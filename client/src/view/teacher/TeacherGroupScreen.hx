package view.teacher;

import model.Teacher;
import action.TeacherAction;
import view.teacher.TeacherGroupView.TeacherGroupProps;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import view.teacher.TeacherDashboardView;
import utils.TimerHelper.defer;

using utils.RemoteDataHelper;

class TeacherGroupScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, TeacherGroupProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<TeacherGroupView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): TeacherGroupProps {
        if (state.teacher.groups.shouldInitiate()) {
            defer(function() {
                dispatch(TeacherAction.LoadGroups);
            });
        } else if(
                state.teacher.groups.loaded &&
                (state.teacher.currentGroup == null || state.teacher.currentGroup.info.id != props.params.id)) {
                    defer(function() {
                        dispatch(TeacherAction.SetCurrentGroup(
                            Lambda.find(
                                state.teacher.groups.data,
                                function(g) { return g.id == props.params.id; })));
                    });
        }

        return { group: if (null != state.teacher.currentGroup) state.teacher.currentGroup.info else null };
    }

}
