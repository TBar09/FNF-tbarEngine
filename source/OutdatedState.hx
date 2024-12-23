package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var optionText:FlxText;
	var optionText2:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		warnText = new FlxText(0, -100, FlxG.width,
			"Hey, your version of the T-Bar Engine\nis outdated! (" + MainMenuState.tbarEngineVersion + "),\nPlease update to " + backend.OnlineUtil.onlineData.get("latestVersion")[1] + "!\n\nThank you for using the T-Bar Engine!", 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		warnText.y -= 150;
		add(warnText);
		
		optionText = new FlxText(0, warnText.y + 250, FlxG.width, "ENTER\n(Continue)");
		optionText.setFormat("VCR OSD Mono", 22, FlxColor.BLUE, CENTER);
		optionText.screenCenter(X);
		add(optionText);
		
		optionText2 = new FlxText(0, warnText.y + 350, FlxG.width, "ESCAPE\n(Go to release page)");
		optionText2.setFormat("VCR OSD Mono", 22, FlxColor.BLUE, CENTER);
		optionText2.screenCenter(X);
		add(optionText2);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				leftStateUtils();
			}
			else if(controls.BACK) {
				leftState = true;
				CoolUtil.browserLoad((backend.OnlineUtil.onlineData.get("modWebsite")[0].length > 0) ? backend.OnlineUtil.onlineData.get("modWebsite")[0] : "https://raw.githubusercontent.com/TBar09/TBar-Engine/");
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
	
	function leftStateUtils()
	{
		FlxTween.tween(warnText, {y: warnText.y + 300, alpha: 0}, 1.5, {ease: FlxEase.quadIn});
		FlxTween.tween(optionText, {y: optionText.y + 200, alpha: 0}, 1.3, {ease: FlxEase.quadIn});
		FlxTween.tween(optionText2, {y: optionText2.y + 200, alpha: 0}, 1, {ease: FlxEase.quadIn});
	}
}
