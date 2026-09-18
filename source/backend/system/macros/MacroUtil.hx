package backend.system.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class MacroUtil {
	/**
	 * Generates a reflection-like call method expression, primarily for
	 * `lime.system.CFFI.load`, since running it normally through scripts
	 * make the game freeze when presented with arguments.
	 *
	 * How this error is bypassed is by generating a switch case with
	 * `totalArguments` number of cases. Each case runs the literal `CFFI.load`
	 * function with the case's amount of arguments. By doing this, the CFFI
	 * function is not being ran reflectively, which allows it to pass arguments
	 * into itself.
	 *
	 * However, the switch case is not infinitely long, and is only as long as
	 * `totalArguments` is. This means that any CFFI function that has an argument
	 * count that exceeds this amount doesn't get catched by any case and throws a
	 * `Too many arguments` error.
	 */
	macro public static function generateReflectionLike(totalArguments:Int, funcName:String, argsName:String):Expr {
		#if macro
		totalArguments++;

		var funcCalls = [];
		for(i in 0...totalArguments) {
			var args = [
				for(d in 0...i) macro $i{argsName}[$v{d}]
			];

			funcCalls.push(macro $i{funcName}($a{args}));
		}

		var expr:Expr = {
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