package parser;

/*typedef Team = {
    id: Int,
    teamName: String,
    members: Array<String>
}*/


class Team {
    public var teamName: String;
    public var members: Array<String>;

    public function new(_univer: String, _members: Array<String>): Void {
        this.teamName = _univer;
        this.members = _members;
    }

    public function toString(): String {
        var str: String = this.teamName + ": ";

        for (i in 0...this.members.length) {
            str += this.members[i] + ", ";
        }

        str = str.substring(0, str.length - 2);
        return str;
    }
}