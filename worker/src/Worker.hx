package ;

import notification.NotificationDestination;
import configuration.AmqpConfig;
import configuration.DatabaseConfig;
import configuration.Configuration;
import configuration.SmtpConfig;
import notification.NotificationType;
import mtwin.mail.Part;
import mtwin.mail.Smtp;
import notification.NotificationStatus;
import model.Notification;
import codeforces.CodeforcesRunner;
import model.User;
import messages.MessagesHelper;
import model.Training;
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
        //trace("Connection is up " + mq);
        channel = mq.channel();
        //trace("Channel:" + channel);
        //channel.bind("jobs_common", "jobs", null);
        channel.consume("jobs_common", onConsume, false);
        trace("On consume is setup");
    }

    public static function getConnectionParams(): ConnectionParameters {
        var params:ConnectionParameters = new ConnectionParameters();
        var config: AmqpConfig = Configuration.instance.getAmqpConfig();
        params.username = config.user;
        params.password = config.password;
        params.vhostpath = config.hostpath;
        params.serverhost = config.host;
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

        var c = delivery.body.readAll().toString();

        trace(c);

        var msg: JobMessage = Unserializer.run(c);

        if (msg != null) {
            trace(EnumValueTools.getName(msg.job));
            switch(msg.job) {
                case UpdateUserResults(userId): {
                    var user: User = User.manager.get(userId);
                    Sys.sleep(0.4);
                    Attempt.updateAttemptsForUser(user);
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.delete();
                    };
                };

                case RefreshResultsForUser(userId): {
                    var user: User = User.manager.get(userId);
                    Sys.sleep(0.4);
                    Attempt.updateAttemptsForUser(user);
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.response = MessagesHelper.successResponse(
                            Lambda.array(
                                Lambda.map(
                                    Training.manager.search($userId == userId && $deleted != true),
                                    function(t) { return t.toMessage(true); })));
                        job.modificationDateTime = Date.now();
                        job.update();
                    };
                };

                case RefreshResultsForGroup(groupId): {
                    for (gl in GroupLearner.manager.search($groupId == groupId)) {
                        Sys.sleep(0.4);
                        Attempt.updateAttemptsForUser(gl.learner);
                    }
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.response = MessagesHelper.successResponse(
                            Lambda.array(
                                Lambda.map(
                                    Training.getTrainingsByGroup(groupId),
                                    function(t) { return t.toMessage(); })));
                        job.modificationDateTime = Date.now();
                        job.update();
                    };
                };

                case UpdateCodeforcesData(cfg): {
                    var codeforcesRunner: CodeforcesRunner = new CodeforcesRunner(cfg);
                    codeforcesRunner.runAll();
                    Sys.sleep(0.4);
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.delete();
                    };
                };

                case SendNotificationToEmail(notificationId): {
                    var notification: Notification = Notification.manager.get(notificationId);
                    var user: User = User.manager.get(notification.user.id);
                    var notificationData: NotificationType = notification.type;
                    var emailMessage: String;
                    var template: haxe.Template;
                    switch(notificationData) {
                        case SimpleMessage(message, type): {
                            template = new haxe.Template(haxe.Resource.getString("SimpleEmailNotification"));
                            emailMessage = template.execute({message: message});
                            sendEmail(user, notification, emailMessage);
                        }
                        case MessageWithLink(message, link, type): {
                            template = new haxe.Template(haxe.Resource.getString("EmailNotificationWithLink"));
                            emailMessage = template.execute({message: message, link: link});
                            sendEmail(user, notification, emailMessage);
                        }
                        default: null;
                    };
                    var job: Job = Job.manager.get(msg.id);
                    if (null != job) {
                        job.delete();
                    };
                };
            }
        }

        sys.db.Manager.cleanup();
        cnx.close();

        Sys.stdout().flush();
        Sys.stderr().flush();

        channel.ack(delivery);
    }

    private function sendEmail(user: User, notification: Notification, emailMessage: String) {
        var subjectForUser ='Scholae: notification';
        var from = Configuration.instance.getEmailNotification();
        var smtpConfig: SmtpConfig = Configuration.instance.getSmtpConfig();
        var email = new Part("multipart/alternative", true, "utf-8");
        email.setHeader("From", from);
        email.setHeader("To", user.email);
        email.setDate();
        email.setHeader("Subject", subjectForUser);
        var emailPart = email.newPart("text/html");
        emailPart.setContent(emailMessage);
        try {
            Smtp.send(
                smtpConfig.host,
                from,
                user.email,
                emailPart.get(),
                smtpConfig.port,
                if (smtpConfig.user != "") smtpConfig.user else null,
                if (smtpConfig.password != "") smtpConfig.password else null
            );
            notification.status = NotificationStatus.Completed;
        } catch (e: Dynamic) {
            trace("SMTP Connection error: " + e);
            notification.status = NotificationStatus.InProgress;
        }
        notification.update();
    }
}
