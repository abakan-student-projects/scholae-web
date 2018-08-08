package services;

import messages.SessionMessage;
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
        return new Promise(function(success, fail) {
            context.AuthService.authenticate.call([email, password], function(e) {
                return if (null != e) {
                    success(e);
                } else {
                    fail(null);
                }
            });
        });
    }

    public function checkSession(sessionId: String): Promise<SessionMessage> {
        return new Promise(function(success, fail) {
            context.AuthService.checkSession.call([sessionId], function(e) {
                return if (null != e) {
                    success(e);
                } else {
                    fail(null);
                }
            });
        });
    }

}
