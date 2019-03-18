package model;

import sys.db.Manager;
import sys.db.Types.SBigId;

@:table("CategoryRating")
class CategoryRating extends sys.db.Object {
    public var id: SBigId;
    @:relation(userId) public var user : User;
    @:relation(categoryId) public var tag : CodeforcesTag;
    public var rating: Float;

    public function new() {
        super();
    }

    public static var manager = new Manager<CategoryRating>(CategoryRating);
}
