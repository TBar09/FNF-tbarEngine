package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;

#if desktop
import Discord.DiscordClient;
#end

//crash handler stuff
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);

		#if VIDEOS_ALLOWED //I wish I knew what this did
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
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
		
		//Loading up stuff
		ClientPrefs.loadDefaultKeys();
		backend.OnlineUtil.loadOnlinePrefs();
		#if CRASH_HANDLER
		addChild(new FridayGame(game.width, game.height, MainState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		#else
		addChild(new FlxGame(game.width, game.height, MainState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		#end
		
		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) fpsVar.visible = ClientPrefs.showFPS;
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if !CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if desktop
		DiscordClient.prepare();
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if !CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "TBarEngine_" + dateNow + ".txt";

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

		errMsg += "\nUncaught Error: " + e.error + "\nWhoops! Looks like the T-Bar Engine has crashed!\nPlease report this error to the T-Bar Engine GitHub page:\n" + OnlineData.MainEngineWebsite + "\n\nYou can look at the crash dump above\nor press the button on this window to exit the game.\n(Crash Handler written by T-Bar)";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "T-Bar Engine Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}

class MainState extends FlxState {
	override function create() {
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		PlayerSettings.init();
		FlxG.mouse.visible = false;
		
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		
		#if LUA_ALLOWED Paths.pushGlobalMods(); #end
		WeekData.loadTheFirstEnabledMod(); //Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		#if GLOBAL_SCRIPTS 
		if(!hscript.ScriptGlobal.globalScriptActive) hscript.ScriptGlobal.addGlobalScript();
		#end

		FlxG.switchState(new TitleState());
		super.create();
	}
}

#if CRASH_HANDLER
//Thanks to Sonic Legacy for the crash handler code!
class FridayGame extends FlxGame
{
	public static var onGameCrash:(errMsg:String, crashDump:String) -> Void;

	/**
	* Used to instantiate the guts of the flixel game object once we have a valid reference to the root.
	*/
	override function create(_):Void {
		try super.create(_)
		catch (e) onCrash(e);
	}

	override function onFocus(_):Void {
		try super.onFocus(_)
		catch (e) onCrash(e);
	}

	override function onFocusLost(_):Void {
		try super.onFocusLost(_)
		catch (e) onCrash(e);
	}

	/**
	* Handles the `onEnterFrame` call and figures out how many updates and draw calls to do.
	*/
	override function onEnterFrame(_):Void {
		try super.onEnterFrame(_)
		catch (e) onCrash(e);
	}

	/**
	* This function is called by `step()` and updates the actual game state.
	* May be called multiple times per "frame" or draw call.
	*/
	override function update():Void {
		try super.update()
		catch (e) onCrash(e);
	}

	/**
	* Goes through the game state and draws all the game objects and special effects.
	*/
	override function draw():Void {
		try super.draw()
		catch (e) onCrash(e);
	}

	private final function onCrash(e:haxe.Exception):Void {
		var errMsg:String = "";
		for (stackItem in haxe.CallStack.exceptionStack(true)) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
					trace(stackItem);
			}
		}
		
		if(onGameCrash != null) onGameCrash(errMsg, e.message);
		
		flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new backend.CrashHandlerState(FlxG.state, errMsg, e.message));
	}
}
#end