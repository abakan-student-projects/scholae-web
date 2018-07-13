package utils;

class TimerHelper {
    public static function defer(f: Void->Void) {
        haxe.Timer.delay(f, 10);
    }
}
