package model;

@:table("ScholaeTrainings")
class ScholaeTraining extends sys.db.Object {
    public var id: SBigId;
    public var name: SString<512>;
    @:relation(userId) public var user : User;
    
    public function new() {
        super();
    }

    public static var manager = new Manager<ScholaeTraining>(ScholaeTraining);
    
}
