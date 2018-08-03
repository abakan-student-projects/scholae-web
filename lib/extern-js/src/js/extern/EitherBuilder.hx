package js.extern;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#if (haxe_ver >= 4)
import haxe.ds.Map;
#end

using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using StringTools;

@:noPackageRestrict
class EitherBuilder
{
    private static var EITHER_PACKAGE : Array<String> = ['js', 'extern', 'either'];

    private static var EITHER_TYPES : Map<String, ComplexType> = new Map();

    private static var TYPE_EREG : EReg = ~/[^a-z0-9_]/ig;

    public static macro function build() : ComplexType
    {
        var builder = new EitherBuilder();
        return builder.handle();
    }

    private function new()
    {

    }

    public function handle() : ComplexType
    {
        var params = this.listParams();
        var hash = this.createHash(params);

        // Check if cache is available
        if (EITHER_TYPES.exists(hash)) {
            return EITHER_TYPES[hash];
        }

        //  Define type
        return this.defineType(params, hash);
    }

    private function listParams() : Array<ComplexType>
    {
        return switch (Context.getLocalType()) {
            case TInst(_, params): [ for (param in params) param.toComplexType() ];
            case _: [];
        }
    }

    private function createHash(params : Array<ComplexType>) : String
    {
        var tmp = [
            for (param in params)
                TYPE_EREG.replace(param.toString().replace('{ }', '_AnonObj_'), '_')
        ];
        tmp.sort(Reflect.compare);
        return tmp.join('_OR_');
    }

    private function defineType(params : Array<ComplexType>, hash : String) : ComplexType
    {
        var typeName = 'Either_${hash}';

        // Define type
        Context.defineType({
            pos: Context.currentPos(),
            params: null,
            pack: EITHER_PACKAGE,
            name: typeName,
            meta: null,
            kind: TDAbstract(macro : Dynamic, params, params),
            isExtern: false,
            fields: []
        });
        
        // Cache it
        return EITHER_TYPES[hash] = TPath({
            pack: EITHER_PACKAGE,
            name: typeName,
        });
    }
}

#end
