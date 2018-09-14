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

	public static function getTaskStringFor(number: Int): String {
		var remainder = number % 10;
		return "задач" + switch(remainder) {
			case 1: "а";
			case 2 | 3 | 4: "и";
			default: "";
		};
	}
	public static function unescapeHtmlSpecialCharacters(text){
		text = StringTools.replace(text, "&laquo;", "«");
		text = StringTools.replace(text, "&raquo;", "»");
		text = StringTools.replace(text, "&hellip;", "...");
		text = StringTools.replace(text, "&ndash;", "-");
		text = StringTools.replace(text, "&mdash;", "–");
		text = StringTools.replace(text, "&rsquo;", "’");
		text = StringTools.replace(text, "&quot;", '"');
		text = StringTools.replace(text, "&amp;", "&");
		text = StringTools.replace(text, "&scaron;", "Š");
		text = StringTools.replace(text, "&aacute;", "Á");
		text = StringTools.replace(text, "&acute;", "´");
		text = StringTools.replace(text, "&icirc;", "Î");
		text = StringTools.replace(text, "&eacute;", "é");
		text = StringTools.replace(text, "&atilde;", "Ã");
		text = StringTools.replace(text, "&ldquo;", '“');
		text = StringTools.replace(text, "&gt;", ">");
		text = StringTools.replace(text, "&lt;", "<");
		return text;
	}
}