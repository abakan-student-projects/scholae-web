package service;

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
}
