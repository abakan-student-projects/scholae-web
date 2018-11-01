package view.editor;

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


class AdminUsersView extends ReactComponentOfProps<AdminUsersProps> implements IConnectedComponent {

    public function new()
    {
        super();
    }

    public function getNameRole(role: Roles){
        var roles = Type.allEnums(Role);
        var n: Roles;
        if (role.has(EnumValueTools.getIndex(Role.Learner)))
            n.set(Role.Learner);
        if (role.has(EnumValueTools.getIndex(Role.Teacher)))
            n.set(Role.Teacher);
        if (role.has(EnumValueTools.getIndex(Role.Administrator)))
            n.set(Role.Administrator);
        if (role.has(EnumValueTools.getIndex(Role.Learner)))
            n.set(Role.Learner);
        trace (r);
        return r;
    }

    override function render() {
        //var roles = getNameRole();
            var users = if (props.users != null)
                [ for (u in props.users)
                        jsx('
                        <tr className="uk-margin scholae-list-item" key=${u.userId}>
                            <td>${u.firstName}</td>
                            <td>${u.lastName}</td>
                            <td>${getNameRole(u.roles)}</td>
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
}
