package;

import flixel.util.FlxSave;
import flixel.FlxG;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.system.FlxSound;
import lime.app.Application;
import openfl.display.BlendMode;
import animateatlas.AtlasFrameMaker;
import Type.ValueType;
import flixel.util.FlxColor;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode
	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
		return difficulties[PlayState.storyDifficulty].toUpperCase();

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length) daList[i] = daList[i].trim();

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length) daList[i] = daList[i].trim();

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel != 0){
					if(countByColor.exists(colorOfThisPixel)){
						countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
					}else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max) {
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//T-BAR ENGINE FUNCTIONS//

	//Thanks to Ghostglowdev for this. I forgot Reflect.fields was a thing
	public static function structToMap(struct:Dynamic) {
		var map = new Map<String, Dynamic>();
    	for (key in Reflect.fields(struct)) map.set(key, Reflect.field(struct, key));
    	return map;
  	}
	
	public static dynamic function resetGame() {
		TitleState.initialized = false;
		TitleState.closedState = false;
		OutdatedState.leftState = false;
		FlxG.sound.music.fadeOut(0.3);
		if(FreeplayState.vocals != null)
		{
			FreeplayState.vocals.fadeOut(0.3);
			FreeplayState.vocals = null;
		}
		FlxG.camera.fade(0xFF000000, 0.5, false, function() {
			#if GLOBAL_SCRIPTS hscript.ScriptGlobal.destroyModScript(); #end
			FlxG.resetGame();
		}, false);
  	}
	
	inline static public function getBuildTarget() {
		#if windows
		return 'windows';
		#elseif linux
		return 'linux';
		#elseif mac
		return 'mac';
		#elseif html5
		return 'browser';
		#elseif android
		return 'android';
		#elseif ios
		return 'ios';
		#else
		return 'unknown';
		#end
	}

	#if HXSCRIPT_ALLOWED
	public static dynamic function getHScriptPreprocessors() {
		var preprocessors:Map<String, Dynamic> = backend.macros.MacroUtil.defines;
		preprocessors.set("CODENAME_ENGINE", false);

		return preprocessors;
	}
	#end
	
	//still learning this stuff, just took it from the DDT+ mod, so props to them
	
	//company can be found in the source through the project.xml, people usually keep it as ShadowMario
	//title is exactly what you think it is, the name of the .exe file, WITHOUT THE EXE EXTENSION
	/**
		* Check for an existing HaxeFlixel save file.
		*
		* @param   company		The company of the HaxeFlixel title, required for saves before 5.0.0+.
		* @param   title		The title/name of the HaxeFlixel title, required for saves before 5.0.0+.
		* @param   localPath	The path of the save file.
		* @param   name			The name of the save file.
		* @param   newPath		Whether or not the save file is from a HaxeFlixel title that's on 5.0.0+.
	**/
	public static function flixelSaveCheck(company:String, title:String, localPath:String = 'ninjamuffin99', name:String = 'funkin', newPath:Bool = false, underFlixel5:Bool = false):Bool
	{
		// FlxSave stuff
		var invalidChars = ~/[ ~%&\\;:"',<>?#]+/;

		// Avoid checking for .sol files directly in AppData
		if (localPath == "")
		{
			var path = company;

			if (path == null || path == "")
				path = "HaxeFlixel";
			else
			{
				#if html5
				// most chars are fine on browsers
				#else
				path = invalidChars.split(path).join("-");
				#end
			}

			localPath = path;
		}

		var directory = lime.system.System.applicationStorageDirectory;
		var path = '';

		if (newPath)
			path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		else
			path = haxe.io.Path.normalize(underFlixel5 ? '$directory/../../../$company/$title/$localPath' + "/" : '$directory/../../../$company/$title/$localPath' + "/");

		name = StringTools.replace(name, "//", "/");

		if (StringTools.startsWith(name, "/")) name = name.substr(1);
		if (StringTools.endsWith(name, "/")) name = name.substring(0, name.length - 1);

		if (name.indexOf("/") > -1) {
			var split = name.split("/");
			name = "";

			for (i in 0...(split.length - 1)) {
				name += "#" + split[i] + "/";
			}

			name += split[split.length - 1];
		}

		return #if sys FileSystem.exists(path + name + ".sol") #else Assets.exists(path + name + ".sol") #end;
	}
	
	public static function openPizzaHut() browserLoad("https://www.pizzahut.com/");
	
	public static dynamic function hxTrace(text:Dynamic, color:FlxColor) {
		if(FlxG.state is PlayState) PlayState.instance.addTextToDebug(Std.string(text), color);
		else trace(text);
	}

	//END//

	//Base game thank you
	public static function coolLerp(base:Float, target:Float, ratio:Float):Float
		return base + cameraLerp(ratio) * (target - base);

	public static function cameraLerp(lerp:Float):Float
		return lerp * (FlxG.elapsed / (1 / 60));

	#if HXSCRIPT_ALLOWED
	/**
	 * Gets the macro class created by hscript-improved for an abstract / enum
	 */
	@:noUsing public static inline function getMacroAbstractClass(className:String) return Type.resolveClass('${className}_HSC');
	#end

	public static function getModSetting(saveTag:String, ?modName:String = null)
	{
		#if MODS_ALLOWED
		if(FlxG.save.data.modSettings == null) FlxG.save.data.modSettings = new Map<String, Dynamic>();
		var settings:Map<String, Dynamic> = FlxG.save.data.modSettings.get(modName);
		
		var path:String = Paths.mods('$modName/data/settings.json');
		if(FileSystem.exists(path))
		{
			if(settings == null || !settings.exists(saveTag))
			{
				if(settings == null) settings = new Map<String, Dynamic>();
				try
				{
					var parsedJson:Dynamic = haxe.Json.parse(#if sys File.getContent(path) #else Assets.getText(path) #end);
					for (i in 0...parsedJson.length)
					{
						var sub:Dynamic = parsedJson[i];
						if(sub != null && sub.save != null && !settings.exists(sub.save))
						{
							if(sub.type != 'keybind' && sub.type != 'key')
							{
								if(sub.value != null)
								{
									//FunkinLua.luaTrace('getModSetting: Found unsaved value "${sub.save}" in Mod: "$modName"');
									settings.set(sub.save, sub.value);
								}
							}
							else
							{
								//FunkinLua.luaTrace('getModSetting: Found unsaved keybind "${sub.save}" in Mod: "$modName"');
								settings.set(sub.save, {keyboard: (sub.keyboard != null ? sub.keyboard : 'NONE'), gamepad: (sub.gamepad != null ? sub.gamepad : 'NONE')});
							}
						}
					}
					FlxG.save.data.modSettings.set(modName, settings);
				} catch(e:Dynamic) {
					var errorTitle = 'Mod name: ' + Paths.currentModDirectory;
					var errorMsg = 'An error occurred: $e';
					#if windows
					flixel.FlxG.stage.window.alert(errorMsg, errorTitle);
					#end
					trace('$errorTitle - $errorMsg');
				}
			}
		}
		else
		{
			FlxG.save.data.modSettings.remove(modName);
			#if (LUA_ALLOWED || HXSCRIPT_ALLOWED)
			CoolUtil.hxTrace('getModSetting: $path could not be found!', 0xFFFF0000);
			#else
			FlxG.log.warn('getModSetting: $path could not be found!');
			#end
			return null;
		}

		if(settings.exists(saveTag)) return settings.get(saveTag);
		#if (LUA_ALLOWED || HXSCRIPT_ALLOWED)
		CoolUtil.hxTrace('getModSetting: "$saveTag" could not be found inside $modName\'s settings!', 0xFFFF0000);
		#else
		FlxG.log.warn('getModSetting: "$saveTag" could not be found inside $modName\'s settings!');
		#end
		#end
		return null;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
		Paths.sound(sound, library);

	public static function precacheMusic(sound:String, ?library:String = null):Void
		Paths.music(sound, library);

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	public static function getSavePath(folder:String = 'TBarEngine'):String {
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
}
