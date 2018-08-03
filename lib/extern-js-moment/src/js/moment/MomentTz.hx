package js.moment;

#if moment_timezone

extern class MomentTz
{
    public function setDefault(zone : String) : Void;
    
    public function guess() : String;
    
    @:overload(function (zones : Array<String>) : MomentTz {})
    public function add(zone : String) : MomentTz;
    
    @:overload(function (zones : Array<String>) : MomentTz {})
    public function link(zone : String) : MomentTz;
    
    public function load(data : {}) : MomentTz;
    
    public function zone(name : String) : Null<Zone>;
    
    public function names() : Array<String>;
}

#end
