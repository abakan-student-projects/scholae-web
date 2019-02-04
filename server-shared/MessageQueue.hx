package ;

import sys.io.Process;
import haxe.io.Bytes;

class MessageQueue {
    public static function publish(routingKey: String, exchange: String, payload: Bytes, vhost: String = "/") {
        var rabbit_path_args = Sys.getEnv("SCHOLAE_RABBIT_PATH");
        var processName = if(rabbit_path_args != null) "python.exe"
            else "/usr/local/sbin/rabbitmqadmin";
        var args = [rabbit_path_args,"--user=scholae", "--password=scholae", "--vhost="+vhost, "publish", "routing_key="+routingKey, "exchange="+exchange];
        var p = new Process(processName, args);
        p.stdin.write(payload);
        p.stdin.close();
        if(p.exitCode(true) != 0) {
            trace(p.stderr.readAll().toString());
        }
    }
}
