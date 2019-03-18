package services;

import achievement.AchievementMessage;
import messages.PasswordMessage;
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

    public function sendActivationEmail() : Promise<Bool> {
        return new Promise(function(success, fail) {
            context.AuthService.sendActivationEmail.call([], function(e) {
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

    public function updateProfile(profileMessage: ProfileMessage) : Promise<ProfileMessage> {
        return request(function(success, fail) {
           context.AuthService.updateProfile.call([profileMessage], function(e) {
               processResponse(e, success, fail);
           });
        });
    }

    public function updateEmail(profileMessage: ProfileMessage) : Promise<ProfileMessage> {
        return request(function(success, fail) {
           context.AuthService.updateEmail.call([profileMessage], function(e) {
              processResponse(e, success, fail);
           });
        });
    }

    public function updatePassword(passwordMessage: PasswordMessage) : Promise<Bool> {
        return new Promise(function(success, fail) {
            context.AuthService.updatePassword.call([passwordMessage], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getAchievements(): Promise<Array<AchievementMessage>> {
        return request(function(success, fail) {
            context.AuthService.getAchievements.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }
}
