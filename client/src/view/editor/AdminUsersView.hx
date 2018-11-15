package view.editor;

import js.html.InputElement;
import Array;
import messages.AdminMessage;
import haxe.EnumTools.EnumValueTools;
import model.Role;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import react.ReactUtil.copy;

typedef AdminUsersProps = {
    users: Array<AdminMessage>,
    roles: Array<Roles>
}

typedef AdminUsersRefs = {
    editingFirstNameInput: InputElement,
    editingLastNameInput: InputElement,
    rolesSelect: Dynamic
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

    public function getAllRoles(){
        var roles = Type.allEnums(Role);
        return roles;
    }

    override function render() {
            var roles = getAllRoles();
            var users = if (props.users != null && state.editingUserId == null)
                [ for (u in props.users)
                        jsx('
                        <tr className="uk-margin scholae-list-item" key=${u.userId}>
                            <td>${u.firstName}</td>
                            <td>${u.lastName}</td>
                            <td>${getNameRole(u.roles)}</td>
                            <td><button onClick=${setStateUserId.bind(u.userId)}>Изменить</td>
                        </tr>
                    ')
                ] else [jsx('
                        <tr className="uk-margin scholae-list-item" key=${u.userId}>
                            <td><input type="text" className="uk-input" defaultValue=${u.firstName} ref="editingFirstNameInput"/></td>
                            <td><input type="text" className="uk-input" defaultValue=${u.lastName} ref="editingLastNameInput"/></td>
                            <td><Select
                                isMulti=${true}
                                options=$roles
                                defaultValue=${getNameRole(u.roles)}
                                onChange=$onSelectedRoleChanged
                                placeholder="Выберите роль..."
                                ref="rolesSelect"/></td>
                            <button className="uk-button uk-button-primary"  onClick=$updateUsers>Сохранить</button>
                            <button className="uk-button uk-button-default uk-margin-left" onClick=$cancelUpdating>Отмена</button>
                        </tr>
                        ')];
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
    function setStateUserId(userId: Float){
        setState(copy(state, { editingUserId: userId }));
    }

    function onSelectedRoleChanged(roles){
        props.onRolesChanged(if (roles != null) Lambda.array(Lambda.map(roles, function(r) { return Std.parseFloat(r.value); })) else []);
        trace(roles);
    }

    function updateUsers(){

    }

    function cancelUpdating(){
        setState(copy(state, { editingUserId: null }));
    }
}
