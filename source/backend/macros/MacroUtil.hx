package backend.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

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
	
	
}
