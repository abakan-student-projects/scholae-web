package utils;

class RemoteDataHelper {
    public static function shouldInitiate<T>(d: RemoteData<T>) { return !d.loaded && !d.loading; }
    public static function createEmpty<T>(): RemoteData<T> { return { data: null, loaded: false, loading: false }; }
}
