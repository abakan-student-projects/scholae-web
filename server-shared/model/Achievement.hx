package model;

import sys.db.Types.SText;
import sys.db.Manager;
import achievement.AchievementCategory;
import sys.db.Types.SEnum;
import sys.db.Types.SDateTime;
import sys.db.Types.SString;
import sys.db.Types.SBigId;

@:table("Achievement")
class Achievement extends sys.db.Object {
    public var id: SBigId;
    public var title: SString<512>;
    public var description: SText;
    public var iconPath: SString<512>;
    public var date: SDateTime;
    public var category: SEnum<AchievementCategory>;

    public function new() {
        super();
    }

    public static var manager = new Manager<Achievement>(Achievement);

    public function toMessage() {
        return
            {
                id: id,
                title: title,
                description: description,
                iconPath: iconPath,
                date: Date,
                category: haxe.Serializer.run(category)
            };
    }
}
