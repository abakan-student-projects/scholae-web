package messages;

@:enum
abstract ResponseStatus(String) {
    var OK = "OK";
    var Error = "Error";
}
