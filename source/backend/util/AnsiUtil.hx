package backend.util;

import backend.macros.MacroUtil;
import haxe.PosInfos;
import haxe.Log;

/*
 * For colorful console tracing, since HScript doesn't support the ANSI escape key.
 * TODO: Support more ansi functions.
 */
class AnsiUtil {
	public static var ansiKeys:Map<String, AnsiColor> = [
		//Normal ansi colors
		"<ansi::black>" => BLACK,
		"<ansi::red>" => RED,
		"<ansi::green>" => GREEN,
		"<ansi::yellow>" => YELLOW,
		"<ansi::blue>" => BLUE,
		"<ansi::magenta>" => MAGENTA,
		"<ansi::cyan>" => CYAN,
		"<ansi::white>" => WHITE,
		"<ansi::reset>" => RESET,
		"<ansi::default>" => DEFAULT,

		//Background colors
		"<ansi::black:bg>" => BG_BLACK,
		"<ansi::red:bg>" => BG_RED,
		"<ansi::green:bg>" => BG_GREEN,
		"<ansi::yellow:bg>" => BG_YELLOW,
		"<ansi::blue:bg>" => BG_BLUE,
		"<ansi::magenta:bg>" => BG_MAGENTA,
		"<ansi::cyan:bg>" => BG_CYAN,
		"<ansi::white:bg>" => BG_WHITE,
		"<ansi::default:bg>" => BG_DEFAULT
	];

	inline public static function ansiTrace(str:String, ?haxeTrace:Bool = false, ?posInfos:PosInfos) {
		if(haxeTrace) Log.trace(formatString(str), posInfos);
		else MacroUtil.print(formatString(str));
	}

	public static function consoleColorToInt(color:AnsiColor):Int {
		return switch(color) {
			case BLACK: 30;
			case RED: 31;
			case GREEN: 32;
			case YELLOW: 33;
			case BLUE: 34;
			case MAGENTA: 35;
			case CYAN: 36;
			case WHITE: 37;
			case DEFAULT: 39;
			case BG_BLACK: 40;
			case BG_RED: 41;
			case BG_GREEN: 42;
			case BG_YELLOW: 43;
			case BG_BLUE: 44;
			case BG_MAGENTA: 45;
			case BG_CYAN: 46;
			case BG_WHITE: 47;
			case BG_DEFAULT: 49;
			case BOLD: 1;
			default: 0; // Also accounts for RESET
		}
	}

	public static function formatString(str:String):String {
		for(key => color in ansiKeys) {
			if(str.contains(key)) str = str.replace(key, color);
		}
		return str;
	}
}

enum abstract AnsiColor(String) to String from String {
	var BG_BLACK = '\033[30;40m';
	var BG_RED = '\033[30;41m';
	var BG_GREEN = '\033[30;42m';
	var BG_YELLOW = '\033[30;43m';
	var BG_BLUE = '\033[30;44m';
	var BG_MAGENTA = '\033[30;45m';
	var BG_CYAN = '\033[30;46m';
	var BG_WHITE = '\033[30;47m';
	var BG_DEFAULT = '\033[30;49m';
	var BLACK = '\033[30;30m';
	var RED = '\033[30;31m';
	var GREEN = '\033[30;32m';
	var YELLOW = '\033[30;33m';
	var BLUE = '\033[30;34m';
	var MAGENTA = '\033[30;35m';
	var CYAN = '\033[30;36m';
	var WHITE = '\033[30;37m';
	var DEFAULT = '\033[30;39m';
	var BOLD = '\033[30;1m';
	var RESET = '\033[30;0m';
}
