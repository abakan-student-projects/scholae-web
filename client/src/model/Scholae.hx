package model;

import router.RouterLocation.RouterAction;
import services.Session;
import redux.StoreMethods;
import redux.StoreMethods;
import redux.IMiddleware;
import action.ScholaeAction;
import redux.IReducer;
import react.ReactUtil.copy;

typedef ScholaeState = {
    auth: AuthState,
    loading: Bool
}

class Scholae
    implements IReducer<ScholaeAction, ScholaeState>
    implements IMiddleware<ScholaeAction, ApplicationState> {

    public var initState: ScholaeState = {
        auth: {
            loggedIn: false,
            email: null,
            sessionId: null,
            returnPath: null
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

            default: next();
        }
    }
}
