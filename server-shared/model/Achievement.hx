package model;

import sys.db.Types.SText;
import sys.db.Manager;
import achievement.AchievementCategory;
import sys.db.Types.SEnum;
import sys.db.Types.SString;
import sys.db.Types.SBigId;

@:table("Achievement")
class Achievement extends sys.db.Object {
    public var id: SBigId;
    public var title: SString<512>;
    public var description: SText;
    public var iconPath: SString<512>;
    public var category: SEnum<AchievementCategory>;

    public function new() {
        super();
    }

    public static var manager = new Manager<Achievement>(Achievement);
}
