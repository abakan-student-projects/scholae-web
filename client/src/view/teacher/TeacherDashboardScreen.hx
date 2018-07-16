package view.teacher;

import action.TeacherAction;
import view.teacher.TeacherDashboardView;
import action.ScholaeAction;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import react.ReactComponent;
import react.ReactMacro.jsx;

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

        if (state.teacher.groups == null) {
            if (!state.teacher.loading) {
                haxe.Timer.delay(function() {
                    dispatch(TeacherAction.LoadGroups);
                }, 10);
            }
            return { groups: [], showNewGroupView: false };
        } else {
            return {
                groups: Lambda.array(state.teacher.groups),
                showNewGroupView: state.teacher.showNewGroupView
            };
        }
    }
}
