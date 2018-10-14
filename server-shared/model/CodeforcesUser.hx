package model;

import messages.CodeforcesUserMessage;
import sys.db.Connection;
import sys.db.Manager;
import sys.db.Types;

@:table("CodeforcesUsers")
class CodeforcesUser extends sys.db.Object {
    public var id: SBigId;
    public var handle: SString<64>;
    public var firstName: SString<64>;
    public var lastName: SString<64>;
    public var russianFirstName: SString<64>;
    public var russianLastName: SString<64>;
    public var rankWorld: SInt;
    public var rankRussia: SInt;
    public var countContests: SInt;
    public var rating: SInt;
    public var solvedProblems: SInt;
    public var lastCodeforcesSubmissionId: SBigInt;
    public var learnerRating: SBigInt;

    public function new() {
        super();
    }

    public static var manager = new Manager<CodeforcesUser>(CodeforcesUser);

    public function toMessage(): CodeforcesUserMessage {
        return {
            id: id,
            handle: handle,
            firstName: firstName,
            lastName: lastName,
            russianFirstName: russianFirstName,
            russianLastName: russianLastName,
            rankWorld: rankWorld,
            rankRussia: rankRussia,
            countContests: countContests,
            rating: rating,
            solvedProblems: solvedProblems,
            lastCodeforcesSubmissionId: lastCodeforcesSubmissionId,
            learnerRating: learnerRating
        };
    }

    public static function calculateLearnerRating(user: CodeforcesUser): Float {
        var rating:Int = 0;
        var results:List<NeercAttempt> = NeercAttempt.manager.search(($userId ==user.id) && ($solved==true));

        for (item in results) {
            if (item.task != null && item.task.level != null)
                rating += item.task.level;
        }

        return rating;
    }
}
