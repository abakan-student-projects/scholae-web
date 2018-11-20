package view.editor;

import utils.UIkit;
import haxe.EnumTools;
import action.AdminAction;
import haxe.EnumTools.EnumValueTools;
import model.Role;
import haxe.EnumTools.EnumValueTools;
import js.html.InputElement;
import Array;
import messages.UserMessage;
import haxe.EnumTools.EnumValueTools;
import model.Role;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import react.ReactUtil.copy;
import utils.Select;

typedef AdminUsersProps = {
    users: Array<UserMessage>,
    update: UserMessage -> Void
}

typedef AdminUsersRefs = {
    roleSelect: Dynamic
}

typedef AdminUsersState = {
    editingUserId: Float
}

class AdminUsersView extends ReactComponentOfProps<AdminUsersProps> implements IConnectedComponent {

    public function new()
    {
        super();
        state = { filter: "" }
    }

    var rolesName: Array<String>;
    var roleForSelect: Array<Role>;
    var roleForUpdate: Roles;

   public function getNameRole(role: Roles){
       rolesName = [];
        if (role.has(Role.Editor)) rolesName.push(" Editor");
        if (role.has(Role.Administrator)) rolesName.push(" Administrator");
        if (role.has(Role.Learner)) rolesName.push(" Learner");
        if (role.has(Role.Teacher)) rolesName.push(" Teacher");
        return jsx('<div>${rolesName}</div>');
    }

    public function getAllRoles(){
        var roles = Type.allEnums(Role);
        var result = Lambda.array(Lambda.map(roles, function(r) { return { value: EnumValueTools.getIndex(r), label: Std.string(EnumValueTools.getName(r)) }; }));
        return result;
    }

    public function getNameRoleForSelect(role: Roles){
        roleForSelect = [];
        if (role.has(Role.Editor)) roleForSelect.push(Role.Editor);
        if (role.has(Role.Administrator)) roleForSelect.push(Role.Administrator);
        if (role.has(Role.Learner)) roleForSelect.push(Role.Learner);
        if (role.has(Role.Teacher)) roleForSelect.push(Role.Teacher);

        var result = Lambda.array(Lambda.map(roleForSelect, function(r) { return { value: EnumValueTools.getIndex(r), label: Std.string(EnumValueTools.getName(r)) }; }));
        return result;
    }

    override function render() {
        if (props.users != null){
            var r = getAllRoles();
            var users =
            [for (u in props.users)
                if (state.editingUserId != null && state.editingUserId == u.id)
                    jsx('
                        <tr className="uk-margin scholae-list-item" key=${u.id}>
                            <td>${u.firstName}</td>
                            <td>${u.lastName}</td>
                            <td><Select
                                isMulti=${true}
                                options=$r
                                defaultValue=${getNameRoleForSelect(u.roles)}
                                onChange=$onSelectedRoleChanged
                                ref="roleSelect"/></td>
                            <button className="uk-button uk-button-primary uk-margin-top" onClick=$updateUsers>Сохранить</button>
                            <button className="uk-button uk-button-default uk-margin-left uk-margin-top" onClick=$cancelUpdating>Отмена</button>
                        </tr>
                    ') else jsx('
                            <tr className="uk-margin scholae-list-item" key=${u.id}>
                                    <td>${u.firstName}</td>
                                    <td>${u.lastName}</td>
                                    <td>${getNameRole(u.roles)}</td>
                                    <td><button data-uk-icon="file-edit" onClick=${startEditingRole.bind(u.id)}></button></td>
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
        } else {
            return jsx('<div>Данные отсутствуют</div>');
        }
    }

    function startEditingRole(userId: Float){
        setState(copy(state, { editingUserId: userId }));
    }

    function updateUsers(){


        var roles = [for (r in roleForSelect) EnumTools.createByIndex(Role, Std.parseInt(Std.string(r)))];
        for (role in roles){
            if (role == Role.Editor) roleForUpdate.set(Role.Editor);
            if (role == Role.Administrator) roleForUpdate.set(Role.Administrator);
            if (role == Role.Learner) roleForUpdate.set(Role.Learner);
            if (role == Role.Teacher) roleForUpdate.set(Role.Teacher);
        }

        props.update({
            id: state.editingUserId,
            email: null,
            firstName: null,
            lastName: null,
            codeforcesHandle: null,
            roles: roleForUpdate
        });
        setState(copy(state, { editingUserId: null }));
        roleForUpdate = null;
    }

    function cancelUpdating(){
        setState(copy(state, { editingUserId: null }));
    }

    function onSelectedRoleChanged(roles){
        roleForSelect = if (roles != null) Lambda.array(Lambda.map(roles, function(r) { return r.value; })) else [];
    }
}
