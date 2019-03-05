package achievement;

class AchievementUtils {

    public function new() {
    }

    public static function getCategoryName(index: Int): String {
        return switch (index) {
            case 0: "Общие";
            case 1: "Рейтинг";
            case 2: "Codeforces";
            case 3: "Тренировки";
            default: "";
        }
    }
}
