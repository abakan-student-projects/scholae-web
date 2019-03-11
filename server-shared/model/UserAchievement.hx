package model;

import notification.NotificationDestination;
import notification.NotificationStyle;
import notification.NotificationStatus;
import notification.NotificationType;
import achievement.AchievementUtils;
import achievement.AchievementParameters;
import haxe.EnumTools.EnumValueTools;
import haxe.EnumTools;
import achievement.AchievementCategory;
import messages.RatingMessage.RatingCategory;
import achievement.AchievementGrade;
import sys.db.Types.SEnum;
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
        checkUserAchievements(user);
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

    public static function updateUserAchievement(user: User, achievement: Achievement, grade: AchievementGrade) {
        var userAchievement: UserAchievement =
            UserAchievement.manager.select($userId == user.id && $achievementId == achievement.id);
        if (userAchievement != null) {
            userAchievement.grade = grade;
            userAchievement.update();
        }
    }

    public static function isEarned(user: User, achievement: Achievement): Bool {
        if (UserAchievement.manager.count($userId == user.id && $achievementId == achievement.id) == 0) {
            return false;
        } else {
            return true;
        }
    }

    public static function checkUserAchievements(user: User) {
        checkCodeforcesAchievements(user);
        checkRatingAchievements(user);
    }

    public static function checkCodeforcesAchievements(user: User) {
        var achievements: List<Achievement> = Achievement.manager.search($category == AchievementCategory.Codeforces);
        for(achievement in achievements) {
            var achievementsCount = UserAchievement.manager.count($userId == user.id && $achievementId == achievement.id);
            trace(achievementsCount);
            if (achievementsCount == 0) {
                switch(achievement.id) {
                    case 1: {
                        var existsSolvedTask: Bool = if(ModelUtils.getTasksSolvedByUser(user) > 0) true else false;
                        if(existsSolvedTask) {
                            insertUserAchievement(user, achievement, AchievementGrade.NoGrade);
                            sendAchievementNotification(user, achievement.title, achievement.id, AchievementGrade.NoGrade);
                        }
                    } ;
                }
            }
        }
    }

    public static function checkRatingAchievements(user: User){
        var ratings: Array<RatingCategory> = User.calculateRatingCategory(user.id);
        var achievements: List<Achievement> = Achievement.manager.search($category == AchievementCategory.Raiting);
        for (achievement in achievements) {
            var ratingCategoryId: Float = 0;
            if (achievement.parameters != null) {
                switch(achievement.parameters) {
                    case AchievementParameters.RatingCategoryId(id): {
                        ratingCategoryId = id;
                    }
                    default: null;
                }
            }
            var categoryRating: Array<RatingCategory> = ratings.filter(function(it: RatingCategory){return (it.id == ratingCategoryId);});
            var rating: Float = if(categoryRating.length > 0) categoryRating[0].rating else 0;
            var grade: AchievementGrade =
                if(rating > 0 && rating <= 5000) AchievementGrade.Newbie
                else if (rating > 5000 && rating <= 10000) AchievementGrade.Amateur
                else if (rating > 10000) AchievementGrade.Master
                else AchievementGrade.NoGrade;
            if (!isEarned(user, achievement) && grade != AchievementGrade.NoGrade) {
                insertUserAchievement(user, achievement, grade);
                sendAchievementNotification(user,achievement.title, achievement.id, grade);
            } else if (grade != AchievementGrade.NoGrade) {
                updateUserAchievement(user, achievement, grade);
                sendAchievementNotification(user,achievement.title, achievement.id, grade);
            }
        }
    }

    private static function sendAchievementNotification(user: User, message: String, achievementId: Float, grade: AchievementGrade) {
        var template = new haxe.Template(haxe.Resource.getString("AchievementNotification"));
        var notificationMessage = template.execute(
            {
                id: achievementId,
                title: message,
                icon: AchievementUtils.getIconPathByGrade(grade)
            }
        );
        trace(notificationMessage);
        var notification = new Notification();
        notification.user = user;
        notification.type = NotificationType.SimpleMessage(notificationMessage, EnumValueTools.getName(NotificationStyle.success));
        notification.status = NotificationStatus.New;
        notification.date = Date.now();
        notification.primaryDestination = NotificationDestination.Client;
        notification.insert();
    }

    public function toMessage() {
        return
            {
                id: achievement.id,
                title: achievement.title,
                description: achievement.description,
                date: date,
                grade: EnumValueTools.getIndex(grade),
                category: EnumValueTools.getIndex(achievement.category)
            };
    }
}
