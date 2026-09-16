package states.stages;

import objects.Character;

class SpookyErect extends BaseStage
{
	final IMAGE_PREFIX:String = "erect/";
	var bgTrees:FlxSprite;
	var bgDark:FlxSprite;
	var stairsDark:FlxSprite;

	var bgLight:FlxSprite;
	var stairsLight:FlxSprite;
	override function create()
	{
		bgTrees = new FlxSprite(200, 50);
		bgTrees.frames = Paths.getSparrowAtlas(IMAGE_PREFIX + "bgtrees");
		bgTrees.animation.addByPrefix("bgtrees", "bgtrees", 5, true);
		bgTrees.scrollFactor.set(0.8, 0.8);
		bgTrees.animation.play("bgtrees");
		add(bgTrees);

		bgDark = new FlxSprite(-360, -220, Paths.image(IMAGE_PREFIX + "bgDark"));
		add(bgDark);

		stairsDark = new FlxSprite(966, -225, Paths.image(IMAGE_PREFIX + "stairsDark"));
		insert(PlayState.instance.members.indexOf(boyfriendGroup) + 1, stairsDark);

		bgLight = new FlxSprite(-360, -220, Paths.image(IMAGE_PREFIX + "bgLight"));
		add(bgLight);

		stairsLight = new FlxSprite(966, -225, Paths.image(IMAGE_PREFIX + "stairsLight"));
		insert(PlayState.instance.members.indexOf(boyfriendGroup) + 1, stairsLight);

		bgLight.alpha = stairsLight.alpha = 0;

		bgLight.antialiasing = stairsLight.antialiasing = 
		stairsDark.antialiasing = bgDark.antialiasing = 
		bgTrees.antialiasing = ClientPrefs.data.antialiasing;

		Paths.sound('thunder_1');
		Paths.sound('thunder_2');

		//Monster cutscene
		if (isStoryMode && !seenCutscene)
		{
			switch(songName)
			{
				case 'monster':
					setStartCallback(monsterCutscene);
			}
		}
	}

	var boyfriendDark:Character;
	var dadDark:Character;
	var gfDark:Character;
	override function createPost()
	{
		boyfriendDark = new Character(0, 0, "week2/" + boyfriend.curCharacter + "-dark", true);
		__startCharacterPos(boyfriendDark);
		boyfriendGroup.insert(boyfriendGroup.members.indexOf(boyfriend), boyfriendDark);

		dadDark = new Character(0, 0, "week2/" + dad.curCharacter + "-dark");
		__startCharacterPos(dadDark, true);
		dadGroup.insert(dadGroup.members.indexOf(dad), dadDark);

		if (gf != null) {
			gfDark = new Character(0, 0, "week2/" + gf.curCharacter + "-dark");
			__startCharacterPos(gfDark);
			gfDark.scrollFactor.set(0.95, 0.95);
			gfGroup.insert(gfGroup.members.indexOf(gf), gfDark);
		}

		boyfriend.alpha = gf.alpha = dad.alpha = 0;
	}

	override function update(elapsed:Float)
	{
		// This is so hacky but it works 
		if(boyfriend != null && boyfriendDark != null) {
			boyfriendDark.animation.frameName = PlayState.instance.boyfriend.animation.frameName;
			boyfriendDark.offset = PlayState.instance.boyfriend.offset;
		}
		if(dad != null && dadDark != null) {
			dadDark.animation.frameName = PlayState.instance.dad.animation.frameName;
			dadDark.offset = PlayState.instance.dad.offset;
		}
		if(gf != null && gfDark != null) {
			gfDark.animation.frameName = PlayState.instance.gf.animation.frameName;
			gfDark.offset = PlayState.instance.gf.offset;
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	override function beatHit()
	{
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	/* BACKEND */

	function __startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(PlayState.instance.GF_X, PlayState.instance.GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) boyfriend.playAnim('scared', true);
		if(dad.animOffsets.exists('scared')) dad.playAnim('scared', true);
		if(gf != null && gf.animOffsets.exists('scared')) gf.playAnim('scared', true);

		bgLight.alpha = stairsLight.alpha = boyfriend.alpha = dad.alpha = 1;
		if(gfDark != null && gf != null) {
			gf.alpha = 1;
			FlxTween.tween(gf, {alpha: 0}, 1.5);
		}

		FlxTween.tween(boyfriend, {alpha: 0}, 1.5);
		FlxTween.tween(dad, {alpha: 0}, 1.5);

		FlxTween.tween(bgLight, {alpha: 0}, 1.5);
		FlxTween.tween(stairsLight, {alpha: 0}, 1.5);

		if(ClientPrefs.data.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!game.camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}
	}

	function monsterCutscene()
	{
		inCutscene = true;
		camHUD.visible = false;

		FlxG.camera.focusOn(new FlxPoint(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100));

		// character anims
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(gf != null) gf.playAnim('scared', true);
		boyfriend.playAnim('scared', true);

		// white flash
		var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
		whiteScreen.scrollFactor.set();
		whiteScreen.blend = ADD;
		add(whiteScreen);
		FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
			startDelay: 0.1,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				remove(whiteScreen);
				whiteScreen.destroy();

				camHUD.visible = true;
				startCountdown();
			}
		});
	}
}