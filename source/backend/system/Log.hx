package backend.system;

import haxe.PosInfos;

enum abstract LogLevel(String) from String to String {
	var INFORMATION =	"[INFORMATION]";
	var WARNING =		"[  WARNING  ]";
	var ERROR =			"[   ERROR   ]";
	var NONE =			"";
}

class Log {
	/**
	 * The original Haxe trace function.
	 * This is stored here when init is called, just in case it wants to
	 * be used again.
	 */
	public static var haxeTraceFunc:Dynamic->PosInfos->Void;

	/**
	 * Traces a regular info trace. This is an alias to `trace`.
	 */
	public static inline function info(v:Dynamic, ?infos:PosInfos) {
		__trace__(__log__formatOutputAdvanced__(v, infos));
	}

	/**
	 * Traces a warning trace. Can be called with `warn`.
	 */
	public static inline function warn(v:Dynamic, ?infos:PosInfos) {
		__trace__(__log__formatOutputAdvanced__(v, infos, WARNING));
	}

	/**
	 * Traces an error trace. Can be called with `error`.
	 */
	public static inline function error(v:Dynamic, ?infos:PosInfos) {
		__trace__(__log__formatOutputAdvanced__(v, infos, ERROR));
	}

	/**
	 * Does a plain trace with no trace position info or log type prefix.
	 * A more cross-platform version of `Sys.println`.
	 */
	public static inline function print(v:Dynamic) {
		__trace__(Std.string(v));
	}

	public static function __log__init__() {
		haxeTraceFunc = haxe.Log.trace;

		haxe.Log.trace = Log.info;
	}

	public static function __log__formatOutputAdvanced__(v:Dynamic, infos:PosInfos, logLevel:LogLevel = INFORMATION):String {
		var str:String = Std.string(v);
		if (infos == null) return Std.string(logLevel) + " " + str;

		var pstr:String = infos.fileName + (infos.lineNumber != -1 ? (":" + infos.lineNumber) : "");
		if (infos.customParams != null) {
			for (v in infos.customParams) {
				str += ", " + Std.string(v);
			}
		}

		return Std.string(logLevel) + " " + pstr + ": " + str;
	}

	public static function __trace__(str:String) {
		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(str);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(str));
		#elseif sys
		Sys.println(str);
		#elseif flash
		flash.Lib.trace(str);
		#else
		throw new haxe.exceptions.NotImplementedException();
		#end
	}
}
