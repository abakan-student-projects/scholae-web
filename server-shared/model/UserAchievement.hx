package model;

import achievement.AchievementGrade;
import sys.db.Types.SEnum;
import haxe.EnumTools.EnumValueTools;
import sys.db.Types.SDateTime;
import sys.db.Manager;
import sys.db.Types.SBigId;

@:table("UserAchievement")
class UserAchievement extends sys.db.Object {
    public var id: SBigId;
    @:relation(userId) public var user: User;
    @:relation(achievementId) public var achievement: Achievement;
    public var date: SDateTime;
    public var grade: SEnum<AchievementGrade>;

    public function new() {
        super();
    }

    public static var manager = new Manager<UserAchievement>(UserAchievement);

    public static function getUserAchievements(user: User): List<UserAchievement> {
        var achievements: List<UserAchievement> = manager.search($userId == user.id);
        return achievements;
    }

    public static function insertUserAchievement(user: User, achievement: Achievement, grade: AchievementGrade) {
        var userAchievement = new UserAchievement();
        userAchievement.user = user;
        userAchievement.achievement = achievement;
        userAchievement.date = Date.now();
        userAchievement.grade = grade;
        userAchievement.insert();
    }

    public function toMessage() {
        return
            {
                id: id,
                title: achievement.title,
                description: achievement.description,
                date: date,
                grade: EnumValueTools.getIndex(grade),
                category: achievement.category
            };
    }
}
