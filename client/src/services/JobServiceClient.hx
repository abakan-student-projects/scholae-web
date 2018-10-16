package services;

import haxe.ds.StringMap;
import messages.JobResponseMessage;
import js.Promise;

class JobServiceClient extends BaseServiceClient {

    private var callbacks: StringMap<Dynamic -> Void>;

    private static var _instance: JobServiceClient;
    public static var instance(get, null): JobServiceClient;
    private static function get_instance(): JobServiceClient {
        if (null == _instance) _instance = new JobServiceClient();
        return _instance;
    }

    public function new() {
        super();
        callbacks = new StringMap<Dynamic -> Void>();
    }

    public function waitForResponse(id: Float, callback: Dynamic -> Void) {
        callbacks.set(Std.string(id), callback);
        planServerRequestOrStop();
    }

    public function planServerRequestOrStop() {
        if (Lambda.count(callbacks) > 0) {
            haxe.Timer.delay(loadResponses, 3000);
        }
    }

    public function loadResponses(): Promise<Bool> {
        return request(function(success, fail) {
            context.JobService.loadResponses.call([], function(e) {
                processResponse(e,
                    function(responses: Array<JobResponseMessage>) {
                        for (r in responses) {
                            var id = Std.string(r.id);
                            if(callbacks.exists(id)) {
                                processResponse(r.response, callbacks.get(id), fail);
                                callbacks.remove(id);
                            }
                        }
                        planServerRequestOrStop();
                    }, fail);
            });
        });
    }
}
