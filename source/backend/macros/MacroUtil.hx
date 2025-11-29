package backend.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
#end

#if js
import js.Browser;
#end
import haxe.Log;

class MacroUtil {
	public static var defines(get, null):Map<String, Dynamic>;
	private static inline function get_defines() return __getDefines();
	private static macro function __getDefines() {
		#if display
		return macro $v{[]};
		#else
		return macro $v{Context.getDefines()};
		#end
	}

	//Thanks to the developers of codename for this function!
	macro public static function generateReflectionLike(totalArguments:Int, funcName:String, argsName:String) {
		#if macro
		totalArguments++;

		var funcCalls = [];
		for(i in 0...totalArguments) {
			var args = [
				for(d in 0...i) macro $i{argsName}[$v{d}]
			];

			funcCalls.push(macro $i{funcName}($a{args}));
		}

		var expr = {
			pos: Context.currentPos(),
			expr: ESwitch(
				macro ($i{argsName}.length),
				[
					for(i in 0...totalArguments) {
						values: [macro $v{i}],
						expr: funcCalls[i],
						guard: null,
					}
				],
				macro throw "Too many arguments"
			)
		}

		return expr;
		#end
	}

	public static final addonClasses:Array<String> = [
		#if (IMPORT_AWAY3D && AWAY3D_ALLOWED && away3d) "away3d", "flixel.flx3d", #end
		#if (VIDEOS_ALLOWED && hxvlc) "hxvlc.flixel", #end
		"objects",
		"backend"
	];
	@:unreflective public static function includeClasses() {
		#if macro
		for(classPackage in addonClasses) Compiler.include(classPackage);
		#end
	}

	/*
	 * USED FOR COMPILING THE FORK
	 */
	@:unreflective public static function compileMacros() {
		#if macro
		print('Compiling T-Bar Engine v2.0, please wait...');

		#if(haxe != "4.2.5" && !(haxe >= "4.3.0"))
		final defineMap = Context.getDefines();
		print('_______________________________WARNING_______________________________
You are currently using haxe version ${defineMap.get("haxe")}
T-Bar Engine has only been tested with version 4.2.5 and may break with
other haxe versions (haxe 4.3.X is also compatible with compiling).
		');

		print('Proceeding...');
		#end

		/* Setting up other internal things */

		//since using `#if 32bits` throws an error
		if(Context.defined("32bits")) {
			Compiler.define("TBAR_ENGINE_32BITS", "1");
			Compiler.define("x86_BUILD", "1"); //Psych 1.0 exclusive preprocessor
		}

		if(Context.defined("hscript_improved_dev"))
			Compiler.define("hscript-improved", "1");

		if(Context.defined("WATERMARKS")) {
			if(Context.definedValue("WATERMARKS") == "tbar") Compiler.define("TBAR_WATERMARKS", "1");
			else if(Context.definedValue("WATERMARKS") == "psych") Compiler.define("PSYCH_WATERMARKS", "1");
		}

		#if(desktop || (android || ios))
		Compiler.include("backend.external.ALSoftConfig"); //Just to make sure it gets included
		#end

		//Include additional classes to help with hscript. Comment this out if you want shorten the compile time
		includeClasses();
		#end
	}

	@:dox(hide) public static function print(str:String) {
		#if js
		if(Browser.console != null) Browser.console.log(str);
		#elseif sys
		Sys.println(str);
		#else
		Log.trace(str, null);
		#end
	}
}