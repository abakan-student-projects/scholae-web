package utils;

class DateUtils {

    private static var months = [
        "января",
        "февраля",
        "марта",
        "апреля",
        "мая",
        "июня",
        "июля",
        "августа",
        "сентября",
        "октября",
        "ноября",
        "декабря"
    ];

    public static function toString(date: Date): String {
        if (date == null) return "";
        return
            ((date.getDate() < 10) ? "0" : "") + Std.string(date.getDate()) + " " +
            months[date.getMonth()] + " " +
            Std.string(date.getFullYear());
    }

    public static function toStringWithTime(date: Date): String {
        if (date == null) return "";
        return toString(date) + " " + Std.string(date.getHours()) +
        ":" + ((date.getMinutes() < 10) ? "0" : "") + Std.string(date.getMinutes());
    }
}
