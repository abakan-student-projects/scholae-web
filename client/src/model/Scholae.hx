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
import services.AuthServiceClient;

typedef ScholaeState = {
    auth: AuthState,
    loading: Bool,
    registration: RegistrationState
}

class Scholae
    implements IReducer<ScholaeAction, ScholaeState>
    implements IMiddleware<ScholaeAction, ApplicationState> {

    public var initState: ScholaeState = {
        auth: {
            loggedIn: false,
            email: null,
            sessionId: null,
            returnPath: null,
            firstName: null,
            lastName: null,
            roles: new Roles()
        },
        registration: {
            codeforcesId: null,
            email: null,
            password: null,
            firstName: null,
            lastName: null,
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

            case Register(email, password, codeforcesId, firstName, lastName): state;
            case RegisteredAndAuthenticated(sessionId): state;
            case PreventRegistrationRedirection: state;
            case RenewPassword (email):state;

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
            
            case RenewPassword(email):
                AuthServiceClient.instance.RenewalPasswordEmailToUser(email);
                next();
            default: next();
        }
    }
}
