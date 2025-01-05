package backend;

import flixel.text.FlxText;
import flixel.FlxState;

using StringTools;
class CrashHandlerState extends MusicBeatState
{	
	public var ermLeft:Bool = false;

	var error:String;
	var errorName:String;

	var bgError:flixel.FlxSprite;
	var errorTxt:FlxText;

	public function new(prevState:FlxState, error:String, errorName:String):Void {
        this.error = error;
        this.errorName = errorName;
        super();
	}

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		var engineSite = (backend.OnlineUtil.onlineData.get("modWebsite")[0].length > 0) ? backend.OnlineUtil.onlineData.get("modWebsite")[0] : "https://raw.githubusercontent.com/TBar09/TBar-Engine/";

		flixel.FlxG.sound.playMusic(null, 0);
		ermLeft = true;

		var errorTextHAHA = "<red>* WHOOPS! T-BAR ENGINE HAS CRASHED *\n* " + errorName + " *<red>\n\nPlease take a screenshot of the error below and\ncreate a new issues page on the T-Bar Engine github\n<bluehyperlink>" + engineSite + "<bluehyperlink>\n\n" + errorName + ": " + error + "\n\n > Press any key to go to the main menu < ";
		bgError = new flixel.FlxSprite().makeGraphic(flixel.FlxG.width, flixel.FlxG.height, 0xFF000000);
		add(bgError);

		errorTxt = new FlxText(0, 0, flixel.FlxG.width - 40, errorTextHAHA, 30);
		if(Paths.font('vcr.ttf') != null) errorTxt.font = Paths.font('vcr.ttf');
		errorTxt.applyMarkup(errorTextHAHA, [
			new flixel.text.FlxTextFormatMarkerPair(new FlxTextFormat(0xFF006EBC, false, false, 0xFF005791), "<bluehyperlink>"),
			new flixel.text.FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF0000, false, false, 0xFFFF0000), "<red>")
		]);
		errorTxt.alignment = CENTER;
		errorTxt.screenCenter();
		add(errorTxt);

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if(ermLeft && (flixel.FlxG.keys.firstJustPressed() != flixel.input.keyboard.FlxKey.NONE))
		{
			ermLeft = false;
			errorTxt.visible = false;

			flixel.FlxG.switchState(new MainMenuState());
		}
	}

	override function destroy() {
		flixel.FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		Conductor.changeBPM(100);

		super.destroy();
	}
}