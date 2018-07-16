package model;

import action.TeacherAction;
import model.RegistrationState;
import model.Role.Roles;
import react.ReactUtil.copy;
import redux.IMiddleware;
import redux.IReducer;
import redux.StoreMethods;
import services.Session;
import services.TeacherServiceClient;
import utils.UIkit;

class Teacher
    implements IReducer<TeacherAction, TeacherState>
    implements IMiddleware<TeacherAction, ApplicationState> {

    public var initState: TeacherState = {
        groups: null,
        showNewGroupView: false,
        loading: false
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: TeacherState, action: TeacherAction): TeacherState {
        trace(action);
        return switch(action) {
            case LoadGroups: copy(state, { loading: true });
            case LoadGroupsFinished(groups):
                copy(state, {
                    loading: false,
                    groups: groups,
                    showNewGroupView: false
                });
            case ShowNewGroupView:
                copy(state, {
                    showNewGroupView: true
                });
            case HideNewGroupView:
                copy(state, {
                    showNewGroupView: false
                });
            case AddGroup(name, signUpKey): copy(state, { loading: true });
            case GroupAdded(group):
                var nextState: TeacherState = copy(state, {
                    loading: false,
                });
                nextState.groups.push(group);
                nextState.showNewGroupView = false;
                nextState;

            default: state;
        }
    }

    public function middleware(action: TeacherAction, next:Void -> Dynamic) {
        trace(action);
        return switch(action) {
            case LoadGroups:
                TeacherServiceClient.instance.getAllGroups()
                    .then(
                        function(groups) {
                            store.dispatch(LoadGroupsFinished(groups));
                        }
                    );
                next();

            case AddGroup(name, signUpKey):
                TeacherServiceClient.instance.addGroup(name, signUpKey)
                .then(
                    function(group) {
                        store.dispatch(GroupAdded(group));
                    }
                );
                next();
            case GroupAdded(group):
                UIkit.notification({ message: "Создана новая группа '" + group.name + "'.", timeout: 3000 });
                next();
            default: next();
        }
    }
}
