package ;

import sys.io.Process;
import haxe.io.Bytes;

class MessageQueue {
    public static function publish(routingKey: String, exchange: String, payload: Bytes, vhost: String = "/") {
        var scholaeRabbitPath = Sys.getEnv("SCHOLAE_RABBIT_PATH");
        var envArgs: Array<String> = if(null != scholaeRabbitPath) scholaeRabbitPath.split(" : ") else [];
        var processName = if(scholaeRabbitPath != null) envArgs.shift() else "/usr/local/sbin/rabbitmqadmin";
        var args = envArgs.concat(["--user=scholae", "--password=scholae", "--vhost="+vhost, "publish", "routing_key="+routingKey, "exchange="+exchange]);
//        trace(processName + " " + args);
        var p = new Process(processName, args);
        p.stdin.write(payload);
        p.stdin.close();
        if(p.exitCode(true) != 0) {
            trace(p.stderr.readAll().toString());
        }
    }
}
