package away3d.utils;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

class Utils {
	public static function expect<T>(obj:Dynamic, type:Class<T>):Null<T> {
		return isOfType(obj, type) ? cast obj : null;
	}
}
