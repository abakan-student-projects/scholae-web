package model;

import achievement.AchievementParameters;
import sys.db.Types.SEnum;
import achievement.AchievementCategory;
import sys.db.Types.SData;
import sys.db.Types.SText;
import sys.db.Manager;
import sys.db.Types.SString;
import sys.db.Types.SBigId;

@:table("Achievement")
class Achievement extends sys.db.Object {
    public var id: SBigId;
    public var title: SString<512>;
    public var description: SText;
    public var category: SEnum<AchievementCategory>;
    public var parameters: SData<AchievementParameters>;

    public function new() {
        super();
    }

    public static var manager = new Manager<Achievement>(Achievement);

}
