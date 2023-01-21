package services;

import Array;
import messages.RatingMessage;
import model.TeacherState;
import messages.ArrayChunk;
import messages.TaskMessage;
import messages.MetaTrainingMessage;
import messages.AttemptMessage;
import messages.TrainingMessage;
import messages.AssignmentMessage;
import messages.TagMessage;
import messages.LearnerMessage;
import messages.GroupMessage;
import js.Promise;
import messages.SessionMessage;
import messages.LinksForTagsMessage;

class TeacherServiceClient extends BaseServiceClient {

    private static var _instance: TeacherServiceClient;
    public static var instance(get, null): TeacherServiceClient;
    private static function get_instance(): TeacherServiceClient {
        if (null == _instance) _instance = new TeacherServiceClient();
        return _instance;
    }

    public function new() {
        super();
    }

    public function getAllGroups(): Promise<Array<GroupMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getAllGroups.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getAllTags(): Promise<Array<TagMessage>> {
        return basicRequest(context.TeacherService.getAllTags, []);
    }

    public function getAllLinks(): Promise<Array<LinksForTagsMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getAllLinks.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getAllRating(groupId: Float): Promise<Array<RatingMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getAllRating.call([groupId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getAllLearnersByGroup(groupId: Float): Promise<Array<LearnerMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getAllLearnersByGroup.call([groupId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function addGroup(name: String, signUpKey: String): Promise<GroupMessage> {
        return request(function(success, fail) {
            context.TeacherService.addGroup.call([name, signUpKey], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function createAssignment(group: GroupMessage, assignment: AssignmentMessage): Promise<AssignmentMessage> {
        return request(function(success, fail) {
            context.TeacherService.createAssignment.call([group, assignment], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function createAdaptiveAssignment(group: GroupMessage, name: String, startDate: Date, finishDate: Date, tasksCount: Int, learnerIds: Array<Float>): Promise<AssignmentMessage> {
        return request(function(success, fail) {
            context.TeacherService.createAdaptiveAssignment.call([group, name, startDate, finishDate, tasksCount, learnerIds], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getAssignmentsByGroup(groupId: Float): Promise<Array<AssignmentMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getAssignmentsByGroup.call([groupId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function createTrainingsByMetaTrainings(groupId: Float): Promise<Array<AssignmentMessage>> {
        return request(function(success, fail) {
            context.TeacherService.createTrainingsByMetaTrainings.call([groupId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getTrainingsByGroup(groupId: Float): Promise<Array<TrainingMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getTrainingsByGroup.call([groupId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function refreshResultsForGroup(groupId: Float): Promise<Array<TrainingMessage>> {
        return request(function(success, fail) {
            context.TeacherService.refreshResultsForGroup.call([groupId], function(e) {
                processAsyncJobResponse(e, success, fail);
            });
        });
    }

    public function getLastAttemptsForTeacher(length: Int): Promise<Array<AttemptMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getLastAttemptsForTeacher.call([length], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getAllTasksByMetaTraining(metaTraining: MetaTrainingMessage, filter: String): Promise<ArrayChunk<TaskMessage>> {
        return request(function(success, fail) {
            context.TeacherService.getAllTasksByMetaTraining.call([metaTraining, filter], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function deleteLearner(learnerId: Float, groupId: Float): Promise<Float> {
        return request(function(success, fail) {
            context.TeacherService.deleteLearner.call([learnerId,groupId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function deleteCourse(groupId: Float): Promise<Float> {
        return request(function(success, fail) {
            context.TeacherService.deleteCourse.call([groupId], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getRatingsForUsers(userIds: Array<Float>, startDate: Date, finishDate: Date): Promise<Array<RatingMessage>> {
        return request(function(success,fail) {
            context.TeacherService.getRatingsForUsers.call([userIds, startDate, finishDate], function(e) {
                processResponse(e, success, fail);
            });
        });
    }
}
