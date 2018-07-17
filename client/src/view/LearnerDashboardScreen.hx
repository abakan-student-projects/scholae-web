package view;

import view.LearnerDashboardView.LearnerDashboardViewProps;
import react.ReactComponent;
import react.ReactMacro.jsx;
import action.ScholaeAction;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import react.ReactComponent.ReactComponentOfPropsAndState;

class LearnerDashboardScreen
extends ReactComponentOfPropsAndState<RouteComponentProps, LearnerDashboardViewProps>
implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }


    override function render() {
        return jsx(' <LearnerDashboardView {...state} dispatch=$dispatch/>');
    }
}
