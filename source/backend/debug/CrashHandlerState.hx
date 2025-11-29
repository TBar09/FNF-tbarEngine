package backend.debug;

import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import backend.util.OnlineUtil;
#if(CRASH_HANDLER && sys)
import backend.macros.MacroUtil;
import haxe.CallStack;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
#end

class CrashHandlerState extends MusicBeatState
{
	public static var returnBPM:Float = 100;

	public var canLeave:Bool = false;

	var error:String;
	var errorName:String;

	public var bgError:FlxSprite;
	public var errorTxt:FlxText;
	#if(CRASH_HANDLER && sys)
	public var saveCrashTxt:FlxText;
	public var crashDumpSaved:Bool = false;
	#end

	public function new(prevState:FlxState, error:String, errorName:String):Void {
        this.error = error;
        this.errorName = errorName;
        super();
	}

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		var engineSite:String = (OnlineUtil.onlineData.get("modWebsite")[0].length > 0) ? OnlineUtil.onlineData.get("modWebsite")[0] : "https://github.com/TBar09/FNF-tbarEngine/";
		FlxG.sound.playMusic(null, 0);

		var errorText = "<red>* WHOOPS! T-BAR ENGINE HAS CRASHED *\n* " + errorName + " *<red>\n\nPlease take a screenshot of the error below and\ncreate a new issues page on the T-Bar Engine github\n<hyperlink>" + engineSite + "<hyperlink>\n\n" + errorName + ": " + error + "\n\n > Press any key to go to the main menu < ";
		bgError = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bgError);

		errorTxt = new FlxText(0, 0, FlxG.width - 40, errorText, 30);
		errorTxt.font = Paths.font('vcr.ttf');
		errorTxt.applyMarkup(errorText, [
			new flixel.text.FlxTextFormatMarkerPair(new FlxTextFormat(0xFF006EBC, false, false, 0xFF005791), "<hyperlink>"),
			new flixel.text.FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF0000, false, false, 0xFFFF0000), "<red>")
		]);
		errorTxt.alignment = CENTER;
		errorTxt.screenCenter();
		add(errorTxt);

		#if(CRASH_HANDLER && sys)
		saveCrashTxt = new FlxText(0, FlxG.height - 20, 600, "Press F2 to save the crash dump.", 10);
		saveCrashTxt.font = Paths.font('vcr.ttf');
		saveCrashTxt.alignment = CENTER;
		add(saveCrashTxt);
		#end

		trace('$errorName\n$error');
		canLeave = true;

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(canLeave && (FlxG.keys.firstJustPressed() != FlxKey.NONE && FlxG.keys.firstJustPressed() != FlxKey.F2)) {
			canLeave = errorTxt.visible = false;
			FlxG.switchState(new states.MainMenuState());
		}
		#if(CRASH_HANDLER && sys) //Let's you save the crash dump to a file like base Psych Engine
		else if(canLeave && !crashDumpSaved && FlxG.keys.justPressed.F2)
			saveCrashTxt.visible = !(crashDumpSaved = saveCrashDump());
		#end
	}

	override function destroy() {
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		Conductor.bpm = returnBPM;

		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = false;
		super.destroy();
	}

	#if(CRASH_HANDLER && sys)
	function saveCrashDump():Bool {
		try {
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();
			dateNow = dateNow.replace(" ", "_").replace(":", "'");

			var errMsg:String = " * " + this.errorName + " * \n" + this.error + "\n\n";

			for (stackItem in callStack) {
				switch (stackItem) {
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						MacroUtil.print(Std.string(stackItem));
				}
			}

			var path:String = "./crash/TBarEngine_crash_" + dateNow + ".txt";
			if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");

			File.saveContent(path, errMsg + "\n\nCrash log saved at " + dateNow);
			return true;
		} catch(e) {
			MacroUtil.print("There was an error saving the crash dump!\nError: " + Std.string(e));
		}
		return false;
	}
	#end
}