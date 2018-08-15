package services;

import messages.TagMessage;
import js.Promise;
import messages.GroupMessage;
import messages.TrainingMessage;

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
}
