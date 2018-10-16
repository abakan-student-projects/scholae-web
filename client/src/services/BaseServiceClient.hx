package services;

import messages.ResponseStatus;
import messages.ResponseMessage;
import haxe.remoting.HttpAsyncConnection;
import haxe.remoting.AsyncConnection;
import js.Promise;

class BaseServiceClient {

    private var url(default, set): String;

    private function set_url(v: String): String {
        url = v;
        context = haxe.remoting.HttpAsyncConnection.urlConnect(v);
        context.setErrorHandler(onError);
        return v;
    }

    private var context: HttpAsyncConnection;

    private function prepareUrl(): String { return Configuration.remotingUrl + "?sid=" + Session.sessionId;  }

    private function onError(err: Dynamic) {
        #if debug
		trace("Error : " + Std.string(err));
		#end
    }

    public function new() {
        context = haxe.remoting.HttpAsyncConnection.urlConnect(Configuration.remotingUrl);
        context.setErrorHandler(onError);
    }

    private function processResponse<T>(response: ResponseMessage, success: T -> Void, fail: Dynamic -> Void) {
        switch(response.status) {
            case ResponseStatus.OK: success(response.result);
            case ResponseStatus.Error: fail(response.message);
        }
    }

    private function processAsyncJobResponse<T>(response: ResponseMessage, success: T -> Void, fail: Dynamic -> Void) {
        switch(response.status) {
            case ResponseStatus.OK: JobServiceClient.instance.waitForResponse(response.result, success);
            case ResponseStatus.Error: fail(response.message);
        }
    }

    private function request<T>(process: (T -> Void) -> (Dynamic -> Void) -> Void): Promise<T> {
        url = prepareUrl();
        return new Promise(process);
    }

    private function basicRequest<T>(connection: AsyncConnection, args: Array<Dynamic>): Promise<T> {
        return
            request(function(success, fail) {
                connection.call(args, function(e) {
                processResponse(e, success, fail);
            });
        });
    }
}
