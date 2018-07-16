package utils;

typedef UIkitNotificationArgs =  {
    message: String,
    ?status: String,
    ?pos: String,
    ?timeout: Int
}

@:native("UIkit") extern class UIkit {
    public static function notification(args: UIkitNotificationArgs): Void;
}
