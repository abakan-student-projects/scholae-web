package service;

import sys.db.Types.SNull;
import model.Job;
import model.Role;
import messages.ResponseMessage;
class JobService {

    public function new() {}

    public function loadResponses(): ResponseMessage {
        return ServiceHelper.authorize(Role.Learner, function() {
            var jobs = Job.manager.search($sessionId == Authorization.instance.session.id && $response != null);
            var result = ServiceHelper.successResponse(
                Lambda.array(
                    Lambda.map(
                        jobs,
                        function(job) {
                            return {
                                id: job.id,
                                response: job.response
                            }
                        }))
            );
            var jobIds = Lambda.array(Lambda.map(jobs, function(job) { return job.id; }));
            Job.manager.delete($id in jobIds);
            return result;
        });
    }
}
