package states;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	public var defaultCreditsList:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
		['T-Bar Engine Fork'],
		['T-Bar',				'tbar',					'Owner and Creator\nMain Programmer of the T-Bar Engine fork',		'https://www.youtube.com/@tbar7460',	 '0077CC'],
		['GhostGlowDev',		'ghost',				'Helping Programmer of the T-Bar Engine fork\nOwner of GhostUtil',	'https://www.youtube.com/@GhostglowDev', '048962'],
		['SwagaRuney',			'swagaruney',			'Beta Tested and promoted the fork',								'https://www.youtube.com/@Swagaruney',	 'C64200'],
		[''],
		['Fork Contributors'],
		['Codename Engine Devs', 'codename-devs', 		'Provided Forks for Away3D, Hscript-improved,\n hxdiscord_rpc, and multiple functions/ideas',   'https://github.com/CodenameCrew/CodenameEngine', '773776'],
		['Redar13', 			 'redar', 				'Provided PR for hscript-improved that\nfixed preprocessors', 									'https://github.com/Redar13', 					  '999999'],
		[''],
		['Psych Engine Team'],
		['Shadow Mario',		'psych/shadowmario',	'Main Programmer and Head of Psych Engine',					 			'https://ko-fi.com/shadowmario',		'444444'],
		['Riveren',				'psych/riveren',		'Main Artist/Animator of Psych Engine',						 			'https://twitter.com/riverennn',		'14967B'],
		[''],
		['Former Engine Members'],
		['bb-panzu',			'psych/bb',				'Ex-Programmer of Psych Engine',							 			'https://twitter.com/bbsub3',			'3E813A'],
		[''],
		['Engine Contributors'],
		['CrowPlexus',			'psych/crowplexus',		'Input System v3, Major Help and Other PRs',				 			'https://twitter.com/crowplexus',		'A1A1A1'],
		['Keoiki',				'psych/keoiki',			'Note Splash Animations and Latin Alphabet',				 			'https://twitter.com/Keoiki_',			'D2D2D2'],
		['SqirraRNG',			'psych/sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform', 			'https://twitter.com/gedehari',			'E1843A'],
		['EliteMasterEric',		'psych/mastereric',		'Runtime Shaders support',									 			'https://twitter.com/EliteMasterEric',	'FFBD40'],
		["MAJigsaw77",			"psych/majigsaw",		".MP4 Video Loader Library (hxvlc)",									"https://twitter.com/MAJigsaw77",		'5F5F5F'],
		['Tahir',				'psych/tahir',			'Implementing & Maintaining SScript and Other PRs',			 			'https://twitter.com/tahirk618',		'A04397'],
		['iFlicky',				'psych/flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',	 			'https://twitter.com/flicky_i',			'9E29CF'],
		['KadeDev',				'psych/kade',			'Fixed some issues on Chart Editor and Other PRs',			 			'https://twitter.com/kade0912',			'64A250'],
		['superpowers04',		'psych/superpowers04',	'LuaJIT Fork',												 			'https://twitter.com/superpowers04',	'B957ED'],
		['CheemsAndFriends',	'psych/cheems',			'Creator of FlxAnimate',												'https://twitter.com/CheemsnFriendos',	'A1A1A1'],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'funkin/ninjamuffin99',	"Programmer of Friday Night Funkin'",									'https://twitter.com/ninja_muffin99',	'CF2D2D'],
		['PhantomArcade',		'funkin/phantomarcade',	"Animator of Friday Night Funkin'",							 			'https://twitter.com/PhantomArcade3K',	'FADC45'],
		['evilsk8r',			'funkin/evilsk8r',		"Artist of Friday Night Funkin'",							 			'https://twitter.com/evilsk8r',			'5ABD4B'],
		['kawaisprite',			'funkin/kawaisprite',	"Composer of Friday Night Funkin'",							 			'https://twitter.com/kawaisprite',		'378FC7'],
		[""],
		["Psych Engine Discord"],
		["Join the Psych Ward!", "misc/discord", "", "https://discord.gg/2ka77eMXDv", "5165F6"]
	];

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end

		for(i in defaultCreditsList) {
			creditsStuff.push(i);
		}

		for(i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null) {
					Mods.currentModDirectory = creditsStuff[i][5];
				}

				var str:String = 'credits/misc/missing_icon';
				if(creditsStuff[i][1] != null && creditsStuff[i][1].length > 0)
				{
					var fileName = 'credits/' + creditsStuff[i][1];
					if (Paths.fileExists('images/$fileName.png', IMAGE)) str = fileName;
					else if (Paths.fileExists('images/$fileName-pixel.png', IMAGE)) str = fileName + '-pixel';
				}

				var icon:AttachedSprite = new AttachedSprite(str);
				if(str.endsWith('-pixel')) icon.antialiasing = false;
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Mods.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		changeSelection();

		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if(FlxG.sound.music != null && FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if(upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if(downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if(controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for(item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(item.x - 70, lastX, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(200 + -40 * Math.abs(item.targetY), item.x, lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		//trace('The BG color is: $newColor');
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		//Checking for a credits.txt file first for compatibility
		if(FileSystem.exists(creditsFile)) {
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);

			return;
		}

		//If we don't find a credits text file, then we search for a json
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.json');
		else creditsFile = Paths.mods('data/credits.json');

		if(FileSystem.exists(creditsFile)) {
			try {
				var creditsArray:Array<CreditEntry> = tjson.TJSON.parse(File.getContent(creditsFile));
				for(credit in creditsArray) {
					if(credit.name == null) {
						trace("[WARNING] Credit entry must at least have a \"name\" field!");
						continue;
					}

					//It's a title
					if((credit.isTitle != null && credit.isTitle) || credit.description == null) {
						creditsStuff.push([credit.name]);
					} else {
						creditsStuff.push([
							credit.name,
							(credit.icon != null ? credit.icon : "misc/missing_icon"),
							credit.description,
							(credit.link != null ? credit.link : ""),
							(credit.color != null ? credit.color : "FFFFFF"),

							/* Not used by the state, just for keeping track of the credit's origins */
							((folder != null && folder.length > 0) ? folder : "NO FOLDER")
						]);
					}
				}
				creditsStuff.push(['']);
			} catch(e) {
				trace('An Error occured in credits.json for mod name "${folder}": ${Std.string(e)}');
			}
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}

typedef CreditEntry = {
	var name:String;
	@:optional var isTitle:Bool;
	@:optional var description:String;
	@:optional var icon:String;
	@:optional var link:String;
	@:optional var color:String;
}