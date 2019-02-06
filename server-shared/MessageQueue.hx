package ;

import sys.io.Process;
import haxe.io.Bytes;

class MessageQueue {
    public static function publish(routingKey: String, exchange: String, payload: Bytes, vhost: String = "/") {
        var scholaeRabbitPath = Sys.getEnv("SCHOLAE_RABBIT_PATH");
        var envArgs: Array<String> = scholaeRabbitPath.split(" : ");
        var processName = if(scholaeRabbitPath != null) envArgs.shift() else "/usr/local/sbin/rabbitmqadmin";
        var args = ["--user=scholae", "--password=scholae", "--vhost="+vhost, "publish", "routing_key="+routingKey, "exchange="+exchange];
        var p = new Process(processName, envArgs.concat(args));
        p.stdin.write(payload);
        p.stdin.close();
        if(p.exitCode(true) != 0) {
            trace(p.stderr.readAll().toString());
        }
    }
}
