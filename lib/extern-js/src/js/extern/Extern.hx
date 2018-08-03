package js.extern;

#if (haxe_ver >= 3.3)

@:autoBuild(js.extern.ExternBuilder.build())
extern interface Extern<@:const P> {}

#else

@:autoBuild(js.extern.ExternBuilder.build())
extern interface Extern<Const> {}

#end
