package;

#if android
import android.content.Context;
#end

import backend.debug.FPSCounter;

import lime.app.Application;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import states.TitleState;

#if linux
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
#end

#if linux
@:cppInclude('./backend/external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite
{
	public static final game = {
		width: 1280, 				// WINDOW width
		height: 720, 				// WINDOW height
		initialState: TitleState, 	// initial game state
		zoom: -1.0, 				// game state bounds
		framerate: 60, 				// default framerate
		skipSplash: true, 			// if the default flixel splash screen should be skipped
		startFullscreen: false 		// if the game should start at fullscreen mode
	};
	public static final versions = {
		funkin: "0.2.8", //FNF version
		psych: "0.7.3" //Psych Engine version
	};

	/* You can pretty much ignore everything from here on - your code should go in your states. */

	public static var fpsVar:FPSCounter;
	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		// Credits to MAJigsaw77 (he's the og author for this code)
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if(hxvlc >= "1.8.0") ['--no-lua'] #end);
		#end
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void {
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();

		#if CHECK_FOR_UPDATES backend.util.OnlineUtil.loadOnlineData(); #end
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		addChild(new FridayGame(game.width, game.height, Init, #if(flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if(CRASH_HANDLER == "psych")
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if(CRASH_HANDLER == "psych")
	function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}

#if(CRASH_HANDLER == "tbar")
class FridayGame extends FlxGame
{
	public static var onGameCrash(default, null):FlxTypedSignal<(String,String)->Void> = new FlxTypedSignal<(String,String)->Void>();

	/**
	* Used to instantiate the guts of the flixel game object once we have a valid reference to the root.
	*/
	override function create(_):Void {
		try super.create(_)
		catch(e) onCrash(e);
	}

	override function onFocus(_):Void {
		try super.onFocus(_)
		catch(e) onCrash(e);
	}

	override function onFocusLost(_):Void {
		try super.onFocusLost(_)
		catch(e) onCrash(e);
	}

	/**
	* Handles the `onEnterFrame` call and figures out how many updates and draw calls to do.
	*/
	override function onEnterFrame(_):Void {
		try super.onEnterFrame(_)
		catch(e) onCrash(e);
	}

	/**
	* This function is called by `step()` and updates the actual game state.
	* May be called multiple times per "frame" or draw call.
	*/
	override function update():Void {
		try super.update()
		catch(e) onCrash(e);
	}

	/**
	* Goes through the game state and draws all the game objects and special effects.
	*/
	override function draw():Void {
		try super.draw()
		catch(e) onCrash(e);
	}

	private final function onCrash(e:haxe.Exception):Void {
		var errMsg:String = "";
		for(stackItem in haxe.CallStack.exceptionStack(true)) {
			switch(stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					trace(stackItem);
			}
		}

		if(onGameCrash != null) {
			onGameCrash.dispatch(errMsg, e.message);
		}

		flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new backend.debug.CrashHandlerState(FlxG.state, errMsg, e.message));
	}
}
#else
typedef FridayGame = flixel.FlxGame;
#end