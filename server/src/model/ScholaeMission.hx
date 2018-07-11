package model;

@:table("ScholaeMissons")
class ScholaeMission extends sys.db.Object {
    public var id: SBigId;
    public var state: SBool;
    @:relation(taskId) public var task : CodeforcesTask;
    @:relation(trainingId) public var training : ScholaeTraining;
    
    public function new() {
        super();
    }

    public static var manager = new Manager<ScholaeMission>(ScholaeMission);
    
}
