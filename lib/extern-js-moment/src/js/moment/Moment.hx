package js.moment;

import haxe.Constraints.Function;
import haxe.extern.Rest;
import js.extern.Either;

extern class Moment
#if moment_timezone
    implements js.extern.Extern<'moment-timezone'>
#else
    implements js.extern.Extern<'moment'>
#end
{
    public static var version : String;
    
    @:selfCall
    @:overload(function (a : MomentLike) : Moment {})
    @:overload(function (a : String, b : String) : Moment {})
    @:overload(function (a : String, b : String, c : String) : Moment {})
    @:overload(function (a : String, b : String, c : Bool) : Moment {})
    @:overload(function (a : String, b : String, c : String, d : Bool) : Moment {})
    @:overload(function (a : String, b : Array<String>, c : String, d : Bool) : Moment {})
    public static function moment(a : {}) : Moment;
    
    @:native('utc')
    @:overload(function (a : Float) : Moment {})
    @:overload(function (a : Array<Float>) : Moment {})
    @:overload(function (a : String) : Moment {})
    @:overload(function (a : String, b : String) : Moment {})
    @:overload(function (a : String, b : Array<String>) : Moment {})
    @:overload(function (a : String, b : String, c : String) : Moment {})
    @:overload(function (a : Moment) : Moment {})
    @:overload(function (a : Date) : Moment {})
    public static function fromUtc() : Moment;
    
    public static function invalid(?object : Dynamic) : Moment;
    
    public static function parseZone(date : String) : Moment;
    
    public static function max(other : Rest<Moment>) : Moment;
    
    public static function min(other : Rest<Moment>) : Moment;
    
    public static function isMoment(value : Dynamic) : Bool;
    
    public static function isDate(value : Dynamic) : Bool;
    
    @:overload(function () : String {})
    @:overload(function (locales : Array<String>) : Void {})
    public static function locale(locale : String, ?values : {}) : Void;
    
    @:overload(function (index : Int) : String {})
    @:overload(function (format : String, index : Int) : String {})
    public static function months(?format : String) : Array<String>;
    
    @:overload(function (index : Int) : String {})
    @:overload(function (format : String, index : Int) : String {})
    public static function monthsShort(?format : String) : Array<String>;
    
    @:overload(function (index : Int) : String {})
    @:overload(function (format : String, index : Int) : String {})
    public static function weekdays(?format : String) : Array<String>;
    
    @:overload(function (index : Int) : String {})
    @:overload(function (format : String, index : Int) : String {})
    public static function weekdaysShort(?format : String) : Array<String>;
    
    @:overload(function (index : Int) : String {})
    @:overload(function (format : String, index : Int) : String {})
    public static function weekdaysMin(?format : String) : Array<String>;
    
    public static function localeData() : Dynamic;
    
    @:overload(function (unit : String, limit : Int) : Void {})
    public static function relativeTimeThreshold(unit : String) : Int;
    
    public static dynamic function now() : Int;
    
    public static function normalizeUnits(unit : String) : String;
    
    public function isValid() : Bool;
    
    public function invalidAt() : Int;
    
    public function creationData() : Dynamic;
    
    public function clone() : Moment;
    
    @:overload(function (value : Int) : Moment {})
    public function millisecond() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function milliseconds() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function second() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function seconds() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function minute() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function minutes() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function hour() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function hours() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function date() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function dates() : Int;
    
    @:overload(function (value : Either<Int, String>) : Moment {})
    public function day() : Int;
    
    @:overload(function (value : Either<Int, String>) : Moment {})
    public function days() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function weekday() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function isoWeekday() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function dayOfYear() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function week() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function weeks() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function isoWeek() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function isoWeeks() : Int;
    
    @:overload(function (value : Either<Int, String>) : Moment {})
    public function month() : Int;
    
    @:native('months')
    @:overload(function (value : Either<Int, String>) : Moment {})
    public function months_() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function quarter() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function year() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function years() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function weekYear() : Int;
    
    @:overload(function (value : Int) : Moment {})
    public function isoWeekYear() : Int;
    
    public function weeksInYear() : Int;
    
    public function isoWeeksInYear() : Int;
    
    public function get(unit : String) : Int;
    
    @:overload(function (values : {}) : Moment {})
    public function set(unit : String, value : Int) : Moment;
    
    @:overload(function (values : {}) : Moment {})
    public function add(value : Int, unit : String) : Moment;
    
    @:overload(function (values : {}) : Moment {})
    public function substract(value : Int, unit : String) : Moment;
    
    public function startOf(unit : String) : Moment;
    
    public function endOf(unit : String) : Moment;
    
    public function local() : Moment;
    
    public function utc() : Moment;
    
    @:overload(function () : Int {})
    public function utcOffset(offset : Either<Int, String>) : Moment;
    
    @:overload(function (zone : String) : Moment {})
    public function zone() : Int;
    
    public function format(?format : String) : String;
    
    public function fromNow(?noSuffix : Bool) : String;
    
    public function from(value : MomentLike, ?noSuffix : Bool) : String;
    
    public function toNow(?noSuffix : Bool) : String;
    
    public function to(value : MomentLike, ?noSuffix : Bool) : String;
    
    public function calendar(?referenceTime : Date, ?formats : {}) : String;
    
    public function diff(value : MomentLike, ?unit : String, ?noSuffix : Bool) : String;
    
    public function valueOf() : Int;
    
    public function unix() : Int;
    
    public function daysInMonth() : Int;
    
    public function toDate() : Date;
    
    public function toArray() : Array<Int>;
    
    public function toJSON() : {};
    
    public function toISOString() : String;
    
    public function toObject() : {};
    
    public function isBefore(value : MomentLike, ?unit : String) : Bool;
    
    public function isSame(value : MomentLike, ?unit : String) : Bool;
    
    public function isAfter(value : MomentLike, ?unit : String) : Bool;
    
    public function isSameOrBefore(value : MomentLike, ?unit : String) : Bool;
    
    public function isSameOrAfter(value : MomentLike, ?unit : String) : Bool;
    
    public function isBetween(value1 : MomentLike, value2 : MomentLike, ?unit : String) : Bool;
    
    public function isDST() : Bool;
    
    public function isDSTShifted() : Bool;
    
    public function isLeapYear() : Bool;
    
    @:native('locale')
    public function setLocale(locale : String) : Moment;
    
    
#if moment_timezone

    /**
     * This one is a shortcut to moment.tz() function
     */
    @:overload(function (zone : String, a : MomentLike) : Moment {})
    @:overload(function (zone : String, a : String, b : String) : Moment {})
    @:overload(function (zone : String, a : String, b : String, c : String) : Moment {})
    @:overload(function (zone : String, a : String, b : String, c : Bool) : Moment {})
    @:overload(function (zone : String, a : String, b : String, c : String, d : Bool) : Moment {})
    @:overload(function (zone : String, a : String, b : Array<String>, c : String, d : Bool) : Moment {})
    @:overload(function (zone : String, a : {}) : Moment {})
    public static function tz(zone : String) : Moment;
    
    /**
     * This one is a shortcut to moment.tz object
     */
    @:native('tz')
    public static var timezone : MomentTz;
    
    @:native('tz')
    public function setTz(zone : String) : Moment;
    
    public function zoneAbbr() : String;
    
    public function zoneName() : String;
    
#end
}
