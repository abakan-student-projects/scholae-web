package services;

import messages.SessionMessage;
import utils.StringUtils;
import js.Promise;
/**
 * ...
 * @author Nick Grebenschikov
 */

class Session {

	public static var sessionId(get, set): String;
	
	private static function get_sessionId(): String {
		return js.Browser.getLocalStorage().getItem("sessionId");
	}
	
	private static function set_sessionId(sid: String): String {
		js.Browser.getLocalStorage().setItem("sessionId", sid);
		return sid;
	}
	
	public static function isUserLoggedIn() {
		return !StringUtils.isStringNullOrEmpty(sessionId);
	}
	
	public static function login(email: String, password: String): Promise<SessionMessage> {
		return AuthServiceClient.instance.authenticate(email, password)
			.then(function(sessionMessage: SessionMessage) {
				sessionId = sessionMessage.sessionId;
				return sessionMessage;
		});
	}
	
	public static function logout() {
		sessionId = null;
	}
	
}