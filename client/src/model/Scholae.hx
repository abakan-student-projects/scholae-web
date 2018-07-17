package model;

import utils.UIkit;
import model.Role.Roles;
import services.TeacherServiceClient;
import model.RegistrationState;
import router.RouterLocation.RouterAction;
import services.Session;
import redux.StoreMethods;
import redux.StoreMethods;
import redux.IMiddleware;
import action.ScholaeAction;
import redux.IReducer;
import react.ReactUtil.copy;
import messages.GroupMessage;

typedef ScholaeState = {
    teacher: TeacherState,
    auth: AuthState,
    loading: Bool,
    registration: RegistrationState
}

class Scholae
    implements IReducer<ScholaeAction, ScholaeState>
    implements IMiddleware<ScholaeAction, ApplicationState> {

    public var initState: ScholaeState = {
        teacher: null,
        auth: {
            loggedIn: false,
            email: null,
            sessionId: null,
            returnPath: null,
            name: null,
            roles: new Roles()
        },
        registration: {
            codeforcesId: null,
            email: null,
            password: null,
            registered: false,
            redirectPath: "/",
            errorMessage: null
        },
        loading: false
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: ScholaeState, action: ScholaeAction): ScholaeState {
        return switch(action) {
            case AuthenticationFailed: copy(state, { loading: false });
            case Authenticate(email, password): copy(state,
                {
                    loading: true,
                    auth: copy(state.auth, { returnPath: if (state.auth.returnPath != null) state.auth.returnPath else "/" })
                });

            case Authenticated(email, sessionId): copy(state,
                {
                    auth: copy(state.auth, {
                        loggedIn: true,
                        email: email,
                        sessionId: sessionId
                    })
                });

            case PreventLoginRedirection: copy(state,
                {
                    auth: copy(state.auth, {
                        returnPath: null
                    })
                });

            case Register(email, password, codeforcesId,name,lastname): state;
            case RegisteredAndAuthenticated(sessionId): state;
            case PreventRegistrationRedirection: state;

            case LoadGroups: copy(state, { loading: true });
            case LoadGroupsFinished(groups):
                var teacher: TeacherState = if (state.teacher != null) state.teacher else { groups: groups, showNewGroupView: false };
                copy(state, {
                    loading: false,
                    teacher: teacher
                });
            case ShowNewGroupView:
                copy(state, {
                    teacher: copy(state.teacher, { showNewGroupView: true })
                });
            case HideNewGroupView:
                copy(state, {
                    teacher: copy(state.teacher, { showNewGroupView: true })
                });
            case AddGroup(name, signUpKey): copy(state, { loading: true });
            case GroupAdded(group):
                var teacher = if (state.teacher != null) state.teacher else { groups: new Array<GroupMessage>(), showNewGroupView: false };
                var nextState: ScholaeState = copy(state, {
                    loading: false,
                    teacher: teacher
                });
                nextState.teacher.groups.push(group);
                nextState.teacher.showNewGroupView = false;
                nextState;
        }
    }

    public function middleware(action: ScholaeAction, next:Void -> Dynamic) {
        return switch(action) {
            case Authenticate(email, password):
                Session.login(email, password)
                .then(
                    function(id) {
                        store.dispatch(Authenticated(email, id));
                    },
                    function(e) {
                        store.dispatch(AuthenticationFailed);
                    }
                );
                next();

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
