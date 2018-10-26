package view.editor;

import messages.LearnerMessage;
import action.EditorAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;

typedef EditorUsersProps = {
    users: Array<LearnerMessage>
}

/*typedef EditorUsersRefs = {

}

typedef EditorUsersState = {

}*/

class EditorUsersView extends ReactComponentOfProps<EditorUsersProps> implements IConnectedComponent {

    public function new()
    {
        super();
    }

    override function render() {
            var users =
                [ for (u in props.users)
                        jsx('
                        <tr className="uk-margin scholae-list-item" key=${u.id}>
                            <td>${u.firstName}</td>
                            <td>${u.lastName}</td>
                        </tr>
                    ')
                ];
            return jsx('
                    <div id="users">
                        <h2>Пользователи</h2>
                        <table className="uk-table uk-table-divider uk-table-middle uk-table-hover">
                            <thead>
                                <tr>
                                    <th>Название на английском</th>
                                    <th>Название на русском</th>
                                    <th className="uk-table-expand"></th>
                                </tr>
                            </thead>
                            <tbody>
                                $users
                            </tbody>
                        </table>
                    </div>
                ');
    }
}
