package services;

import messages.ProfileMessage;
import messages.UserMessage;
import messages.SessionMessage;
import messages.ResponseMessage;
import js.Promise;

class AuthServiceClient extends BaseServiceClient {

    private static var _instance: AuthServiceClient;
    public static var instance(get, null): AuthServiceClient;
    private static function get_instance(): AuthServiceClient {
        if (null == _instance) _instance = new AuthServiceClient();
        return _instance;
    }

    public function new() {
        super();
    }

    public function authenticate(email: String, password: String): Promise<SessionMessage> {
        return request(function(success, fail) {
            context.AuthService.authenticate.call([email, password], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function registerAndAuthenticateUser(user: UserMessage): Promise<SessionMessage> {
        return request(function(success, fail) {
            context.AuthService.registerAndAuthenticateUser.call([user], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function checkSession(sessionId: String): Promise<SessionMessage> {
        return request(function(success, fail) {
            context.AuthService.checkSession.call([sessionId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function renewPassword(email: String): Promise<Bool> {
        return new Promise(function(success, fail) {
            context.AuthService.renewPassword.call([email], function(e) {
                return if (null != e) {
                    success(e);
                } else {
                    fail(null);
                }
            });
        });
    }

    public function emailActivation(code: String): Promise<Bool> {
        return new Promise(function(success, fail) {
            context.AuthService.emailActivation.call([code], function(e) {
                return if (null != e) {
                    success(e);
                } else {
                    fail(null);
                }
            });
        });
    }

    public function getAuthenticationData() : Promise<SessionMessage> {
        return request(function(success, fail) {
            context.AuthService.getAuthenticationData.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getProfile() : Promise<ProfileMessage> {
        return request(function(success, fail) {
            context.AuthService.getProfile.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function updateProfile(codeforcesHandle: String, firstName: String, lastName: String) : Promise<ProfileMessage> {
        return request(function(success, fail) {
           context.AuthService.updateProfile.call([codeforcesHandle, firstName, lastName], function(e) {
               processResponse(e, success, fail);
           });
        });
    }
}
