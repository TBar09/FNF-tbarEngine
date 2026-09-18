package backend.system.macros;

#if macro
import haxe.macro.Compiler;
#end

final class IncludeMacro {
	public static final addonClasses:Array<String> = [
		#if (IMPORT_AWAY3D && AWAY3D_ALLOWED && away3d)
		"away3d",
		"flixel.flx3d",
		#end
		#if (VIDEOS_ALLOWED && hxvlc)
		"hxvlc.flixel",
		#end
		"objects",
		"backend"
	];

	@:dox(hide) @:unreflective
	public static function compile() {
		#if macro
		for(pack in addonClasses) {
			Compiler.keep(pack);
			Compiler.include(pack);
		}
		#end
	}
}