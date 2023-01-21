package ;

import configuration.DatabaseConfig;
import configuration.Configuration;
import service.NotificationService;
import service.JobService;
import service.EditorService;
import service.LearnerService;
import service.TeacherService;
import haxe.remoting.HttpConnection;
import service.AuthService;
import haxe.remoting.Context;

class Main {
    public static function main() {

        haxe.Log.trace = serverTrace;

        var context = new Context();
        context.addObject("AuthService", new AuthService());
        context.addObject("TeacherService", new TeacherService());
        context.addObject("LearnerService", new LearnerService());
        context.addObject("EditorService", new EditorService());
        context.addObject("JobService", new JobService());
        context.addObject("NotificationService", new NotificationService());

        var config: DatabaseConfig = Configuration.instance.getDatabaseConfig();

        var cnx = sys.db.Mysql.connect({
            host : config.host,
            port : null,
            user : config.user,
            pass : config.password,
            database : config.name,
            socket : null,
        });
        cnx.request("SET NAMES 'utf8';");

        sys.db.Manager.cnx = cnx;
        sys.db.Manager.initialize();

        if (HttpConnection.handleRequest(context)) {
            return;
        } else {
            php.Lib.print("This is a remoting server !");
        }

        sys.db.Manager.cleanup();
        cnx.close();
    }

    static function dumpError(s: String) {
        Sys.stderr().writeString("[Scholae][" + Date.now().toString() + "] ");
        Sys.stderr().writeString(s);
        Sys.stderr().flush();
    }

    public static function serverTrace(v: Dynamic, ?pos: haxe.PosInfos) {
        dumpError(pos.fileName + ":" + Std.string(pos.lineNumber) + ": " + Std.string(v) + "\n");
    }
}
