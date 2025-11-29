package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.FlxObject;

import states.editors.MasterEditorMenu;
import options.OptionsState;
import psychlua.LuaUtils;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var versionTexts:FlxTypedGroup<FlxText>;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	var magenta:FlxSprite;
	var bg:FlxSprite;

	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for(i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);

			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
		}

		versionTexts = new FlxTypedGroup<FlxText>();
		add(versionTexts);

		var versionMsg:Array<Dynamic> = [
			['Friday Night Funkin\' v${Main.versions.funkin}', 24],
			['Built on Psych Engine v${Main.versions.psych}', 44],
			['T-Bar Engine v${openfl.Lib.application.meta["version"]}', 64],
		];
		for(txt in versionMsg) {
			var versionTxt:FlxText = new FlxText(12, FlxG.height - txt[1], 0, txt[0], 12);
			versionTxt.scrollFactor.set();
			versionTxt.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			versionTexts.add(versionTxt);
		}

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}
	
	override function closeSubState() {
		if(callOnMenuScript("onCloseSubStatePre", []) != LuaUtils.Function_Stop) {
			persistentUpdate = true;
			if(FlxG.sound.music != null) FlxG.sound.music.resume();
			if(FreeplayState.vocals != null) FreeplayState.vocals.resume();

			super.closeSubState();
		}
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if(FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if(!selectedSomethin)
		{
			if(controls.UI_UP_P || controls.UI_DOWN_P) {
				changeItem((controls.UI_UP_P ? -1 : 1));
			}
			else if(controls.BACK) {
				if(callOnMenuScript("onSelectedItem", ['back', -1]) != LuaUtils.Function_Stop) {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new TitleState());
				}
			}
			#if(MODS_ALLOWED && SOFTCODED_STATES)
			else if(FlxG.keys.justPressed.TAB) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new ModsMenuState());
			}
			#end

			if(controls.ACCEPT) {
				if(callOnMenuScript("onSelectedItem", [optionShit[curSelected], curSelected]) != LuaUtils.Function_Stop) {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					if (optionShit[curSelected] == 'donate') {
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					} else {
						selectedSomethin = true;
						selectedItem(curSelected);
					}
				}
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				persistentUpdate = false;
				openSubState(new substates.MasterEditorSubState());
			}
			#end
		}

		super.update(elapsed);
	}

	function selectedItem(selectedItem:Int) {
		if(ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		FlxFlicker.flicker(menuItems.members[selectedItem], 1, 0.06, false, false, function(flick:FlxFlicker)
		{
			switch(optionShit[selectedItem])
			{
				case 'story_mode':
					MusicBeatState.switchState(new StoryMenuState());
				case 'freeplay':
					MusicBeatState.switchState(new FreeplayState());
				#if MODS_ALLOWED
				case 'mods':
					MusicBeatState.switchState(new ModsMenuState());
				#end
				#if ACHIEVEMENTS_ALLOWED
				case 'awards':
					MusicBeatState.switchState(new AchievementsMenuState());
				#end
				case 'credits':
					MusicBeatState.switchState(new CreditsState());
				case 'options':
					MusicBeatState.switchState(new OptionsState());
					OptionsState.onPlayState = false;
					if (PlayState.SONG != null) {
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}
			}
		});

		for(i in 0...menuItems.members.length) {
			if(i == curSelected) continue;

			FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					menuItems.members[i].kill();
				}
			});
		}
	}

	function changeItem(delta:Int = 0) {
		if(callOnMenuScript("onChangeItemPre", [delta]) == LuaUtils.Function_Stop) return;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		menuItems.members[curSelected].screenCenter(X);

		curSelected = FlxMath.wrap(curSelected + delta, 0, menuItems.length - 1);

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		menuItems.members[curSelected].screenCenter(X);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));

		callOnMenuScript("onChangeItem", [delta]);
	}
}
