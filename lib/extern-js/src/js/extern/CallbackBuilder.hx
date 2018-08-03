package js.extern;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.TypeTools;

@:noPackageRestrict
class CallbackBuilder
{
    public static macro function build() : ComplexType
    {
        return switch (Context.getLocalType()) {
            case TInst(_, params):
                var args = [ macro : js.extern.Error ];
                for (param in params) {
                    args.push(param.toComplexType());
                }
                TFunction(args, macro : Void);
            case _:
                null;
        }
    }
}

#end
