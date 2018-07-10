package utils;

class StringUtils {

	public static function getRandomChar(alphabet: String) {
		return alphabet.charAt(Math.round(Math.random() * (alphabet.length - 1)));
	}
	
	public static function getRandomString(alphabet: String, length: Int) {
		var buf = new StringBuf();
		while (length-- > 0) {
			buf.add(getRandomChar(alphabet));
		}
		
		return buf.toString();
	}
	
	public static var numeric = "0123456789";
    public static var alphaNumeric = numeric + "ABCDEFGHIKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

	public static function isValidEmail(email: String ): Bool {
		var emailExpression : EReg = ~/^[^@]+@.{2,}\.[a-z]{2,6}$/i;
		return emailExpression.match( email );
	}

	public static function isStringNullOrEmpty(s: String): Bool {
		return null == s || "" == s;
	}
	
}