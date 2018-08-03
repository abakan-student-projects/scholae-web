package js.moment;

#if moment_timezone

@:native('tz.Zone')
@:externjs(namespace=true)
extern class Zone implements js.extern.Extern<'moment-timezone'>
{
    public var name : String;
    
    public var abbrs : Array<String>;
    
    public var untils  : Array<Int>;
    
    public var offsets : Array<Int>;
    
    public function abbr(timestamp : Int) : String;
    
    public function offset(timestamp : Int) : Int;
    
    public function parse(timestamp : Int) : Int;
}

#end
