package model;

@:table("CodeforcesTags")
class CodeforcesTag extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;

    public function new() {
        super();
    }

    public static var manager = new Manager<CodeforcesTag>(CodeforcesTag);

}
