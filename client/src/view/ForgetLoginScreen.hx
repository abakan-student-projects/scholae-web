package view;

import view.ForgetLoginView.ForgetLoginViewProps;
import action.ScholaeAction;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.RouterLocation.RouterAction;
import utils.TimerHelper.defer;
import view.LoginView;

class ForgetLoginScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, ForgetLoginViewProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<ForgetLoginView {...state} dispatch=$dispatch/>');
    }
}
