package backend;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end
#if windows
import data.CppAPI;
#end

import FunkinLua;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;
class LuaUtil {
	public static dynamic function getDefaultLuas():Map<String, Dynamic> {
		return [
			// Lua shit
			"Function_StopLua" => FunkinLua.Function_StopLua,
			"Function_Stop" => FunkinLua.Function_Stop,
			"Function_Continue" => FunkinLua.Function_Continue,
			"luaDebugMode" => false,
			"luaDeprecatedWarnings" => true,
			"inChartEditor" => false,
			
			// Song/Week shit
			"curBpm" => Conductor.bpm,
			"crochet" => Conductor.crochet,
			"stepCrochet" => Conductor.stepCrochet,
			"songLength" => FlxG.sound.music.length,
			"startedCountdown" => false,
			
			// Camera poo
			"cameraX" => 0,
			"cameraY" => 0,
			
			// Screen stuff
			"screenWidth" => FlxG.width,
			"screenHeight" => FlxG.height,
			
			// PlayState cringe ass nae nae bullcrap
			"curBeat" => 0,
			"curStep" => 0,
			"curDecBeat" => 0,
			"curDecStep" => 0,
			
			"score" => 0,
			"misses" => 0,
			"hits" => 0,
			
			"rating" => 0,
			"ratingName" => "",
			"ratingFC" => '',
			"version" => 'tbarEngine ${MainMenuState.tbarEngineVersion.trim()}',
			"versionTBarEngine" => MainMenuState.tbarEngineVersion.trim(),

			"inGameOver" => false,
			"mustHitSection" => false,
			"altAnim" => false,
			"gfSection" => false,
			
			"healthGainMult" => PlayState.instance.healthGain,
			"healthLossMult" => PlayState.instance.healthLoss,
			"playbackRate" => PlayState.instance.playbackRate,
			"instakillOnMiss" => PlayState.instance.instakillOnMiss,
			"botPlay" => PlayState.instance.cpuControlled,
			"practice" => PlayState.instance.practiceMode,
			
			"defaultBoyfriendX" => PlayState.instance.BF_X,
			"defaultBoyfriendY" => PlayState.instance.BF_Y,
			"defaultOpponentX" => PlayState.instance.DAD_X,
			"defaultOpponentY" => PlayState.instance.DAD_Y,
			"defaultGirlfriendX" => PlayState.instance.GF_X,
			"defaultGirlfriendY" => PlayState.instance.GF_Y,
			
			"boyfriendName" => PlayState.SONG.player1,
			"dadName" => PlayState.SONG.player2,
			"gfName" => PlayState.SONG.gfVersion,
			
			"bpm" => PlayState.SONG.bpm,
			"scrollSpeed" => PlayState.SONG.speed,
			"songName" => PlayState.SONG.song,
			"songPath" => Paths.formatToSongPath(PlayState.SONG.song),
			"curStage" => PlayState.SONG.stage,
			"isStoryMode" => PlayState.isStoryMode,
			"difficulty" => PlayState.storyDifficulty,
			
			"difficultyName" => CoolUtil.difficulties[PlayState.storyDifficulty],
			"difficultyPath" => Paths.formatToSongPath(CoolUtil.difficulties[PlayState.storyDifficulty]),
			"weekRaw" => PlayState.storyWeek,
			"week" => WeekData.weeksList[PlayState.storyWeek],
			"seenCutscene" => PlayState.seenCutscene,
			
			//Settings
			"downscroll" => ClientPrefs.downScroll,
			"middlescroll" => ClientPrefs.middleScroll,
			"framerate" => ClientPrefs.framerate,
			"ghostTapping" => ClientPrefs.ghostTapping,
			"hideHud" => ClientPrefs.hideHud,
			"timeBarType" => ClientPrefs.timeBarType,
			"scoreZoom" => ClientPrefs.scoreZoom,
			"cameraZoomOnBeat" => ClientPrefs.camZooms,
			"flashingLights" => ClientPrefs.flashing,
			"noteOffset" => ClientPrefs.noteOffset,
			"healthBarAlpha" => ClientPrefs.healthBarAlpha,
			"noResetButton" => ClientPrefs.noReset,
			"lowQuality" => ClientPrefs.lowQuality,
			"shadersEnabled" => ClientPrefs.shaders,
			"currentModDirectory" => Paths.currentModDirectory,
			
			"autoPause" => ClientPrefs.autoPause,
			"fullScreen" => ClientPrefs.fullScreen,
			"windowMode" => ClientPrefs.windowMode,
			"showMemory" => ClientPrefs.showMemory,
			
			"defaultWidth" => 1280,
			"defaultHeight" => 720,
			"buildTarget" => CoolUtil.getBuildTarget()
		];
	}

	public static function implementDeprecatedFunctions(funk:FunkinLua) {
		var lua:State = funk.lua;
		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			FunkinLua.luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.getLuaObject(obj,false) != null) {
				PlayState.instance.getLuaObject(obj,false).animation.play(name, forced, false, startFrame);
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(FunkinLua.getInstance(), obj);
			if(spr != null) {
				spr.animation.play(name, forced, false, startFrame);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
			FunkinLua.luaTrace("characterPlayAnim is deprecated! Use playAnim instead", false, true);
			switch(character.toLowerCase()) {
				case 'dad':
					if(PlayState.instance.dad.animOffsets.exists(anim))
						PlayState.instance.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if(PlayState.instance.gf != null && PlayState.instance.gf.animOffsets.exists(anim))
						PlayState.instance.gf.playAnim(anim, forced);
				default:
					if(PlayState.instance.boyfriend.animOffsets.exists(anim))
						PlayState.instance.boyfriend.playAnim(anim, forced);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String) {
			FunkinLua.luaTrace("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				PlayState.instance.modchartSprites.get(tag).makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			FunkinLua.luaTrace("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var cock:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			FunkinLua.luaTrace("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var strIndices:Array<String> = indices.trim().split(',');
				var die:Array<Int> = [];
				for (i in 0...strIndices.length) {
					die.push(Std.parseInt(strIndices[i]));
				}
				var pussy:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
			FunkinLua.luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).animation.play(name, forced);
			}
		});
		Lua_helper.add_callback(lua, "setLuaSpriteCamera", function(tag:String, camera:String = '') {
			FunkinLua.luaTrace("setLuaSpriteCamera is deprecated! Use setObjectCamera instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).cameras = [FunkinLua.cameraFromString(camera)];
				return true;
			}
			FunkinLua.luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float) {
			FunkinLua.luaTrace("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "scaleLuaSprite", function(tag:String, x:Float, y:Float) {
			FunkinLua.luaTrace("scaleLuaSprite is deprecated! Use scaleObject instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var shit:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPropertyLuaSprite", function(tag:String, variable:String) {
			FunkinLua.luaTrace("getPropertyLuaSprite is deprecated! Use getProperty instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
				}
				return Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), variable);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic) {
			FunkinLua.luaTrace("setPropertyLuaSprite is deprecated! Use setProperty instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
					return true;
				}
				Reflect.setProperty(PlayState.instance.modchartSprites.get(tag), variable, value);
				return true;
			}
			FunkinLua.luaTrace("setPropertyLuaSprite: Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			FunkinLua.luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);

		});
		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
			FunkinLua.luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
		});
	}

	public static function implementCppFunctions(funk:FunkinLua) {
		var lua:State = funk.lua;

		Lua_helper.add_callback(lua, "setDarkMode", function(windowReset:Bool = true) {
			#if windows
			CppAPI.setDarkMode();
			if(windowReset) CppAPI.redrawWindowHeader();
			#else
			FunkinLua.luaTrace("setDarkMode: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "setLightMode", function(windowReset:Bool = true) {
			#if windows
			CppAPI.setLightMode();
			if(windowReset) CppAPI.redrawWindowHeader();
			#else
			FunkinLua.luaTrace("setLightMode: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "setWindowColorMode", function(isDarkMode:Bool = false, windowReset:Bool = true) {
			#if windows
			CppAPI.setWindowColorMode(isDarkMode, windowReset);
			#else
			FunkinLua.luaTrace("setWindowColorMode: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "obtainRAM", function() {
			#if windows
			return CppAPI.obtainRAM();
			#else
			FunkinLua.luaTrace("obtainRAM: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "setWindowBorderColor", function(color:String, setHeader:Bool = true, setBorder:Bool = false) {
			#if windows
			var colorNum:FlxColor = FlxColor.TRANSPARENT;
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			else colorNum = Std.parseInt(color);
				
			CppAPI.setWindowBorderColor([colorNum.red, colorNum.green, colorNum.blue, colorNum.alpha], setHeader, setBorder);
			#else
			FunkinLua.luaTrace("setWindowBorderColor: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "setWindowTitleColor", function(color:String) {
			#if windows
			var colorNum:FlxColor = FlxColor.TRANSPARENT;
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			else colorNum = Std.parseInt(color);

			CppAPI.setWindowTitleColor([colorNum.red, colorNum.green, colorNum.blue, colorNum.alpha]);
			#else
			FunkinLua.luaTrace("setWindowTitleColor: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "resetWindowBorderColor", function(setHeader:Bool = true, setBorder:Bool = false) {
			#if windows
			CppAPI.setWindowBorderColor([-1, -1, -1, -1], setHeader, setBorder);
			#else
			FunkinLua.luaTrace("resetWindowBorderColor: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "resetWindowTitleColor", function() {
			#if windows
			CppAPI.setWindowTitleColor([-1, -1, -1, -1]);
			#else
			FunkinLua.luaTrace("resetWindowTitleColor: C++ Bindings aren't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "redrawWindowHeader", function() {
			CppAPI.redrawWindowHeader();
		});

		Lua_helper.add_callback(lua, "hasOsVersion", function(version:String = "Windows 10") {
			CppAPI.hasWindowsVersion(version);
		});
	}
}