package configuration;

import configuration.SmtpConfig;
import configuration.DatabaseConfig;

class Configuration {
    public static var instance(get, null): Configuration;
    private static var _instance: Configuration;
    private static function get_instance(): Configuration {
        if (null == _instance) {
            _instance = new Configuration();
        }
        return _instance;
    }

    private var xml: Xml;

    public function new() {
        xml = Xml.parse(haxe.Resource.getString("scholae.xml")).firstElement();
    }

    private function getTagValue(tagName: String): String {
        return xml.elementsNamed(tagName).next().firstChild().nodeValue;
    }

    public function getEmailNotification(): String {
        return getTagValue("EmailNotification");
    }

    public function getDatabaseConfig(): DatabaseConfig {
        var em = xml.elementsNamed("DatabaseParameters").next();
        var host = em.elementsNamed("host").next().firstChild().nodeValue;
        var name = em.elementsNamed("name").next().firstChild().nodeValue;
        var user = em.elementsNamed("user").next().firstChild().nodeValue;
        var password = em.elementsNamed("password").next().firstChild().nodeValue;
        return {host: host, name: name, user: user, password: password};
    }

    public function getSmtpConfig(): SmtpConfig {
        var em = xml.elementsNamed("SMTPParameters").next();
        var host = em.elementsNamed("host").next().firstChild().nodeValue;
        var port = Std.parseInt(em.elementsNamed("port").next().firstChild().nodeValue);
        var user = em.elementsNamed("user").next().firstChild().nodeValue;
        var password = em.elementsNamed("password").next().firstChild().nodeValue;
        return {host: host, port: port, user: user, password: password};
    }

    public function getAmqpConfig(): AmqpConfig {
        var em = xml.elementsNamed("AmqpParameters").next();
        var user = em.elementsNamed("user").next().firstChild().nodeValue;
        var password = em.elementsNamed("password").next().firstChild().nodeValue;
        var hostpath = em.elementsNamed("hostpath").next().firstChild().nodeValue;
        var host = em.elementsNamed("host").next().firstChild().nodeValue;
        return {user: user, password: password, hostpath: hostpath, host: host};
    }
}
