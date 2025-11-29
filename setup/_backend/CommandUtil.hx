package _backend;

import haxe.Log;
#if macro
import haxe.macro.Context;
#end

class CommandUtil {
	public static var defines(get, null):Map<String, Dynamic>;
	private static inline function get_defines() return __getDefines();
	private static macro function __getDefines()
		#if display return macro $v{[]}; #else return macro $v{Context.getDefines()}; #end

	public static function print(str:Dynamic) {
		Log.trace(Std.string(str), null);
	}
}