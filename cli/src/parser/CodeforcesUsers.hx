package parser;

import model.CodeforcesUser;
import htmlparser.HtmlDocument;
import codeforces.Response;
import codeforces.Codeforces;
import haxe.Http;
import haxe.Json;
import haxe.Timer;

class CodeforcesUsers {
	public static function ParseUsersFromRussia() {
        for (i in 1...35 + 1) {
            ParsePage(i);
        }
	}

    public static function updateCodeforcesUsersNames() {
        var handles = getAllHandles();
        var items = 500;
        var iterations: Int = Math.floor(handles.length / items + 1);

        for (k in 0...iterations) {
            var postfix = "en";
            var url = "http://codeforces.com/api/user.info?handles=" + getHandlesUrl(handles.slice((k * items), ((k != iterations - 1) ? (k * items + items) : handles.length)));
            var result: Response = Json.parse(Http.requestUrl(url));

            if (result.result.length > 0) {
                var updated = 0;

                for (i in 0...result.result.length) {
                    var firstName = result.result[i].firstName;
                    var lastName = result.result[i].lastName;
                    var handle = result.result[i].handle;

                    if (lastName != null) {
                        var updateUserInfo = CodeforcesUser.manager.select({handle: handle});
                        updateUserInfo.firstName = firstName;
                        updateUserInfo.lastName = lastName;
                        updateUserInfo.update();

                        updated++;
                    }
                }

                trace("Updated " + updated + " " + postfix + "-names of the users");
            } else {
                trace("?");
            }
        }
    }

	public static function ParsePage(page: Int) {
        var eregTr: EReg = new EReg("<tr[^>]*>","igm");
        var eregTags: EReg = new EReg("</?span[^>]*>","igm");
        var data = eregTr.replace(Http.requestUrl("http://codeforces.com/ratings/country/Russia/page/" + page), "</tr><tr>");
        var html: HtmlDocument = new HtmlDocument(data, true);
        var table = html.find("#pageContent>div.datatable>div>table>tr");
        var users = 0;

        for (i in 0...table.length) {
            var records = table[i].find(">td");
            var handleHTML = table[i].find(">td>a");
            var userHandles: Array<String> = getAllHandles();

            if (records.length > 0 && handleHTML.length > 0) {
                var handle = handleHTML[0].innerHTML;

                if (i < 3 && page < 2)
                    handle = eregTags.replace(handle, "");
                if (userHandles.indexOf(handle) == -1) {
                    var rank = (records[0].innerHTML != "-") ? records[0].innerHTML.split("&nbsp;(") : null;

                    var user = new CodeforcesUser();
                    user.handle = eregTags.replace(handle, "");
                    user.countContests = Std.parseInt(records[2].innerHTML);
                    user.rating = Std.parseInt(records[3].innerHTML);

                    if (rank != null) {
                        user.rankWorld = Std.parseInt(rank[0]);
                        if (Std.is(rank[1], String)) {
                            user.rankRussia = Std.parseInt(rank[1].substring(0, rank[1].length-2));
                        }
                    }

                    user.insert();
                    users++;
                }
            }

        }

        trace("Added " + users + ((users == 1) ? " user" : " users") + " on page " + page);
	}

    private static function getHandlesUrl(handles: Array<String>): String {
        var url = "";
        for (i in 0...handles.length) url += handles[i] + ";";
        return url;
    }

    public static function getAllHandles(): Array<String> {
        return Lambda.array(Lambda.map(Lambda.array(CodeforcesUser.manager.all()), function(user) {
            return user.handle;
        }));
    }

    // clear table: TRUNCATE TABLE CodeforcesUsers
}