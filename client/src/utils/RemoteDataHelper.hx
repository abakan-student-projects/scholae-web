package utils;

import redux.Redux.Action;
import utils.TimerHelper.defer;

class RemoteDataHelper {
    public static function shouldInitiate<T>(d: RemoteData<T>) { return !d.loaded && !d.loading; }
    public static function createEmpty<T>(): RemoteData<T> { return { data: null, loaded: false, loading: false }; }
    public static function createLoading<T>(): RemoteData<T> { return { data: null, loaded: false, loading: true }; }
    public static function createLoaded<T>(data: T): RemoteData<T> { return { data: data, loaded: true, loading: false }; }
    public static function dataOrEmptyArray<T>(d: RemoteData<T>): Dynamic {
        return if (null != d && d.loaded) d.data else [];
    }

    public static function ensureRemoteDataLoaded<T>(data: RemoteData<T>, action: Action, ?next: Void -> Void) {
        if (shouldInitiate(data)) {
            defer(function() {
                Main.store.dispatch(action);
            });
        } else {
            if (null != next) next();
        }
    }
}
