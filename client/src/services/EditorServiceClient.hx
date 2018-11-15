package services;

import messages.ArrayChunk;
import messages.TaskMessage;
import messages.TagMessage;
import js.Promise;
import messages.GroupMessage;
import messages.TrainingMessage;
import messages.LinksForTagsMessage;

class EditorServiceClient extends BaseServiceClient {

    private static var _instance: EditorServiceClient;
    public static var instance(get, null): EditorServiceClient;
    private static function get_instance(): EditorServiceClient {
        if (null == _instance) _instance = new EditorServiceClient();
        return _instance;
    }

    public function new() {
        super();
    }

    public function updateTag(tag: TagMessage): Promise<TagMessage> {
        return request(function(success, fail) {
            context.EditorService.updateTag.call([tag], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function insertTag(tag: TagMessage): Promise<TagMessage> {
        return request(function(success, fail) {
            context.EditorService.insertTag.call([tag], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function updateLink(link: LinksForTagsMessage): Promise<LinksForTagsMessage> {
        return request(function(success, fail) {
            context.EditorService.updateLink.call([link], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function insertLink(link: LinksForTagsMessage): Promise<LinksForTagsMessage> {
        return request(function(success, fail) {
            context.EditorService.insertLink.call([link], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function deleteLink(link: LinksForTagsMessage): Promise<LinksForTagsMessage> {
        return request(function(success, fail) {
            context.EditorService.deleteLink.call([link], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function getTasks(filter: String, offset: Int, limit: Int): Promise<ArrayChunk<TaskMessage>> {
        return request(function(success, fail) {
            context.EditorService.getTasks.call([filter, offset, limit], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function updateTaskTags(taskId: Float, tagIds: Array<Float>): Promise<TaskMessage> {
        return request(function(success, fail) {
            context.EditorService.updateTaskTags.call([taskId, tagIds], function(e) {
                processResponse(e, success, fail);
            });
        });
    }
}
