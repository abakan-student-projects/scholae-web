package model;

import messages.ProfileMessage;
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
    public var activationDate: SDateTime;
    public var emailActivationCode: SString<128>;
    public var emailActivated: SBool;
    public var lastResultsUpdateDate: SDateTime;

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

    public function toProfileMessage(): ProfileMessage {
        return
            {
                userId: id,
                email: email,
                firstName: firstName,
                lastName: lastName,
                codeforcesHandle: codeforcesHandle,
                emailActivated: emailActivated
            };
    }

    public function toRatingMessage(userId: Float, ?startDate: Date, ?finishDate: Date): RatingMessage {
        var learner = manager.select($id == userId);
        return
        {
            rating: if (startDate != null && finishDate != null) 0 else calculateLearnerRating(userId),
            ratingCategory: if (startDate != null && finishDate != null) [] else calculateRatingCategory(userId),
            learner: learner.toLearnerMessage(),
            ratingDate: if (startDate != null && finishDate != null) calculateLearnerRatingsForUsers(userId, startDate, finishDate) else [],
            solvedTasks: if (startDate != null && finishDate != null) getSolvedTasks(userId, startDate, finishDate) else null,
            ratingByPeriod: if (startDate != null && finishDate != null) getRatingByPeriod(userId, startDate,finishDate) else null
        };
    }

    public static function getSolvedTasks(userId: Float, startDate: Date, finishDate: Date): Float {
        var attempts = [for (a in Attempt.manager.search(($userId == userId) && ($solved == true) && ($datetime >= startDate) && ($datetime <= finishDate))) a];
        var solvedTasks = 0;
        for (a in attempts) {
            if (a.task != null) {
                solvedTasks ++;
            }
        }
        return solvedTasks;
    }

    public static function getRatingByPeriod(userId: Float, startDate: Date, finishDate: Date): Float {
        var allRatingsForUser: Array<RatingDate> = calculateLearnerRatingsForUsers(userId, startDate, finishDate);
        var startRating = allRatingsForUser.shift();
        var finishRating = allRatingsForUser.pop();
        var result = finishRating.rating - startRating.rating;
        return result;
    }

    public static function calculateLearnerRatingsForUsers(userId: Float, startDate: Date, finishDate: Date) : Array<RatingDate> {
        var attempts = [for (a in Attempt.manager.search(($userId == userId) && ($solved == true))) a].filter(function(a) { return a.task != null; });
        ArraySort.sort(attempts, function(x:Attempt, y: Attempt) { var x2 = ((x.datetime.getFullYear() - 2010 - 1) * 12 + x.datetime.getMonth()) * 31 + x.datetime.getDate();
                                                                    var y2 = ((y.datetime.getFullYear() - 2010 - 1) * 12 + y.datetime.getMonth()) * 31 + y.datetime.getDate();
                                                                    return if (x2 > y2) 1 else -1;});

        var ratingData: Array<RatingDate> = [];
        var rating = 0;
        var prevData: Attempt = null;
        var prevRating = 0;
        var i = 1;
        var length = attempts.length;
        for (a in attempts) {
            if (a.task != null) {
                if(i == 1) {
                    prevData = a;
                    prevRating = a.task.level;
                } else {
                    if (prevData.datetime.getDate() == a.datetime.getDate() && prevData.datetime.getMonth() == a.datetime.getMonth() && prevData.datetime.getFullYear() == a.datetime.getFullYear()) {
                        if (i == length) {
                            ratingData.push({id: a.user.id, rating: Math.round(Math.log(a.task.level + prevRating)*1000), date: a.datetime});
                        } else {
                            prevData = a;
                            prevRating += a.task.level;
                        }
                    } else {
                        if (i == length) {
                            ratingData.push({id: a.user.id, rating:Math.round(Math.log(prevRating)*1000), date: prevData.datetime});
                            ratingData.push({id: a.user.id, rating: Math.round(Math.log(prevRating+a.task.level)*1000), date: a.datetime});
                        } else {
                            ratingData.push({id: a.user.id, rating:Math.round(Math.log(prevRating)*1000), date: prevData.datetime});
                            prevData = a;
                            prevRating += a.task.level;
                        }
                    }
                }
            }
            i++;
        }
        var result: Array<RatingDate> = [];
        var prevResult: RatingDate = null;
        var startD = ((startDate.getFullYear() - 2010 - 1) * 12 + startDate.getMonth()) * 31 + startDate.getDate() + 1;
        var endDate = ((finishDate.getFullYear() - 2010 - 1) * 12 + finishDate.getMonth()) * 31 + finishDate.getDate();
        var prevDay = null;
        i = 1;
        if (ratingData.length == 0) {
            result.push({id: userId, date: startDate, rating:0});
        } else {
            for (r in ratingData) {
                var day = ((r.date.getFullYear() - 2010 - 1) * 12 + r.date.getMonth()) * 31 + r.date.getDate();
                if (i == 1) {
                    prevResult = r;
                } else {
                    var prevDay = ((prevResult.date.getFullYear() - 2010 - 1) * 12 + prevResult.date.getMonth()) * 31 + prevResult.date.getDate();

                    if (result.length == 0 && day != startD) {
                        if (prevDay == startD) {
                            result.push(prevResult);
                            if (i == ratingData.length && day <= endDate) {
                                result.push(r);
                            }
                        } else if (prevDay > startD){
                            result.push({id: prevResult.id, date: startDate, rating: 0});
                            result.push(prevResult);
                            if (i == ratingData.length && day <= endDate) {
                                result.push(r);
                            }
                        } else if (prevDay < startD && day > startD) {
                            result.push({id: prevResult.id, date: startDate, rating: prevResult.rating});
                            if (i == ratingData.length && day <= endDate) {
                                result.push(r);
                            }
                        } else if (i == ratingData.length && day < endDate) {
                            result.push({id: r.id, date: startDate, rating: r.rating});
                        }
                        prevResult = r;
                    } else {
                        if (prevDay >= startD && prevDay <= endDate) {
                            result.push(prevResult);
                            prevResult = r;
                            if (i == ratingData.length && day >= startD && day <= endDate) {
                                result.push(r);
                            }
                        } else if (day >=startD && day <= endDate)
                        {
                            result.push(r);
                            prevResult = r;

                        } else break;
                    }
                }
                i++;
            }
        }
        if (result.length != 0) {
            var lastElement = result.pop();
            var day = ((lastElement.date.getFullYear() - 2010 - 1) * 12 + lastElement.date.getMonth()) * 31 + lastElement.date.getDate();
            if (day == endDate) {
                result.push(lastElement);
            } else if (day < endDate) {
                result.push(lastElement);
                result.push({id: lastElement.id, date: finishDate, rating: lastElement.rating});
            }
        }
        return result;
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
