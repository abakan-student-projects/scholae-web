package model;

import sys.db.Types.SText;
import sys.db.Manager;
import sys.db.Types.SString;
import sys.db.Types.SBigId;

@:table("Achievement")
class Achievement extends sys.db.Object {
    public var id: SBigId;
    public var title: SString<512>;
    public var description: SText;
    public var icon: SString<512>;
    public var category: Int;

    public function new() {
        super();
    }

    public static var manager = new Manager<Achievement>(Achievement);

}
