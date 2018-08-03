package js.extern;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#if (haxe_ver >= 4)
import haxe.ds.Map;
#end


using StringTools;

@:noPackageRestrict
@:enum
private abstract AccessMode(String) from String to String
{
    var Global  = 'global';
    var Window  = 'window';
    var Require = 'require';
}

@:noPackageRestrict
class ExternBuilder
{
    private static var MODES : Array<String> = [ AccessMode.Global, AccessMode.Window, AccessMode.Require ];

    @:isVar
    private static var accessMode(get, null) : String;
    private static function get_accessMode() : String
    {
        if (null == ExternBuilder.accessMode) {
            var definedMode = Compiler.getDefine('extkit_mode');
            ExternBuilder.accessMode = ((MODES.indexOf(definedMode) == -1) ? Require : definedMode);
        }

        return ExternBuilder.accessMode;
    }

    private static inline var EXTERN_INTERFACE = 'js.extern.Extern';

    private static inline var MODE_DEFINE : String = 'extkit_mode';

    private static inline var EXTERN_META : String      = ':externjs';
    private static inline var EXTERN_DONE_META : String = ':extkit_extern_done';

    public static macro function build() : Array<Field>
    {
        var builder = new ExternBuilder();
        builder.handle();
        return builder.fields;
    }

    var currentClass : ClassType;
    var fields : Array<Field>;
    var isNamespace : Bool;
    var names : Map<String, String>;

    private function new()
    {
        this.currentClass = Context.getLocalClass().get();
        this.fields       = Context.getBuildFields();
        this.isNamespace  = false;
        this.names        = new Map();
    }

    public function handle() : Void
    {
        // Don't handle extern twice
        if (currentClass.meta.has(ExternBuilder.EXTERN_DONE_META)) {
            return;
        }
        currentClass.meta.add(ExternBuilder.EXTERN_DONE_META, [], this.pos());

        // Parse meta
        this.handleMetas();

        // Handle version define
        this.handleVersion();

        // Handle access
        this.handleAccess();
    }

    public function handleVersion() : Void
    {
        var module  = this.extractModule(this.currentClass).toLowerCase().replace('-', '_');
        var version = '${module}_ver';
        
        // Check currently defined version
        var definedVersion = Context.definedValue(version);
        if (null != definedVersion) {
            return;
        }

        // Define default version
        var defaultVersion = '${module}_default_ver';
        Compiler.define(version, Context.definedValue(defaultVersion));
    }

    public function handleMetas() : Void
    {
        if (!this.currentClass.meta.has(EXTERN_META)) {
            return;
        }

        var meta = this.currentClass.meta.extract(EXTERN_META);
        for (param in meta[0].params) {
            switch (param) {
                case { expr: EBinop(OpAssign, { expr: EConst(CIdent(key)) }, value) }:
                    switch (key) {
                        case 'namespace':
                            switch (value) {
                                case { expr: EConst(CIdent('true')) }:  this.isNamespace = true;
                                case { expr: EConst(CIdent('false')) }: this.isNamespace = false;
                                case _: Context.fatalError('Invalid value for "namespace" parameter. Expected true or false, got ${value.expr}.', value.pos);
                            }
                        case mode if (MODES.indexOf(mode) != -1):
                            switch (value) {
                                case { expr: EConst(CIdent(overload)) } | { expr: EConst(CString(overload)) }:  this.names[mode] = overload;
                                case _: Context.fatalError('Invalid value for "${mode}" parameter. Expected a string or an identifier, got ${value.expr}.', value.pos);
                            }
                        case _:
                            Context.fatalError('Unknown @:externjs parameter "$key".', param.pos);
                    }
                case _:
                    Context.fatalError('Invalid @:externjs parameter "$param".', param.pos);
            }
        }
    }

    public function handleAccess() : Void
    {
        // Get extern module name
        var module = (this.names.exists(ExternBuilder.accessMode) ?
            this.names.get(ExternBuilder.accessMode) :
            this.extractModule(this.currentClass)
        );
        
        // Handle access mode
        switch (ExternBuilder.accessMode) {
            case Global, Window:
                // Default global name
                var global = '${ExternBuilder.accessMode}.$module';

                // Append namespace name
                if (this.isNamespace) {
                    var native = this.extractNative(true);
                    global += '.' + (null == native ? this.currentClass.name : native);
                }

                this.currentClass.meta.add(':native', [macro $v{global}], this.pos());

            case Require:
                // Prepare @:jsRequire meta
                var params = [ macro $v{module} ];

                // Add namespace if required
                if (this.isNamespace) {
                    // Use @:native meta if specified
                    // Otherwise use class name
                    var native = this.extractNative(true);
                    var name = (null == native ? this.currentClass.name : native);
                    params.push(macro $v{name});
                }

                this.currentClass.meta.add(':jsRequire', params, this.pos());
        }
    }

    function extractModule(classType : ClassType) : String
    {
        for (type in classType.interfaces) {
            if (type.t.toString() == ExternBuilder.EXTERN_INTERFACE) {
                // Check parameters length
                if (1 != type.params.length) {
                    Context.fatalError('${ExternBuilder.EXTERN_INTERFACE} interface should ony take one parameter.', this.pos());
                }

                // Try to extract a string on the first parameter
                switch (type.params[0]) {
                    case TInst(param, _):
                        switch (param.get().kind) {
                            case KExpr({ expr: EConst(CString(name)) }): return name;
                            case _:
                        }
                    case _:
                }
                Context.fatalError('Invalid ${ExternBuilder.EXTERN_INTERFACE} type parameter. It should be a string constant.', this.pos());
            }
        }

        if (null != classType.superClass) {
            return this.extractModule(classType.superClass.t.get());
        }

        Context.fatalError('Assert false.', this.pos());
        return null;
    }

    function extractNative(remove : Bool = false) : Null<String>
    {
        // Extract value
        var native = this.currentClass.meta.extract(':native');
        var value = switch (native) {
            case [{ params: [{ expr: EConst(CString(name)) }] }]: name;
            case _: null;
        }

        // Remove meta
        if (null != value && remove) {
            this.currentClass.meta.remove(':native');
        }

        return value;
    }

    function pos() : Position
    {
        return Context.currentPos();
    }
}

#end
