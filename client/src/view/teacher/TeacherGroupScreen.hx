package view.teacher;

import action.TeacherAction;
import view.teacher.TeacherGroupView.TeacherGroupProps;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import view.teacher.TeacherDashboardView;

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

        if (state.teacher.groups == null) {
            if (!state.teacher.loading) {
                haxe.Timer.delay(function() {
                    dispatch(TeacherAction.LoadGroups);
                    trace("load groups");
                }, 10);
            }
            return { group: null };
        } else {
            return { group: Lambda.find(state.teacher.groups, function(g) { return g.id == props.params.id; }) }
        }
    }
}
