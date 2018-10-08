package ;

import sys.io.Process;
import haxe.io.Bytes;

class MessageQueue {
    public static function publish(routingKey: String, exchange: String, payload: Bytes) {
        var p = new Process("/usr/local/sbin/rabbitmqadmin", ["publish", "routing_key="+routingKey, "exchange="+exchange]);
        p.stdin.write(payload);
        p.stdin.close();
        p.exitCode(true);
    }

}
