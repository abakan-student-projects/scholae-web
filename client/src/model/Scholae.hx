package model;

import utils.RemoteData;
import utils.RemoteDataHelper;
import messages.SessionMessage;
import messages.ProfileMessage;
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
    activetedEmail: Bool,
    registration: RegistrationState,
    profile: RemoteData<ProfileMessage>
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
            codeforcesHandle: null,
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
        activetedEmail: false,
        loading: false,
        profile: RemoteDataHelper.createEmpty()
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: ScholaeState, action: ScholaeAction): ScholaeState {
        return switch(action) {
            case AuthenticationFailed(failMessage): copy(state, { loading: false });
            case Authenticate(email, password): copy(state,
                {
                    loading: true,
                    auth: copy(state.auth, { returnPath: if (state.auth.returnPath != null) state.auth.returnPath else "/" })
                });

            case Authenticated(sessionMessage): copy(state,
                {
                    auth: copy(state.auth, {
                        loggedIn: true,
                        email: sessionMessage.email,
                        sessionId: sessionMessage.sessionId,
                        firstName: sessionMessage.firstName,
                        lastName: sessionMessage.lastName,
                        roles: sessionMessage.roles
                    })
                });

            case PreventLoginRedirection: copy(state,
                {
                    auth: copy(state.auth, {
                        returnPath: null
                    })
                });

            case Register(email, password, codeforcesId, firstName, lastName): state;
            case RegisteredAndAuthenticated(sessionMessage): copy(state,
                {
                    auth: copy(state.auth, {
                        loggedIn: true,
                        email: sessionMessage.email,
                        sessionId: sessionMessage.sessionId,
                        firstName: sessionMessage.firstName,
                        lastName: sessionMessage.lastName,
                        roles: sessionMessage.roles
                    }),
                    registration: copy(state.registration, {
                        registered: true
                    })
                });
            case PreventRegistrationRedirection: copy(state,
                {
                    registration: copy(state.registration, {
                        codeforcesId: null,
                        email: null,
                        password: null,
                        firstName: null,
                        lastName: null,
                        registered: false,
                        redirectPath: "/",
                        errorMessage: null
                    })
                });
            case RegistrationFailed(message): copy(state,
                {
                    registration: copy(state.registration, {
                        errorMessage: message
                    })
                });
            case Clear: initState;
            case RenewPassword (email):state;
            case EmailActivationCode(code): copy(state, null);
            case EmailActivationCodeFinished(check): copy(state, {
                activetedEmail: check
            });
            case SendActivationEmail: state;
            case GetProfile: copy(state, { profile: RemoteDataHelper.createLoading() });
            case UpdateProfile(profileMessage): copy(state, {
                profile: RemoteDataHelper.createLoading()
            });
            case UpdateProfileFinished(profileMessage): copy(state, {
                profile: RemoteDataHelper.createLoaded(profileMessage),
                auth: copy(state.auth, {
                    firstName: profileMessage.firstName,
                    lastName: profileMessage.lastName,
                })
            });
            case UpdateEmail(profileMessage): copy(state, {
                profile: RemoteDataHelper.createLoading()
            });
            case UpdateEmailFinished(profileMessage): copy(state, {
                profile: RemoteDataHelper.createLoaded(profileMessage),
                auth: copy(state.auth, {
                    email: profileMessage.email
                })
            });
            case UpdatePassword(passwordMessage): state;
        }
    }

    public function middleware(action: ScholaeAction, next:Void -> Dynamic) {
        return switch(action) {
            case Authenticate(email, password):
                Session.login(email, password)
                    .then(
                        function(sessionMessage) {
                            store.dispatch(Authenticated(sessionMessage));
                        },
                        function(e) {
                            store.dispatch(AuthenticationFailed(e));
                        }
                    );
                next();

            case AuthenticationFailed(failMessage):
                UIkit.notification({ message: Std.string(failMessage), timeout: 3000 });
                next();

            case Clear:
                Session.logout();
                next();

            case RenewPassword(email):
                AuthServiceClient.instance.renewPassword(email);
                next();

            case EmailActivationCode(code):
                AuthServiceClient.instance.emailActivation(code)
                    .then(function(check) {
                        store.dispatch(EmailActivationCodeFinished(check));
                    });
                next();

            case Register(email, password, codeforcesId, firstName, lastName):
                AuthServiceClient.instance.registerAndAuthenticateUser({
                    id: null,
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    codeforcesHandle: codeforcesId,
                    password: password,
                    roles: null
                }).then(
                    function(sessionMessage) {
                        Session.sessionId = sessionMessage.sessionId;
                        store.dispatch(RegisteredAndAuthenticated(sessionMessage));
                    },
                    function(e) {
                        store.dispatch(RegistrationFailed(e));
                    });
                next();

            case RegistrationFailed(message):
                UIkit.notification({ message: "Ошибка при регистрации: " + message + ".", timeout: 5000, status: "warning" });
                next();

            case SendActivationEmail:
                AuthServiceClient.instance.sendActivationEmail().then(
                    function(check) {
                        if(check) {
                            UIkit.notification({
                                message: "Письмо успешно отправлено", timeout: 5000, status: "success"
                            });
                        } else {
                            UIkit.notification({
                                message: "Письмо не отправлено", timeout: 5000, status: "warning"
                            });
                        }
                    },
                    function(e) {
                        UIkit.notification({
                            message: "Письмо не отправлено", timeout: 5000, status: "warning"
                        });
                    });
                next;

            case GetProfile:
                AuthServiceClient.instance.getProfile().then(
                    function(profileMessage) {
                        store.dispatch(UpdateProfileFinished(profileMessage));
                    },
                    function(e) {
                        UIkit.notification({
                            message: "Ошибка загрузки профиля: " + e + ".", timeout: 5000, status: "warning"
                        });
                    });
                next;

            case UpdateProfile(profileMessage):
                AuthServiceClient.instance.updateProfile(profileMessage).then(
                    function(profileMessage) {
                        UIkit.notification({ message: "Профиль обновлён", timeout: 5000, status: "success" });
                        store.dispatch(UpdateProfileFinished(profileMessage));
                    },
                    function(e) {
                        UIkit.notification({
                            message: "Ошибка обновления профиля: " + e + ".", timeout: 5000, status: "warning"
                        });
                    });
                next;

            case UpdateEmail(profileMessage):
                AuthServiceClient.instance.updateEmail(profileMessage).then(
                    function(profileMessage) {
                        UIkit.notification({ message: "Email обновлён", timeout: 5000, status: "success" });
                        store.dispatch(UpdateEmailFinished(profileMessage));
                    },
                    function(e) {
                        UIkit.notification({
                            message: "Ошибка обновления email: " + e + ".", timeout: 5000, status: "warning"
                        });
                    });
                next;

            case UpdatePassword(passwordMessage):
                AuthServiceClient.instance.updatePassword(passwordMessage).then(
                    function(check) {
                        UIkit.notification({
                            message: "Пароль успешно изменен", timeout: 5000, status: "success"
                        });
                    },
                    function(e) {
                        UIkit.notification({
                            message: e, timeout: 5000, status: "warning"
                        });
                    });
                next;

            default: next();
        }
    }
}
