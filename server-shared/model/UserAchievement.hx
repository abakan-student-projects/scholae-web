package model;

import sys.db.Manager;
import sys.db.Types.SBigId;

@:table("UserAchievement")
class UserAchievement extends sys.db.Object {
    public var id: SBigId;
    @:relation(userId) public var user: User;
    @:relation(achievementId) public var achievement: Achievement;

    public function new() {
        super();
    }

    public static var manager = new Manager<UserAchievement>(UserAchievement);

    public static function getUserAchievements(user: User): List<UserAchievement> {
        var achievements: List<UserAchievement> = manager.search($userId == user.id);
        return achievements;
    }

    public static function insertUserAchievement(user: User, achievement: Achievement) {
        var userAchievement = new UserAchievement();
        userAchievement.user = user;
        userAchievement.achievement = achievement;
        userAchievement.insert();
    }
}
