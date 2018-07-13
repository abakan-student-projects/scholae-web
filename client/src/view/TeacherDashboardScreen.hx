package view;

import action.ScholaeAction;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import react.ReactComponent;
import react.ReactMacro.jsx;

typedef TeacherDashboardProps = {
    groups: Array<String>
}

class TeacherDashboardScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, TeacherDashboardProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<h1>Teacher dashboard</h1>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): TeacherDashboardProps {

        if (state.scholae.teacher == null) {
            if (!state.scholae.loading) {
                haxe.Timer.delay(function() {
                    dispatch(ScholaeAction.LoadGroups);
                }, 10);
            }
            return { groups: [] };
        } else {
            return { groups: Lambda.array(Lambda.map(state.scholae.teacher.groups, function(g) { return g.name; } )) };
        }
    }
}
