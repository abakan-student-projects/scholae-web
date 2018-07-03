package ;

import model.User;

class Main {
    public static function main() {

        var cnx = sys.db.Mysql.connect({
            host : "127.0.0.1",
            port : null,
            user : "scholae",
            pass : "scholae",
            database : "scholae",
            socket : null,
        });

        sys.db.Manager.cnx = cnx;

        sys.db.Manager.initialize();

        for (u in User.manager.all()) {
            trace(u.id);
            trace(u.email);
            trace(u.passwordHash);
        }
    }
}
