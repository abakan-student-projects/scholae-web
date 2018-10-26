package service;

import model.User;
import model.CodeforcesTaskTag;
import model.CodeforcesTag;
import messages.TagMessage;
import model.CodeforcesTask;
import messages.ResponseMessage;
import model.Assignment;
import model.Attempt;
import model.Group;
import model.GroupLearner;
import model.ModelUtils;
import model.Role;
import model.Training;

using Lambda;

class EditorService {

    public function new() {}

    private function authorize(next: Void -> ResponseMessage): ResponseMessage {
        return ServiceHelper.authorize(Role.Editor, next);
    }

    public function getTags(): ResponseMessage {
        return authorize(function() {
            return ServiceHelper.successResponse(Lambda.array(CodeforcesTask.manager.all()));
        });
    }

    public function insertTag(tagMessage: TagMessage): ResponseMessage {
        return authorize(function() {
            if (CodeforcesTag.manager.count($name == tagMessage.name) > 0) {
                return ServiceHelper.failResponse("Тег " + tagMessage.name + " уже существует.");
            }
            var tag = new CodeforcesTag();
            tag.name = tagMessage.name;
            tag.russianName = tagMessage.russianName;
            tag.insert();

            return ServiceHelper.successResponse(tag.toMessage());
        });
    }

    public function updateTag(tagMessage: TagMessage): ResponseMessage {
        return authorize(function() {
            var tag: CodeforcesTag = CodeforcesTag.manager.get(tagMessage.id);
            if (tag != null) {
                tag.name = tagMessage.name;
                tag.russianName = tagMessage.russianName;
                tag.update();
                return ServiceHelper.successResponse(tag.toMessage());
            } else {
                return ServiceHelper.failResponse("Тег id=" + tagMessage.id + " не существует.");
            }
        });
    }

    public function getTasks(filter: String, offset: Int, limit: Int): ResponseMessage {
        return authorize(function() {
            var tasksCount = CodeforcesTask.manager.count($name.like("%"+filter+"%"));
            var tasks = CodeforcesTask.manager.search($name.like("%"+filter+"%"), {orderBy: name, limit: [offset, limit]});
            var messages =
                tasks
                    .map(function(t) { return t.toMessage(); })
                    .array();
            return ServiceHelper.successResponse({
                data: messages,
                offset: offset,
                totalLength: tasksCount
            });
        });
    }

    public function getAllUsers(): ResponseMessage {
        return ServiceHelper.successResponse(
            Lambda.array(
                Lambda.map(
                    User.manager.all(),
                    function(u) { return u.toLearnerMessage(); }))
        );
    }

    public function updateTaskTags(taskId: Float, tagIds: Array<Float>): ResponseMessage {
        return authorize(function() {
            var task: CodeforcesTask = CodeforcesTask.manager.get(taskId);
            if (task != null) {
                CodeforcesTaskTag.manager.delete($taskId == task.id);
                for (tagId in tagIds) {
                    var tag = CodeforcesTag.manager.get(tagId);
                    if (null != tag) {
                        var relation = new CodeforcesTaskTag();
                        relation.task = task;
                        relation.tag = tag;
                        relation.insert();
                    }
                }
                return ServiceHelper.successResponse(task.toMessage());
            } else {
                return ServiceHelper.failResponse("Задача id=" + taskId + " не существует.");
            }
        });
    }
}
