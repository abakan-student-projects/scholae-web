package view.editor;

import Array;
import messages.AdminMessage;
import haxe.EnumTools.EnumValueTools;
import model.Role;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import react.ReactUtil.copy;

typedef AdminUsersProps = {
    users: Array<AdminMessage>
}

typedef AdminUsersRefs = {

}

typedef AdminUsersState = {
    editingUserId: Float
}

class AdminUsersView extends ReactComponentOfProps<AdminUsersProps> implements IConnectedComponent {

    public function new()
    {
        super();
    }

    public function getNameRole(role: Roles){
        var roles = Std.string(role);
        roles = StringTools.replace(roles,"1"," Learner");
        roles = StringTools.replace(roles,"2"," Teacher");
        roles = StringTools.replace(roles,"3"," Administrator");
        roles = StringTools.replace(roles,"4"," Editor");
        return roles;
    }

    override function render() {
            var users = if (props.users != null)
                [ for (u in props.users)
                        jsx('
                        <tr className="uk-margin scholae-list-item" key=${u.userId}>
                            <td>${u.firstName}</td>
                            <td>${u.lastName}</td>
                            <td>${getNameRole(u.roles)}</td>
                            <td><button onClick=$updateUsers>Изменить</td>
                        </tr>
                    ')
                ]else [jsx('<div></div>')];
            return jsx('
                    <div id="users">
                        <h2>Пользователи</h2>
                        <table className="uk-table uk-table-divider uk-table-middle uk-table-hover">
                            <thead>
                                <tr>
                                    <th>Фамилия</th>
                                    <th>Имя</th>
                                    <th>Роль</th>
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

    function viewRoles(role: String){
        var r = role;
        trace(r);
        var allr = Type.allEnums(Role);
        trace(allr);
        return r;
    }

    function updateUsers(){
        return
    }
}
