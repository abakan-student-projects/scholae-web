package parser;

import model.NeercContest;
import model.NeercTeamUser;
import model.NeercTeam;
import model.NeercUser;
import model.NeercUniversity;
import parser.Team;
import sys.io.File;
import htmlparser.HtmlDocument;
import haxe.Json;
import haxe.Http;

class Neerc {
    private static var url: String;
    private static var contestName: String;

    public static function startParsing(_url: String, year: Int) {
        url = _url;
        var neercContestTeams = Parse();
        var neercContestsList = Lambda.array(NeercContest.manager.all());
        var neercContests: Array<String> = Lambda.array(Lambda.map(neercContestsList, function(r) {
            return r.name;
        }));

        if (neercContestTeams.length > 0 && contestName.length > 0) {
            if (neercContests.indexOf(contestName) == -1) {
                var contest = new NeercContest();
                contest.name = contestName;
                contest.year = year;
                contest.insert();

                neercContestsList.push(contest);
                neercContests.push(contestName);

                trace("Adding data from contest of the " + year + " year");

                addTeamsAndUsers(neercContestTeams, contest.id);
            } else {
                trace("Contest of the " + year + " year already exists");
            }
        } else {
            trace("Contest don't exist");
        }
    }

    public static function Parse() {
    	var html: HtmlDocument = new HtmlDocument(Http.requestUrl(url));
        var a = html.find("table.standings>tbody>tr");
        var eregTags: EReg = new EReg("/(<([^>]+)>)/ig","");
        var teams = [];
        
        contestName = eregTags.replace(html.find("table.wrapper>tr>td>center>a>h2")[0].innerHTML, "");

        for (i in 0...a.length) {
        	var b = a[i].find("td");
        	var team = [];

        	for (j in 0...b.length) {
        		var c = eregTags.replace(b[j].innerHTML, "");
        		team.push(c);
        	}

        	teams.push(team);
        }

        return teams;
    }

    public static function addTeamsAndUsers(a: Array<Array<String>>, contestId: Float) {
        var eregBrackets: EReg = new EReg("/()/ig", "");
        var neercUniversities = Lambda.array(NeercUniversity.manager.all());
        var neercUniversityNames: Array<String> = Lambda.array(Lambda.map(neercUniversities, function(f: NeercUniversity) {
            return f.name;
        }));
        var users = 0;
        var teams = 0;
        var universities = 0;

        for (i in 0...a.length) {
            var team = a[i][1].split("(");

            if (team.length == 2) {
                var teamMembersString: String = team[1].substring(0, team[1].length-1);
                var teamMembers: Array<String> = teamMembersString.split(", ");

                var neercTeam = new NeercTeam();
                neercTeam.name = team[0];
                neercTeam.rank = Std.parseInt(a[i][0]);
                neercTeam.contestId = contestId;
                neercTeam.solvedProblemsCount = Std.parseInt(a[i][a[i].length-2]);
                neercTeam.time = Std.parseInt(a[i][a[i].length-1]);
                neercTeam.insert();

                teams++;

                var universityName = getUniversityNameByTeamName(team[0]);
                var univerityId: Int = neercUniversityNames.indexOf(universityName);

                if (univerityId == -1) {
                    var neercUniversity = new NeercUniversity();
                    neercUniversity.name = universityName;
                    neercUniversity.insert();

                    neercUniversityNames.push(universityName);
                    neercUniversities.push(neercUniversity);
                    universities++;

                    univerityId = Std.int(neercUniversity.id);
                } else {
                    univerityId = Std.int(neercUniversities[univerityId].id);
                }

                if (teamMembers.length > 0) {
                    for (j in 0...teamMembers.length) {
                        var neercUser = new NeercUser();
                        neercUser.lastName = teamMembers[j];
                        neercUser.universityId = univerityId;
                        neercUser.insert();

                        var neercTeamUser = new NeercTeamUser();
                        neercTeamUser.teamId = neercTeam.id;
                        neercTeamUser.userId = neercUser.id;
                        neercTeamUser.insert();

                        users++;
                    }
                }
            }
        }

        trace("Added " + universities + ((universities == 1) ? " university" : " universities"));
        trace("Added " + teams + ((teams == 1) ? " team" : " teams"));
        trace("Added " + users + ((users == 1) ? " user" : " users\n"));
    }

    // deleting number of team name
    public static function getUniversityNameByTeamName(name: String): String {
        var wasDigit = false;

        for (i in 1...name.length) {
            if (name.charAt(name.length-i) != " " && !wasDigit) {
                wasDigit = true;
            } else if (name.charAt(name.length-i) == ' ' && wasDigit) {
                return name.substring(0, name.length-i);
            }
        }

        return "";
    }

    public static function getTeams(): List<String> {
        var neercTeams: List<model.NeercTeam> = NeercTeam.manager.all();

        if (neercTeams != null) {
            var res: List<String> = Lambda.map(neercTeams, function(t) {
                var s: String = t.name;
                return s;
            });

            return res;
        }

        return null;
    }

    public static function deleteAllDataFromDataBase() {
        /*
        TRUNCATE TABLE NeercUsers;
        TRUNCATE TABLE NeercTeamUsers;
        TRUNCATE TABLE NeercTeams;
        TRUNCATE TABLE NeercUniversities;
        TRUNCATE TABLE NeercContests;
        */
    }
}