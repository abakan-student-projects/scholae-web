package model;

@:table("CodeforcesTasks")
class CodeforcesTask extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;
    public var level: SInt;
    public var solvedCount: Int;
    public var contestId: Int;
    public var contestIndex: SString<128>;

    public function new() {
        super();
    }

    public static var manager = new Manager<CodeforcesTask>(CodeforcesTask);

}
