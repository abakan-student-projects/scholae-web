package jobs;

import model.Job;
import MessageQueue;
import haxe.Serializer;
import haxe.io.Bytes;

class JobQueue {
    public static function publishScholaeJob(job: ScholaeJob, sessionId: String): Float {
        var jobModel = new Job();
        jobModel.sessionId  = sessionId;
        jobModel.request = job;
        jobModel.progress = 0.0;
        jobModel.creationDateTime = Date.now();
        jobModel.modificationDateTime = jobModel.creationDateTime;
        jobModel.insert();

        MessageQueue.publish("common", "jobs", Bytes.ofString(Serializer.run({
                id: jobModel.id,
                job: job
            })));

        return jobModel.id;
    }
}
