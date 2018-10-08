package ;

import messages.ResponseStatus;
import haxe.EnumTools.EnumValueTools;
import model.Job;
import jobs.JobMessage;
import model.Attempt;
import model.GroupLearner;
import haxe.Unserializer;
import jobs.ScholaeJob;
import org.amqp.fast.FastImport.Delivery;
import org.amqp.fast.FastImport.Channel;
import org.amqp.ConnectionParameters;
import org.amqp.fast.neko.AmqpConnection;

class Worker {

    private var mq: AmqpConnection;
    private var channel: Channel;

    public function new() {
        trace("Started");
        mq = new AmqpConnection(getConnectionParams());
        trace("Connection is up " + mq);
        channel = mq.channel();
        trace("Channel:" + channel);
        //channel.bind("jobs_common", "jobs", null);
        channel.consume("jobs_common", onConsume, false);
        trace("On consume is setup");
    }

    public static function getConnectionParams(): ConnectionParameters {
        var params:ConnectionParameters = new ConnectionParameters();
        params.username = "guest";
        params.password = "guest";
        params.vhostpath = "/";
        params.serverhost = "127.0.0.1";
        return params;
    }

    public function run() {
        trace("The loop is running...");
        while(true) {
            mq.deliver(false);
            Sys.sleep(0.0001);
        }
    }

    public function onConsume(delivery: Delivery) {
        var msg: JobMessage = Unserializer.run(delivery.body.readAll().toString());

        if (msg != null) {
            trace(EnumValueTools.getName(msg.job));
            switch(msg.job) {
                case RefreshResultsForGroup(groupId):
                    for (gl in GroupLearner.manager.search($groupId == groupId)) {
                        Attempt.updateAttemptsForUser(gl.learner);
                        Sys.sleep(0.3);
                        var job: Job = Job.manager.get(msg.id);
                        if (null != job) {
                            job.response = { status: ResponseStatus.OK, result: true };
                            job.modificationDateTime = Date.now();
                            job.update();
                        }
                    }
            }
        }
        channel.ack(delivery);
    }
}
