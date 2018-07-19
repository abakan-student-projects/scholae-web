package view;

import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import view.RenewPasswordResponseView;


class RenewPasswordResponseScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, RenewPasswordResponseViewProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<RenewPasswordResponseView {...state} dispatch=$dispatch/>');
    }
}
