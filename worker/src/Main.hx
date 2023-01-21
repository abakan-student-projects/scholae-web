package ;

class Main {
    public static function main() {
        haxe.Log.trace = serverTrace;
        new Worker().run();
    }

    static function dumpError(s: String) {
        Sys.stderr().writeString("[Mulinella Worker][" + Date.now().toString() + "] ");
        Sys.stderr().writeString(s);
        Sys.stderr().flush();
    }

    public static function serverTrace(v: Dynamic, ?pos: haxe.PosInfos) {
        dumpError(pos.fileName + ":" + Std.string(pos.lineNumber) + ": " + Std.string(v) + "\n");
    }
}
