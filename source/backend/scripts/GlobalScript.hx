package backend.scripts;

import flixel.FlxG;
#if sys
import sys.FileSystem;
#end
#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end

class GlobalScript {
	#if(GLOBAL_SCRIPTS && HSCRIPT_ALLOWED && MODS_ALLOWED)
	public static var globalScript:HScript;
	public static var globalScriptActive:Bool = false;

	public static function addGlobalScript() {
		var foldersToCheck = Mods.directoriesWithFile('', 'states/');

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (!globalScriptActive && file.toLowerCase().endsWith('global' + Paths.HSCRIPT_EXT)) {
						globalScript = new HScript(folder + file);
						globalScriptActive = true;
						break; //We only want one global script active at a time, Usually the upmost important mod that's enabled.
					}
				}
			}
		}

		if(globalScriptActive && globalScript != null) {
			FlxG.signals.focusGained.add(function() {
				if(globalScriptActive) globalScript.call("onFocusGained", []);
			});
			
			FlxG.signals.focusLost.add(function() {
				if(globalScriptActive) globalScript.call("onFocusLost", []);
			});

			FlxG.signals.gameResized.add(function(width:Int, height:Int) {
				if(globalScriptActive) globalScript.call("onGameResized", [width, height]);
			});

			FlxG.signals.postGameStart.add(function() {
				if(globalScriptActive) globalScript.call("onGameStart", []);
			});

			FlxG.signals.preGameReset.add(function() {
				if(globalScriptActive) globalScript.call("onGameReset", []);
			});

			FlxG.signals.postGameReset.add(function() {
				if(globalScriptActive) globalScript.call("onGameResetPost", []);
			});

			FlxG.signals.preStateSwitch.add(function() {
				if(globalScriptActive) globalScript.call("onStateSwitch", []);
			});

			FlxG.signals.postStateSwitch.add(function() {
				if(globalScriptActive) globalScript.call("onStateSwitchPost", []);
			});

			FlxG.signals.preStateCreate.add(function(state:flixel.FlxState) {
				if(globalScriptActive) globalScript.call("onStateCreate", [state]);
			});

			//Update signals

			FlxG.signals.preDraw.add(function() {
				if(globalScriptActive) globalScript.call("onDraw", []);
			});

			FlxG.signals.postDraw.add(function() {
				if(globalScriptActive) globalScript.call("onDrawPost", []);
			});

			FlxG.signals.preUpdate.add(function() {
				if(globalScriptActive) globalScript.call("onUpdate", [FlxG.elapsed]);
			});

			FlxG.signals.postUpdate.add(function() {
				if(globalScriptActive) globalScript.call("onUpdatePost", [FlxG.elapsed]);
			});

			globalScript.call("onCreatePost", []);
		}
	}

	public static function callGlobalScript(callback:String, args:Array<Dynamic>):Dynamic
		return (globalScript != null && globalScriptActive) ? globalScript.call(callback, args) : null;

	public static function destroyModScript() {
		if(globalScript != null && globalScriptActive) {
			globalScript.call("onDestroy", []);
			globalScript.stop();
			globalScript = null;

			globalScriptActive = false;
		}
	}
	
	#else
	public static function addGlobalScript() {
		//throw "Global scripts are not supported on this platform!";
	}

	public static function callGlobalScript(callback:String, args:Array<Dynamic>):Dynamic { return null; }
	public static function destroyModScript() {}
	#end
}

typedef ScriptGlobal = GlobalScript;