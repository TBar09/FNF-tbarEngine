package hscript;

class Config {
	// Runs support for custom classes in these
	public static final ALLOWED_CUSTOM_CLASSES = [
		"flixel",
		"backend",
		"shaders",
		"psychlua",
		"options",
		"objects"
	];

	// Runs support for abstract support in these
	public static final ALLOWED_ABSTRACT_AND_ENUM = [
		"backend",
		"flixel",
		"haxe.xml",
		"haxe.CallStack",
		"openfl",
		"openfl.display.BlendMode"
	];

	// Incase any of your files fail
	// These are the module names
	public static final DISALLOW_CUSTOM_CLASSES = [
		"flixel.FlxGame",
		"flixel.addons.ui.FlxUI9SliceSprite",
		"flixel.addons.ui.FlxUIList",
		"flixel.addons.ui.FlxUINumericStepper"
	];

	public static final DISALLOW_ABSTRACT_AND_ENUM = [

	];
}