package model;

import messages.ProfileMessage;
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

    public function toRatingMessage(userId: Float): RatingMessage {
        var learner = manager.select($id == userId);
        return
        {
            rating: calculateLearnerRating(userId),
            ratingCategory: calculateRatingCategory(userId),
            learner: learner.toLearnerMessage()
        };
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
