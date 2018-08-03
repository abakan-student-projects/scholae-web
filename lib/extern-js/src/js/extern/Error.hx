package js.extern;

@:forward
abstract Error(Dynamic) from js.Error to js.Error from String to String
#if js_kit
from js.support.Error to js.support.Error 
#end
{}
