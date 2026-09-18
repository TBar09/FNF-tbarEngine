package backend.system.macros;

#if macro
import haxe.macro.Compiler as HaxeCompiler;
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class CompilerMacro {
	public static var defines(get, null):Map<String, Dynamic>;

	@:dox(hide) @:unreflective
	public static function compile() {
		#if macro
		// Since using `#if 32bits` throws an error
		if(Context.defined("32bits")) {
			HaxeCompiler.define("TBAR_ENGINE_32BITS", "1");
			HaxeCompiler.define("x32", "1");
			HaxeCompiler.define("x86_BUILD", "1"); // Used in Psych 1.0
		}

		if(Context.defined("hscript_improved_dev")) {
			var hscriptValue:String = Context.definedValue("hscript_improved_dev");

			HaxeCompiler.define("hscript-improved", hscriptValue);
			HaxeCompiler.define("hscript", hscriptValue);
		}

		if(Context.defined("WATERMARKS")) {
			var watermarkValue:String = Context.definedValue("WATERMARKS");

			if(watermarkValue == "tbar") HaxeCompiler.define("TBAR_WATERMARKS", "1");
			else if(watermarkValue == "psych") HaxeCompiler.define("PSYCH_WATERMARKS", "1");
		}

		#if(desktop || (android || ios))
		HaxeCompiler.include("backend.external.ALSoftConfig"); //Just to make sure it gets included
		#end
		#end
	}

	static inline function get_defines() { return __getDefines(); }
	private static macro function __getDefines() {
		#if display
		return macro $v{[]};
		#else
		var __defines:Map<String, String> = Context.getDefines();

		//Removes any unnecessary defines from the compiled version
		//(Also because these contains things like username and personal file paths)
		if(__defines.exists("ANDROID_NDK_ROOT")) __defines.remove("ANDROID_NDK_ROOT");
		if(__defines.exists("ANDROID_SETUP")) __defines.remove("ANDROID_SETUP");
		if(__defines.exists("ANDROID_SDK")) __defines.remove("ANDROID_SDK");
		if(__defines.exists("JAVA_HOME")) __defines.remove("JAVA_HOME");

		return macro $v{__defines};
		#end
	}
}