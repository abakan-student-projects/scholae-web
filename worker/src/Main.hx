package ;

class Main {
    public static function main() {

        haxe.Log.trace = serverTrace;

        var cnx = sys.db.Mysql.connect({
            host : "127.0.0.1",
            port : null,
            user : "scholae",
            pass : "scholae",
            database : "scholae",
            socket : null,
        });
        cnx.request("SET NAMES 'utf8';");

        sys.db.Manager.cnx = cnx;
        sys.db.Manager.initialize();


        new Worker().run();


        sys.db.Manager.cleanup();
        cnx.close();
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
