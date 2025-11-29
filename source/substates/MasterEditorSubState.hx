package substates;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxAxes;
import flixel.FlxObject;
import objects.Character;

import states.editors.*;
import states.FreeplayState;

class MasterEditorSubState extends MusicBeatSubstate
{
	public static var menuColor:FlxColor = 0xFF0000b6;

	//[option name, function when selected, description]
	public var options:Array<Dynamic> = [];

	/*
	 * The top level. All of the available options that appear when you first open the master debug menu.
	 */
	public var topLevelOptions:Array<Dynamic> = [];

	/*
	 * All of the default editors that you can choose by selecting "Debug Menus" in the top level.
	 */
	public var debugMenuOptions:Array<Dynamic> = [];
	public var curSelected:Int = 0;

	public var bgObjects:Array<Dynamic> = [];
	public var optionObjects:Array<FlxText> = [];
	public function new() {
		super(0x59000000);
	}

	function initDefaultOptions() {
		topLevelOptions = [
			['Resume', function() { close(); }, "Resume the game."],
			['Restart Game', function() { states.ModsMenuState.resetGame(); }, "Restart the entire engine."],
			['Editor Menus', function() { 
				curSelected = 0;
				resetOptionList(debugMenuOptions);
				changeSelection();
			}, "Select an editor."],
			#if MODS_ALLOWED
			['Mods Menu', function() {
				MusicBeatState.switchState(new states.ModsMenuState());
				close();
			}, "Go to the mods menu."],
			#end
			['Wiki', function() { 
				CoolUtil.browserLoad('https://tbar09.github.io/tbarEngine-wiki/');
			}, "Go to the fork's wiki page for documentation."],
			['Exit Game', function() { Sys.exit(1); }, "Exit the game."]
		];

		debugMenuOptions = [
			['Chart Editor', function() { selectTopLevel(0); }, "Edit song charts."],
			['Character Editor', function() { selectTopLevel(1); }, "Edit characters/character json data."],
			['Week Editor', function() { selectTopLevel(2); }, "Edit week data."],
			['Menu Character Editor', function() { selectTopLevel(3); }, "Edit menu characters for the story mode menu."],
			['Dialogue Editor', function() { selectTopLevel(4); }, "Create dialogue data for use in songs."],
			['Dialogue Portrait Editor', function() { selectTopLevel(5); }, "Create character portraits for the dialogue boxes."],
			['Note Splash Debug', function() { selectTopLevel(6); }, "Edit various note splash data."],
			['Back', function() {
				curSelected = 0;
				resetOptionList(topLevelOptions);
				changeSelection();
			}, "Return to the top level."]
		];
	}

	override function create() {
		if(FlxG.sound.music != null) FlxG.sound.music.pause();
		if(FreeplayState.vocals != null) FreeplayState.vocals.pause();
		initDefaultOptions();

		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, menuColor);
		bg.scrollFactor.set();
		bg.scale.set(500, 90);
		bg.updateHitbox();
		bg.setPosition(getMidpointOf(bg, FlxAxes.X), getMidpointOf(bg, Y) - 200);
		add(bg);
		bgObjects.push(bg);

		var bg2:FlxSprite = new FlxSprite().makeGraphic(1, 1, menuColor);
		bg2.scrollFactor.set();
		bg2.scale.set(500, 300);
		bg2.updateHitbox();
		bg2.setPosition(getMidpointOf(bg, FlxAxes.X), bg.y + bg.height + 30);
		add(bg2);
		bgObjects.push(bg2);

		var bg3:FlxSprite = new FlxSprite().makeGraphic(1, 1, menuColor);
		bg3.scrollFactor.set();
		bg3.scale.set(500, 40);
		bg3.updateHitbox();
		bg3.setPosition(0, FlxG.height - bg3.height);
		add(bg3);
		bgObjects.push(bg3);

		var descText:FlxText = new FlxText(0, 0, 1250, "");
		descText.scrollFactor.set();
		descText.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, "left", null, FlxColor.BLACK);
		add(descText);
		bgObjects.push(descText);

		var titleText:FlxText = new FlxText(0, 0, 0, "T-BAR ENGINE v" + openfl.Lib.application.meta["version"] + "\nDEV MENU");
		titleText.scrollFactor.set();
		titleText.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, "center", null, FlxColor.TRANSPARENT);
		titleText.setPosition(getMidpointOf(titleText, FlxAxes.X), bg.y + 20);
		add(titleText);
		bgObjects.push(titleText);

		resetOptionList(topLevelOptions);
		changeSelection();

		resetDescription(bg3, descText, options[curSelected][2]);
	}

	override function update(elapsed:Float) {
		if(controls.UI_UP_P || controls.UI_DOWN_P) changeSelection(controls.UI_UP_P ? -1 : 1);
		else if(controls.ACCEPT) selectItem(curSelected);

		super.update(elapsed);
	}

	//BACKEND//

	function selectTopLevel(selectId:Int, ?skipTrans:Bool = true) {
		if(skipTrans) FlxTransitionableState.skipNextTransIn = true;
		switch(selectId) {
			case 0: //Chart Editor
				LoadingState.loadAndSwitchState(new ChartingState(), false);
			case 1: //Character Editor
				LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
			case 2: //Week Editor
				MusicBeatState.switchState(new WeekEditorState());
			case 3: //Menu Character Editor
				MusicBeatState.switchState(new MenuCharacterEditorState());
			case 4: //Dialogue Editor
				LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
			case 5: //Dialogue Portrait Editor
				LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
			case 6: //Note Splash Debug
				MusicBeatState.switchState(new NoteSplashDebugState());
		}
		close();
	}

	function selectItem(selectId:Int) {
		if(options[selectId][1] != null) {
			var selectFunc = options[selectId][1];
			selectFunc();
		}
	}

	function changeSelection(delta:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + delta, 0, options.length - 1);

		for(item in optionObjects) {
			if(item.ID == curSelected) item.color = FlxColor.RED;
			else item.color = FlxColor.WHITE;
		}

		resetDescription(bgObjects[2], bgObjects[3], options[curSelected][2]);
	}

	function resetDescription(bgObj:FlxSprite, descObj:FlxText, newDesc:String) {
		descObj.visible = bgObj.visible = (newDesc != null);
		descObj.text = (descObj.visible ? newDesc : "");
		descObj.setPosition(bgObj.x + 3, bgObj.y + (bgObj.height / 8));
		bgObj.scale.x = (17 * descObj.text.length) / 1.05; //this is a bad ducktape fix but it works for now
		bgObj.updateHitbox();
	}

	function resetOptionList(?newOpt:Array<Dynamic>) {
		for(obj in optionObjects) {
			obj.destroy();
		}
		optionObjects = [];
		if(newOpt != null) options = newOpt;

		for(i => item in options) {
			var optionTxt:FlxText = new FlxText(0, 0, 600, item[0]);
			optionTxt.scrollFactor.set();
			optionTxt.setFormat(Paths.font("vcr.ttf"), 29, FlxColor.WHITE, CENTER, null, FlxColor.TRANSPARENT);
			optionTxt.setPosition(getMidpointOf(optionTxt, X), bgObjects[1].y + 10 + (i * 30));
			optionTxt.bold = true;
			optionTxt.ID = i;
			add(optionTxt);

			optionObjects.push(optionTxt);
		}

		bgObjects[1].scale.y = (options.length * 30) + 30;
		bgObjects[1].updateHitbox();
	}

	function getMidpointOf(sprite:FlxObject, axis:FlxAxes = FlxAxes.X) {
		if(sprite != null) {
			switch(axis) {
				case X: return (FlxG.width - sprite.width)/2;
				case Y: return (FlxG.height - sprite.height)/2;
				default: return -1;
			}
		}

		return -1;
	}
}