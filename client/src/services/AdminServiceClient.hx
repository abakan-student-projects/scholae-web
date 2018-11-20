package services;

import messages.AdminMessage;
import js.Promise;

class AdminServiceClient extends BaseServiceClient {

    private static var _instance: AdminServiceClient;
    public static var instance(get, null): AdminServiceClient;
    private static function get_instance(): AdminServiceClient {
        if (null == _instance) _instance = new AdminServiceClient();
        return _instance;
    }

    public function new() {
        super();
    }


    public function getAllUsers(): Promise<Array<AdminMessage>> {
        return request(function(success, fail) {
            context.EditorService.getAllUsers.call([], function(e) {
                processResponse(e, success, fail);
            });
        });
    }

    public function UpdateRoleUsers(user: AdminMessage): Promise<AdminMessage> {
        return request(function(success, fail) {
            context.EditorService.updateRole.call([user], function(e) {
                processResponse(e, success, fail);
            });
        });
    }
}
