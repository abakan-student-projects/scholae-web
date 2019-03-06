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

    public static function getGradeName(grade: Int): String {
        return switch (grade) {
            case 1: "Новичок";
            case 2: "Любитель";
            case 3: "Мастер";
            default: "";
        }
    }

    public static function getIconPathByGrade(grade: Int): String {
        return switch (grade) {
            case 1: "cup-bronze";
            case 2: "cup-silver";
            case 3: "cup-gold";
            default: "cup-gold";
        }
    }
}
