package achievement;

class AchievementUtils {

    public function new() {
    }

    public static function getCategoryName(index: Int): String {
        return switch (index) {
            case 0: "Общие";
            case 1: "Codeforces";
            case 2: "Тренировки";
            case 3: "Рейтинг";
            default: "";
        }
    }

    public static function getGradeName(grade: AchievementGrade): String{
        return switch (grade) {
            case AchievementGrade.Newbie: "cup-bronze";
            case AchievementGrade.Amateur: "cup-silver";
            case AchievementGrade.Master: "cup-gold";
            default: "cup-gold";
        }
    }

    public static function getIconPathByGrade(grade: AchievementGrade): String{
        return switch (grade) {
            case AchievementGrade.Newbie: "cup-bronze";
            case AchievementGrade.Amateur: "cup-silver";
            case AchievementGrade.Master: "cup-gold";
            default: "cup-gold";
        }
    }
}
