package services;

import messages.GroupMessage;
import js.Promise;
import messages.SessionMessage;

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
        prepareUrl();
        return new Promise(function(success, fail) {
            context.TeacherService.getAllGroups.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }
}
