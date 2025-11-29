package psychlua;

import flixel.util.FlxSave;
import openfl.utils.Assets;
import openfl.Lib;

/*
 * Things to trivialize some dumb stuff like splitting strings on older Lua
 */
class ExtraFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		// Keyboard & Gamepads
		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String) return FlxG.gamepads.anyJustPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String) FlxG.gamepads.anyPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String) return FlxG.gamepads.anyJustReleased(name));

		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return PlayState.instance.controls.NOTE_LEFT_P;
				case 'down': return PlayState.instance.controls.NOTE_DOWN_P;
				case 'up': return PlayState.instance.controls.NOTE_UP_P;
				case 'right': return PlayState.instance.controls.NOTE_RIGHT_P;
				default: return PlayState.instance.controls.justPressed(name);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return PlayState.instance.controls.NOTE_LEFT;
				case 'down': return PlayState.instance.controls.NOTE_DOWN;
				case 'up': return PlayState.instance.controls.NOTE_UP;
				case 'right': return PlayState.instance.controls.NOTE_RIGHT;
				default: return PlayState.instance.controls.pressed(name);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return PlayState.instance.controls.NOTE_LEFT_R;
				case 'down': return PlayState.instance.controls.NOTE_DOWN_R;
				case 'up': return PlayState.instance.controls.NOTE_UP_R;
				case 'right': return PlayState.instance.controls.NOTE_RIGHT_R;
				default: return PlayState.instance.controls.justReleased(name);
			}
			return false;
		});

		// Save data management
		Lua_helper.add_callback(lua, "initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
			if(!PlayState.instance.modchartSaves.exists(name))
			{
				var save:FlxSave = new FlxSave();
				// folder goes unused for flixel 5 users. @BeastlyGhost
				save.bind(name, CoolUtil.getSavePath() + '/' + folder);
				PlayState.instance.modchartSaves.set(name, save);
				return;
			}
			FunkinLua.luaTrace('initSaveData: Save file already initialized: ' + name);
		});
		Lua_helper.add_callback(lua, "flushSaveData", function(name:String) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).flush();
				return;
			}
			FunkinLua.luaTrace('flushSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic = null) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				var saveData = PlayState.instance.modchartSaves.get(name).data;
				if(Reflect.hasField(saveData, field))
					return Reflect.field(saveData, field);
				else
					return defaultValue;
			}
			FunkinLua.luaTrace('getDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
			return defaultValue;
		});
		Lua_helper.add_callback(lua, "setDataFromSave", function(name:String, field:String, value:Dynamic) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				Reflect.setField(PlayState.instance.modchartSaves.get(name).data, field, value);
				return;
			}
			FunkinLua.luaTrace('setDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "eraseSaveData", function(name:String)
		{
			if (PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).erase();
				return;
			}
			FunkinLua.luaTrace('eraseSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});

		// File management
		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false) {
			#if MODS_ALLOWED
			if(absolute)
			{
				return FileSystem.exists(filename);
			}

			var path:String = Paths.modFolders(filename);
			if(FileSystem.exists(path))
			{
				return true;
			}
			return FileSystem.exists(Paths.getPath('assets/$filename', TEXT));
			#else
			if(absolute)
			{
				return Assets.exists(filename);
			}
			return Assets.exists(Paths.getPath('assets/$filename', TEXT));
			#end
		});
		Lua_helper.add_callback(lua, "saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try {
				#if MODS_ALLOWED
				if(!absolute)
					File.saveContent(Paths.mods(path), content);
				else
				#end
					File.saveContent(path, content);

				return true;
			} catch (e:Dynamic) {
				FunkinLua.luaTrace("saveFile: Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "deleteFile", function(path:String, ?ignoreModFolders:Bool = false)
		{
			try {
				#if MODS_ALLOWED
				if(!ignoreModFolders)
				{
					var lePath:String = Paths.modFolders(path);
					if(FileSystem.exists(lePath))
					{
						FileSystem.deleteFile(lePath);
						return true;
					}
				}
				#end

				var lePath:String = Paths.getPath(path, TEXT);
				if(Assets.exists(lePath))
				{
					FileSystem.deleteFile(lePath);
					return true;
				}
			} catch (e:Dynamic) {
				FunkinLua.luaTrace("deleteFile: Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
			return Paths.getTextFromFile(path, ignoreModFolders);
		});
		Lua_helper.add_callback(lua, "directoryFileList", function(folder:String) {
			var list:Array<String> = [];
			#if sys
			if(FileSystem.exists(folder)) {
				for (folder in FileSystem.readDirectory(folder)) {
					if (!list.contains(folder)) {
						list.push(folder);
					}
				}
			}
			#end
			return list;
		});

		// String tools
		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String) {
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String) {
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "stringSplit", function(str:String, split:String) {
			return str.split(split);
		});
		Lua_helper.add_callback(lua, "stringTrim", function(str:String) {
			return str.trim();
		});

		// Randomization
		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '') break;
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '') break;
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});
	}

	public static function addTBarEngineCallbacks(lua:State) {
		if(lua == null) return;

		Lua_helper.add_callback(lua, "doTweenNumber", function(tag:String, fromNumber:Float, toNumber:Float, duration:Float = 1, ease:String, ?mode:String) {
			PlayState.instance.modchartTweens.set(tag, FlxTween.num(fromNumber, toNumber, duration, {ease: LuaUtils.getTweenEaseByString(ease), type: LuaUtils.getTweenTypeByString(mode), onComplete:
				function(twn:FlxTween){
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					PlayState.instance.modchartTweens.remove(tag);
				}
			},
				function(num) { PlayState.instance.callOnLuas('onNumberTweenUpdate', [tag, num]); }
			));
		});

		Lua_helper.add_callback(lua, "browserLoad", CoolUtil.browserLoad);

		Lua_helper.add_callback(lua, "getDataFromURL", function(url:String) {
			if(url == null) return null;

			var http = new haxe.Http(url.toString());
			http.onData = function(data:String) {
				return data;
			}
			http.onError = function(error) {
				FunkinLua.luaTrace('getDataFromURL: ${error}', false, false, FlxColor.RED);
			}
			http.request();

			return null;
		});

		Lua_helper.add_callback(lua, "parseJSON", function(str:String):Dynamic {
			return #if tjson tjson.TJSON.parse(str) #else haxe.Json.parse(str) #end;
		});
	}

	public static function addGhostutilWindowCallbacks(lua:State) {
		if(lua == null) return;

		Lua_helper.add_callback(lua, "setWindowPosition", function(?xValue:Int = 0, ?yValue:Int = 0) {
			#if windows
			FlxG.stage.window.x = xValue;
			FlxG.stage.window.y = yValue;
			#end
		});

		Lua_helper.add_callback(lua, "windowScreenCenter", function(?axis:String = 'xy') {
			#if windows
			if (axis.toLowerCase().contains('x'))
				FlxG.stage.window.x = Std.int((Std.int(Lib.application.window.display.bounds.width) - FlxG.stage.window.width) / 2);

			if (axis.toLowerCase().contains('y'))
				FlxG.stage.window.y = Std.int((Std.int(Lib.application.window.display.bounds.height) - FlxG.stage.window.height) / 2);
			#end
		});

		Lua_helper.add_callback(lua, "setWindowProperty", function(property:String, ?newValue:Dynamic) {
			#if windows
			if(property == null) {
				FunkinLua.luaTrace('setWindowProperty: Unknown value or nil value "${newValue}"', false, false, FlxColor.RED);
				return;
			}

			switch(property.toLowerCase()) {
				case 'borderless': FlxG.stage.window.borderless = newValue;
				case 'height': FlxG.stage.window.height = newValue;
				case 'width': FlxG.stage.window.width = newValue;
				case 'x': FlxG.stage.window.x = newValue;
				case 'y': FlxG.stage.window.y = newValue;
				case 'fullscreen': FlxG.stage.window.fullscreen = newValue;
				case 'title': FlxG.stage.window.title = newValue;
				case 'resizable': FlxG.stage.window.resizable = newValue;
			}
			#end
		});

		Lua_helper.add_callback(lua, "windowAlert", function(?msg:String, ?title:String) {
			if(!(FlxG.fullscreen || FlxG.stage.window.maximized) && (msg != null && title != null))
				FlxG.stage.window.alert(msg, title);
		});

		Lua_helper.add_callback(lua, "windowTweenResize", function(tag:String, targetDimensions:Array<Int>, duration:Float = 1, ease:String = 'linear') {
			#if windows
			if(targetDimensions.length != 2) return;

			PlayState.instance.modchartTweens.set(tag, FlxTween.tween(FlxG.stage.window, {width: Std.int(targetDimensions[0]), height: Std.int(targetDimensions[1])}, duration, {
				ease: LuaUtils.getTweenEaseByString(ease), 
				onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
			}));
			#end
		});

		Lua_helper.add_callback(lua, "windowTweenX", function(tag:String, value:Int, duration:Float, ease:String = 'linear') {
			#if windows
			PlayState.instance.modchartTweens.set(tag, FlxTween.tween(FlxG.stage.window, {x: value}, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(twn:FlxTween){
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					PlayState.instance.modchartTweens.remove(tag);
				}
			}));
			#end
		});

		Lua_helper.add_callback(lua, "windowTweenY", function(tag:String, value:Int, duration:Float, ease:String = 'linear') {
			#if windows
			PlayState.instance.modchartTweens.set(tag, FlxTween.tween(FlxG.stage.window, {y: value}, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(twn:FlxTween){
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					PlayState.instance.modchartTweens.remove(tag);
				}
			}));
			#end
		});

		Lua_helper.add_callback(lua, "setWindowTitle", function(title:String) {
			#if windows
			FlxG.stage.window.title = (title == null ? Lib.application.meta["name"] : title.toString());
			#end
		});
	}
}
