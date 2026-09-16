package;

import flixel.FlxState;
import openfl.display.Sprite;
#if(GLOBAL_SCRIPTS && HSCRIPT_ALLOWED) 
import backend.scripts.GlobalScript;
#end
#if(MODS_ALLOWED && DISCORD_ALLOWED)
import backend.util.DiscordClient;
#end

/*
 * Making this extend FlxState instead of MusicBeatState so it doesn't load a menu script of this
 * Edit: Could've just set scriptsAllowed to false
 */
class Init extends FlxState {
    override public function create() {
        super.create();

		//Global modpack init
		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		//Global scripts
		#if(GLOBAL_SCRIPTS && HSCRIPT_ALLOWED && MODS_ALLOWED)
		if(!GlobalScript.globalScriptActive) GlobalScript.addGlobalScript();
		#end

		//Discord client
		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#if MODS_ALLOWED
		DiscordClient.loadModRPC();
		#end
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		//Save
		ClientPrefs.init();

		FlxG.switchState(Type.createInstance(Main.game.initialState, []));

		// shader coords fix
		FlxG.signals.gameResized.add(function(w:Int, h:Int) {
			if(FlxG.cameras != null) {
				for(cam in FlxG.cameras.list) {
					if(cam != null && cam.filters != null) resetSpriteCache(cam.flashSprite);
				}
			}

			if(FlxG.game != null) resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}