package ;

import sys.io.Process;
import haxe.io.Bytes;

class MessageQueue {
    public static function publish(routingKey: String, exchange: String, payload: Bytes, vhost: String = "/") {
        var args = ["--user=scholae", "--password=scholae", "--vhost="+vhost, "publish", "routing_key="+routingKey, "exchange="+exchange];
        var p = new Process("/usr/local/sbin/rabbitmqadmin", args);
        p.stdin.write(payload);
        p.stdin.close();
        p.exitCode(true);
    }

}
