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
import flixel.tweens.FlxEase;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnTitle:FlxText;
	var warnText:FlxText;
	var flashingText:FlxText;
	
	var canToggle:Bool = true;
	
	var flashingColorTrue:FlxTextFormat = new FlxTextFormat(0xFF00FF00, false, false, null);
	var flashingColorFalse:FlxTextFormat = new FlxTextFormat(0xFF023D66, false, false, null);
	
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		warnTitle = new FlxText(0, 0, FlxG.width, "WARNING", 52);
		warnTitle.setFormat("VCR OSD Mono", 52, FlxColor.YELLOW, CENTER);
		warnTitle.screenCenter(Y);
		warnTitle.y -= 120;
		add(warnTitle);

		warnText = new FlxText(0, 0, FlxG.width, "", 24);
		warnText.text = "Hey, this engine contains flashing lights.\nPress [TAB] to toggle the Flashing Lights setting\nand press [ENTER] to continue!\n(Don't worry, you can change this anytime in settings)";
		warnText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
		
		flashingText = new FlxText(0, FlxG.height - 24, 600, "");
		flashingText.text = "Flashing Lights are currently ";
		flashingText.alpha = 0;
		flashingText.setFormat("VCR OSD Mono", 22, FlxColor.WHITE, LEFT);
		add(flashingText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if(FlxG.keys.justPressed.TAB && canToggle)
			{
				canToggle = false;
				ClientPrefs.flashing = (!ClientPrefs.flashing);
				ClientPrefs.saveSettings();
				if(ClientPrefs.flashing)
				{
					flashingText.applyMarkup(
						"Flashing Lights are currently <y>ON<y>.",
						[new FlxTextFormatMarkerPair(flashingColorTrue, "<y>")]
					);
				} else {
					flashingText.applyMarkup(
						"Flashing Lights are currently <y>OFF<y>.",
						[new FlxTextFormatMarkerPair(flashingColorFalse, "<y>")]
					);
				}
				
				flashingText.alpha = 1;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(flashingText, {alpha: 0}, 1, {ease: FlxEase.quadIn, onComplete: 
					function(tween:FlxTween) {
						canToggle = true;
					}
				});
			}
			
			if (controls.ACCEPT) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				if(ClientPrefs.flashing)
				{
					FlxFlicker.flicker(warnTitle, 1, 0.1, false, true);
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						warnText.destroy();
						warnTitle.destroy();
						new FlxTimer().start(0.6, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxTween.tween(warnTitle, {alpha: 0}, 1, {ease: FlxEase.quadIn});
					FlxTween.tween(warnText, {alpha: 0}, 1, {ease: FlxEase.quadIn, onComplete: function(tween:FlxTween) {
						warnText.destroy();
						warnTitle.destroy();
						new FlxTimer().start(0.6, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					}});
				}
			}
		}
		super.update(elapsed);
	}
}
