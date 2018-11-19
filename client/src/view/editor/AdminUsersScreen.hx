package view.editor;

import action.AdminAction;
import view.editor.AdminUsersView.AdminUsersProps;
import action.EditorAction;
import utils.RemoteDataHelper;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;

using utils.RemoteDataHelper;

class AdminUsersScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, AdminUsersProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<AdminUsersView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): AdminUsersProps {
        RemoteDataHelper.ensureRemoteDataLoaded(state.admin.users, AdminAction.LoadUsers);
        return {
            users: state.admin.users.data
        }
    }
}
