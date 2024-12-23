package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import lime.app.Application;

import data.CppAPI;

using StringTools;

class ApplicationSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Application';
		rpcTitle = 'Application Settings Menu'; //for Discord Rich Presence
		
		#if windows
		var option:Option = new Option('Auto Pause',
			"If unchecked, the game doesn't auto pause/freeze when you\nunfocus/unselect the application",
			'autoPause',
			'bool',
			false);
		addOption(option);
        option.onChange = autoPauseToggle;

        var option:Option = new Option('Fullscreen',
			"Fullscreens the application.",
			'fullScreen',
			'bool',
			false);
		addOption(option);
        option.onChange = fullScreen;
		
		var option:Option = new Option('Window Theme: ',
			"Change the Theme of the window.",
			'windowMode',
			'string',
			'LIGHT',
			['LIGHT', 'DARK']);
		addOption(option);
		option.onChange = windowModeToggle;
		#end

		super();
	}
	
	function windowModeToggle() {
		#if windows
		CppAPI.setWindowColorMode(((ClientPrefs.windowMode == "DARK") ? true : false), CppAPI.hasWindowsVersion("10"));
		#end
	}
	
	function fullScreen() {
		#if windows
		Application.current.window.fullscreen = ClientPrefs.fullScreen;
		#end
	}

	function autoPauseToggle() {
		#if windows
		FlxG.autoPause = ClientPrefs.autoPause;
		#end
	}
}