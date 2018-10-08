package view;

import router.RouterLocation.RouterAction;
import action.ScholaeAction;
import react.ReactComponent.ReactElement;
import redux.react.IConnectedComponent;
import view.EmailActivationView;
import router.RouteComponentProps;
import react.ReactComponent.ReactComponentOfPropsAndState;
import react.ReactMacro.jsx;

import utils.TimerHelper.defer;

class EmailActivationScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, EmailActivationViewProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<EmailActivationView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): EmailActivationViewProps {
        return
            {
                emailActivation: function(code) {
                    dispatch(ScholaeAction.EmailActivationCode(code));
                },
                emailActivated: state.scholae.activetedEmail
            };
    }
}
