package view.editor;

import action.EditorAction;
import utils.RemoteDataHelper;
import view.editor.EditorUsersView;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;

using utils.RemoteDataHelper;

class EditorUsersScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, EditorUsersProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<EditorUsersView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): EditorUsersProps {
        RemoteDataHelper.ensureRemoteDataLoaded(state.editor.users, EditorAction.LoadUsers);
        return {
            users: state.editor.users.data
        }
    }
}
