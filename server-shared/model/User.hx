package model;

import Std;
import messages.AttemptMessage;
import haxe.ds.ArraySort;
import DateTools;
import Array;
import messages.TagMessage;
import messages.RatingMessage;
import messages.UserMessage;
import messages.SessionMessage;
import messages.LearnerMessage;
import haxe.crypto.Md5;
import sys.db.Manager;
import sys.db.Types;


@:table("users")
class User extends sys.db.Object {
    public var id: SBigId;
    public var email: SString<512>;
    public var firstName: SString<128>;
    public var lastName: SString<128>;
    public var passwordHash: SString<128>;
    public var roles: SFlags<Role>;
    public var codeforcesHandle: SString<512>;
    public var lastCodeforcesSubmissionId: Float;
    public var registrationDate: SDateTime;
    public var emailActivationCode: SString<128>;
    public var emailActivated: SBool;

    public function new() {
        super();
        roles.set(Role.Learner);
    }

    public static var manager = new Manager<User>(User);

    public static function getUserByEmailAndPassword(email: String, password: String) {
        var users = manager.search( {
            email: email,
            passwordHash: Md5.encode(password)
        });
        return if (users.length > 0) users.first() else null;
    }

    public function toLearnerMessage(): LearnerMessage {
        return
            {
                id: id,
                email: email,
                firstName: firstName,
                lastName: lastName
            };
    }

    public function toUserMessage(): UserMessage {
        return
        {
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            roles: roles,
            codeforcesHandle: codeforcesHandle
        }
    }

    public function toSessionMessage(sessionId: String): SessionMessage {
        return
            {
                userId: id,
                email: email,
                firstName: firstName,
                lastName: lastName,
                roles: roles,
                sessionId: sessionId
            };
    }
    public function toRatingMessage(userId: Float, ?startDate: Date, ?endDate: Date): RatingMessage {
        var learner = manager.select($id == userId);
        return
        {
            rating: if (startDate != null && endDate != null) 0 else calculateLearnerRating(userId),
            ratingCategory: if (startDate != null && endDate != null) [] else calculateRatingCategory(userId),
            learner: learner.toLearnerMessage(),
            ratingDate: if (startDate != null && endDate != null) calculateLearnerRatingForLine(userId, startDate, endDate) else []
        };
    }

    public static function calculateLearnerRatingForLine(userId: Float, startDate: Date, endDate: Date) : Array<RatingDate> {
        var rating:Float = 0;
        var ratingDate: Array<RatingDate> = [];
        var prevDay: Date = Date.fromString("01.01.2000");
        var ratingDate2: Array<RatingDate> = [];
        var prevData:RatingDate = null;
        var i = 1;
        var j = 1;
        var results = Attempt.manager.search(($userId == userId) && ($solved == true) && ($datetime >= startDate && $datetime <= endDate));
        var res = [for (r in results) r];
        ArraySort.sort(res, function(x: Attempt, y:Attempt) { return if (DateTools.format(x.datetime,"%d.%m.%Y") > DateTools.format(y.datetime,"%d.%m.%Y")) 1 else -1; });

        for (item in res) {
            if (item.task != null){
                var prevDayString = prevDay.toString().split(" ");
                var dateTime = Std.string(item.datetime).split(" ");
                if (prevDayString[0] == dateTime[0]){
                    rating += item.task.level;
                } else {
                    rating = 0;
                }
                rating += item.task.level;
                rating = Math.log(rating) * 1000;
                rating = Math.round(rating);
                ratingDate.push({ id: item.user.id, rating: rating, date: item.datetime });
                prevDay = item.datetime;
            }
        }
        var length = ratingDate.length;
        for (r in ratingDate) {
            if (length == 1) {
                ratingDate2.push(r);
            } else {
                if (i == 1) {
                    prevData = r;
                    i = 2;
                } else {
                    if (DateTools.format(prevData.date,"%d.%m.%Y") != DateTools.format(r.date,"%d.%m.%Y")) {
                        if (j == length) {
                            ratingDate2.push(prevData);
                            ratingDate2.push(r);
                        } else {
                            ratingDate2.push(prevData);
                            prevData = r;
                        }
                    } else {
                        if (j == length) {
                            ratingDate2.push(r);
                        } else {
                            prevData = r;
                        }
                    }
                }
                j++;
            }
        }
        return ratingDate2;
    }

   public static function calculateLearnerRating(userId: Float): Float {
       var rating:Float = 0;
       var results = Attempt.manager.search(($userId == userId) && ($solved == true));
       for (item in results) {
           if (item.task != null){
               rating += item.task.level;
           }
       }
       rating = Math.log(rating) * 1000;
       return Math.round(rating);
   }

    public static function calculateRatingCategory(userId: Float): Array<RatingCategory> {
        var rating: Float = 0;
        var res: Array<RatingCategory> = [];
        var attempts = Attempt.manager.search(($userId == userId) && ($solved == true));
        var tagIds = CodeforcesTag.manager.all();
        var taskIds = [];
        for (a in attempts) {
            if (a.task != null){
                taskIds.push(a.task.id);
            }
        }
        var taskTagIds = CodeforcesTaskTag.manager.search($taskId in taskIds);
        for (t in tagIds) {
            for (taskTag in taskTagIds) {
                if (taskTag.tag.id == t.id) {
                    rating += taskTag.task.level;
                }
            }
            if (rating != 0) {
                rating = Math.log(rating) * 1000;
                res.push({id: t.id, rating: Math.round(rating)});
                rating = 0;
            } else {
                res.push({id: t.id, rating: rating});
            }
        }
        return res;
    }
}
