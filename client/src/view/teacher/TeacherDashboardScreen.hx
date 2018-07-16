package view.teacher;

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

        if (state.scholae.teacher == null) {
            if (!state.scholae.loading) {
                haxe.Timer.delay(function() {
                    dispatch(ScholaeAction.LoadGroups);
                }, 10);
            }
            return { groups: [], showNewGroupView: false };
        } else {
            return {
                groups: Lambda.array(state.scholae.teacher.groups),
                showNewGroupView: state.scholae.teacher.showNewGroupView
            };
        }
    }
}
