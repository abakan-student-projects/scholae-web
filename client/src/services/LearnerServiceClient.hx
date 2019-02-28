package services;

import achievement.AchievementMessage;
import messages.RatingMessage;
import messages.TrainingMessage;
import js.Promise;
import messages.GroupMessage;
import messages.LearnerMessage;

class LearnerServiceClient extends BaseServiceClient {

    private static var _instance: LearnerServiceClient;
    public static var instance(get, null): LearnerServiceClient;
    private static function get_instance(): LearnerServiceClient {
        if (null == _instance) _instance = new LearnerServiceClient();
        return _instance;
    }

    public function new() {
        super();
    }

    public function signUp(key: String): Promise<GroupMessage> {
        return request(function(success, fail) {
            context.LearnerService.signUp.call([key], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getMyTrainings(): Promise<Array<TrainingMessage>> {
        return request(function(success, fail) {
            context.LearnerService.getMyTrainings.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function refreshResults(): Promise<Array<TrainingMessage>> {
        return request(function(success, fail) {
            context.LearnerService.refreshResults.call([], function(e) {
                processAsyncJobResponse(e, success, fail);
            });
        });
    }

    public function getRating(learnerId : Float): Promise<Array<RatingMessage>> {
        return request(function(success, fail) {
            context.LearnerService.getRating.call([learnerId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getAchievements(): Promise<Array<AchievementMessage>> {
        return request(function(success, fail) {
            context.LearnerService.getAchievements.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }
}
