package model;

import messages.ResponseMessage;
import jobs.ScholaeJob;
import sys.db.Manager;
import sys.db.Types;

@:id(id)
@:table("Jobs")
class Job extends sys.db.Object {
    public var id: SBigId;
    public var sessionId: SString<255>;
    public var request: SData<ScholaeJob>;
    public var response: SData<ResponseMessage>;
    public var progress: SFloat;
    public var creationDateTime: SDateTime;
    public var modificationDateTime: SDateTime;

    public static var manager = new Manager<Job>(Job);

    public function new() {
        super();
    }
}
