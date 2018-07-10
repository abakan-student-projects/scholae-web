package services;

import haxe.remoting.HttpAsyncConnection;
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
}
