package model;

import haxe.EnumTools.EnumValueTools;
import messages.LinksForTagsMessage;
import sys.db.Manager;
import sys.db.Types;
import messages.LinkTypes;

@:table("LinksForTags")
class LinksForTags extends sys.db.Object {
    public var id: SBigId;
    @:relation(tagId) public var tag: CodeforcesTag;
    public var URL: SString<128>;
    public var type: SEnum<LinkTypes>;
    public var optional: SString<512>;

    public function new() {
        super();
    }

    public static var manager = new Manager<LinksForTags>(LinksForTags);

    public function toMessage(): LinksForTagsMessage {
        return {
            id: id,
            tag: tag.id,
            url: URL,
            type: EnumValueTools.getIndex(type),
            optional: optional
        };
    }
}
