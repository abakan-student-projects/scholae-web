# extern-js-moment

- **Target :** Javascript (NodeJS + Browser)
- **Library :** moment
- **Last tested version :** 2.11.2
- **Available on :** [Web](http://momentjs.com/) - [Github](https://github.com/moment/moment) - [NPM](https://www.npmjs.com/package/moment)
- **Plugins :**
  - *Timezone* (0.5.1) : [Web](http://momentjs.com/timezone/) - [Github](https://github.com/moment/moment-timezone/) - [NPM](https://www.npmjs.com/package/moment-timezone)

## Usage

```haxe
import js.moment.*;

class Main
{
  static function main()
  {
    // Format Dates
    Moment.moment().format('MMMM Do YYYY, h:mm:ss a'); // March 7th 2016, 2:32:21 pm
    Moment.moment().format('dddd');                    // Monday
    Moment.moment().format("MMM Do YY");               // Mar 7th 16
    Moment.moment().format('YYYY [escaped] YYYY');     // 2016 escaped 2016
    Moment.moment().format();                          // 2016-03-07T14:32:21+01:00

    // Relative Time
    Moment.moment("20111031", "YYYYMMDD").fromNow(); // 4 years ago
    Moment.moment("20120620", "YYYYMMDD").fromNow(); // 4 years ago
    Moment.moment().startOf('day').fromNow();        // 15 hours ago
    Moment.moment().endOf('day').fromNow();          // in 9 hours
    Moment.moment().startOf('hour').fromNow();       // 32 minutes ago

    // Calendar Time
    Moment.moment().subtract(10, 'days').calendar(); // 02/26/2016
    Moment.moment().subtract(6, 'days').calendar();  // Last Tuesday at 2:32 PM
    Moment.moment().subtract(3, 'days').calendar();  // Last Friday at 2:32 PM
    Moment.moment().subtract(1, 'days').calendar();  // Yesterday at 2:32 PM
    Moment.moment().calendar();                      // Today at 2:32 PM
    Moment.moment().add(1, 'days').calendar();       // Tomorrow at 2:32 PM
    Moment.moment().add(3, 'days').calendar();       // Thursday at 2:32 PM
    Moment.moment().add(10, 'days').calendar();      // 03/17/2016

    // Multiple Locale Support
    Moment.moment.locale();         // en
    Moment.moment().format('LT');   // 2:32 PM
    Moment.moment().format('LTS');  // 2:32:21 PM
    Moment.moment().format('L');    // 03/07/2016
    Moment.moment().format('l');    // 3/7/2016
    Moment.moment().format('LL');   // March 7, 2016
    Moment.moment().format('ll');   // Mar 7, 2016
    Moment.moment().format('LLL');  // March 7, 2016 2:32 PM
    Moment.moment().format('lll');  // Mar 7, 2016 2:32 PM
    Moment.moment().format('LLLL'); // Monday, March 7, 2016 2:32 PM
    Moment.moment().format('llll'); // Mon, Mar 7, 2016 2:32 PM
  }
}
```

## Differences with native moment

Moment uses the same name for instance and static methods. As Haxe doesn't allow this, some methods have been renamed to avoid this conflict:

- `moment.utc(...)` becomes `Moment.fromUtc(...)`
- `moment(...).months(...)` becomes `Moment.moment(...).months_(...)`
- `moment(...).locale(...)` becomes `Moment.moment(...).setLocale(...)`

## Plugins

### Timezone

To enable moment-timezone plugin you must add the following parameter to your `hxml` build configuration:
```hxml
-D moment_timezone
```

You can use it like this
```haxe
import js.moment.*;

class Main
{
  static function main()
  {
    // Format Dates in Any Timezone
    var jun = Moment.moment("2014-06-01T12:00:00Z");
    var dec = Moment.moment("2014-12-01T12:00:00Z");

    jun.setTz('America/Los_Angeles').format('ha z');  // 5am PDT
    dec.setTz('America/Los_Angeles').format('ha z');  // 4am PST

    jun.setTz('America/New_York').format('ha z');     // 8am EDT
    dec.setTz('America/New_York').format('ha z');     // 7am EST

    jun.setTz('Asia/Tokyo').format('ha z');           // 9pm JST
    dec.setTz('Asia/Tokyo').format('ha z');           // 9pm JST

    jun.setTz('Australia/Sydney').format('ha z');     // 10pm EST
    dec.setTz('Australia/Sydney').format('ha z');     // 11pm EST

    // Convert Dates Between Timezones
    var newYork    = Moment.tz("2014-06-01 12:00", "America/New_York");
    var losAngeles = newYork.clone().setTz("America/Los_Angeles");
    var london     = newYork.clone().setTz("Europe/London");

    newYork.format();    // 2014-06-01T12:00:00-04:00
    losAngeles.format(); // 2014-06-01T09:00:00-07:00
    london.format();     // 2014-06-01T17:00:00+01:00
  }
}
```

As moment defines a *magic* `tz` function for multiple purpose, some actions requires to use an other method:

- `moment.tz.<...>(...)` becomes `Moment.timezone.<...>(...)`
- `moment(...).tz(...)` becomes `Moment.moment(...).setTz(...)`
