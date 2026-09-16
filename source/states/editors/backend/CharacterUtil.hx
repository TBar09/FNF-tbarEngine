package states.editors.backend;

import haxe.xml.Printer;
import objects.Character;
import haxe.Json;

/*
 * A utility class for converting character jsons to & from
 * various formats.
 *
 * TODO: Fix CNE offsets being off when converted to and from.
 */
class CharacterUtil {
	public static function convertFromCodename(xmlStr:String, ?spriteName:Null<String>):CharacterFile {
		var psychChar:CharacterFile = {
			animations: [],
			image: "characters/boyfriend",
			no_antialiasing: false,
			sing_duration: 5,
			position: [0, 0],
			camera_position: [0, 0],
			scale: 1,
			vocals_file: null,

			healthicon: "icon-name",
			healthbar_colors: [0, 255, 0],

			flip_x: false
		};

		var parsedXml = Xml.parse(xmlStr);
		var characterNode = parsedXml.firstElement();

		//Finding the sprite path. If it doesn't exist, then we just use the filename
		if(characterNode.exists("sprite")) {
			var __charName:String = characterNode.get("sprite");
			if(__charName.startsWith("characters/")) __charName = __charName.substr(11);

			psychChar.image = __charName.substr(11);
		} else if(spriteName != null && spriteName.length > 0) {
			psychChar.image = spriteName;
		}

		//Camera and Field Positions
		var charPos:Array<Float> = [0, 0];
		if(characterNode.exists("camx")) charPos[0] = Std.parseFloat(characterNode.get("camx"));
		if(characterNode.exists("camy")) charPos[1] = Std.parseFloat(characterNode.get("camy"));
		Reflect.setField(psychChar, "camera_position", charPos);

		//NOTE: We do camera position first, then actual position so we can use this array for animation offsets
		charPos = [0, 0]; //Reusing the char position array
		if(characterNode.exists("x")) charPos[0] = Std.parseFloat(characterNode.get("x"));
		if(characterNode.exists("y")) charPos[1] = Std.parseFloat(characterNode.get("y"));
		Reflect.setField(psychChar, "position", charPos);

		//Other Character stuff
		if(characterNode.exists("isPlayer"))
			Reflect.setField(psychChar, "_editor_isPlayer", (characterNode.get("isPlayer") == "true"));
		if(characterNode.exists("antialiasing"))
			Reflect.setField(psychChar, "no_antialiasing", (characterNode.get("antialiasing") == "false"));
		if(characterNode.exists("flipX"))
			Reflect.setField(psychChar, "flip_x", (characterNode.get("flipX") == "true"));

		if(characterNode.exists("holdTime"))
			Reflect.setField(psychChar, "sing_duration", Std.parseFloat(characterNode.get("holdTime")));
		if(characterNode.exists("scale"))
			Reflect.setField(psychChar, "scale", Std.parseFloat(characterNode.get("scale")));

		if(characterNode.exists("icon"))
			Reflect.setField(psychChar, "healthicon", Std.string(characterNode.get("icon")));

		if(characterNode.exists("color")) {
			var color = FlxColor.fromString(Std.string(characterNode.get("color")));
			Reflect.setField(psychChar, "healthbar_colors", [color.red, color.green, color.blue]);
		}
		
		// Animations
		for(animNode in characterNode.elements()) {
			var charAnim:AnimArray = {anim: "NO_NAME", name: "NO_ANIMATION", loop: false, fps: 24, indices: [], offsets: [0, 0]};

			if(animNode.exists("name")) Reflect.setField(charAnim, "anim", animNode.get("name"));
			if(animNode.exists("anim")) Reflect.setField(charAnim, "name", animNode.get("anim"));

			if(animNode.exists("fps")) Reflect.setField(charAnim, "fps", Std.parseInt(animNode.get("fps")));
			if(animNode.exists("loop")) Reflect.setField(charAnim, "loop", (animNode.get("loop") == "true"));

			var animOffsets:Array<Float> = [0, 0];
			if(animNode.exists("x")) animOffsets[0] = charPos[0] + Std.parseFloat(animNode.get("x"));
			if(animNode.exists("y")) animOffsets[1] = charPos[1] + Std.parseFloat(animNode.get("y"));
			Reflect.setField(charAnim, "offsets", animOffsets);

			if(animNode.exists("indices")) Reflect.setField(charAnim, "indices", parseXMLIndices(animNode.get("indices")));

			psychChar.animations.push(charAnim);
		}

		return psychChar;
	}

	public static function convertFromVSlice(vsliceStr:String):CharacterFile {
		var psychChar:CharacterFile = {
			animations: [],
			image: "characters/boyfriend",
			no_antialiasing: false,
			sing_duration: 5,
			position: [0, 0],
			camera_position: [0, 0],
			scale: 1,
			vocals_file: null,

			healthicon: "icon-name",
			healthbar_colors: [0, 255, 0],

			flip_x: false
		};

		var vsliceChar:VSliceCharacter = Json.parse(vsliceStr);
		var animationList:Array<VSliceAnimation> = Reflect.field(vsliceChar, "animations");

		//Image
		if(Reflect.hasField(vsliceChar, "assetPath")) {
			var imagePath:String = Reflect.field(vsliceChar, "assetPath");
			if(imagePath.startsWith("shared:")) imagePath = imagePath.substr(7);

			Reflect.setField(psychChar, "image", imagePath);
		}

		//Health Icon
		if(Reflect.hasField(vsliceChar, "healthIcon")) {
			var healthIcon = Reflect.field(vsliceChar, "healthIcon");
			Reflect.setField(psychChar, "healthicon", Reflect.field(healthIcon, "id"));

			//If the icon has no "icon-" prefix, then we add it
			if(!psychChar.healthicon.startsWith("icon-")) psychChar.healthicon = "icon-" + psychChar.healthicon;

			//If the icon is a pixel icon, then we append this
			if(Reflect.field(vsliceChar, "isPixel") == true) psychChar.healthicon = psychChar.healthicon + "-pixel";
		}

		//Camera and Game Positions
		var charPos:Array<Float> = [0, 0];
		if(Reflect.hasField(vsliceChar, "offsets")) {
			charPos = Reflect.field(vsliceChar, "offsets");
		}
		Reflect.setField(psychChar, "position", charPos);

		charPos = [0, 0];
		if(Reflect.hasField(vsliceChar, "cameraOffsets")) {
			charPos = Reflect.field(vsliceChar, "cameraOffsets");
		}
		Reflect.setField(psychChar, "camera_position", charPos);

		//Misc.

		/*
		 * The reason why the boolean values have `== true` is because some jsons have the boolean values set to null,
		 * this way we can make mark it false if it's null with no additional null check
		 */
		if(Reflect.hasField(vsliceChar, "flipX"))
			Reflect.setField(psychChar, "flip_x", (Reflect.field(vsliceChar, "flipX") == true));
		if(Reflect.hasField(vsliceChar, "isPixel"))
			Reflect.setField(psychChar, "no_antialiasing", (Reflect.field(vsliceChar, "isPixel") == true));

		if(Reflect.hasField(vsliceChar, "singTime"))
			Reflect.setField(psychChar, "sing_duration", Reflect.field(vsliceChar, "singTime"));
		if(Reflect.hasField(vsliceChar, "scale"))
			Reflect.setField(psychChar, "scale", Reflect.field(vsliceChar, "scale"));

		//Animations
		for(vsliceAnim in animationList) {
			var charAnim:AnimArray = {anim: "NO_NAME", name: "NO_ANIMATION", loop: false, fps: 24, indices: [], offsets: [0, 0]};

			Reflect.setField(charAnim, "anim", Reflect.field(vsliceAnim, "name"));
			Reflect.setField(charAnim, "name", Reflect.field(vsliceAnim, "prefix"));

			if(Reflect.hasField(vsliceAnim, "looped"))
				Reflect.setField(charAnim, "loop", Reflect.field(vsliceAnim, "looped"));

			if(Reflect.hasField(vsliceAnim, "frameIndices"))
				Reflect.setField(charAnim, "indices", Reflect.field(vsliceAnim, "frameIndices"));
			if(Reflect.hasField(vsliceAnim, "offsets"))
				Reflect.setField(charAnim, "offsets", Reflect.field(vsliceAnim, "offsets"));

			if(Reflect.hasField(vsliceAnim, "frameRate"))
				Reflect.setField(charAnim, "fps", Reflect.field(vsliceAnim, "frameRate"));

			psychChar.animations.push(charAnim);
		}

		return psychChar;
	}

	public static function convertToCodename(psychChar:CharacterFile):String {
		var cneXml:Xml = Xml.createElement("character");

		cneXml.set("sprite", Std.string(psychChar.image));

		cneXml.set("x", Std.string(psychChar.position[0]));
		cneXml.set("y", Std.string(psychChar.position[1]));
		cneXml.set("camx", Std.string(psychChar.camera_position[0]));
		cneXml.set("camy", Std.string(psychChar.camera_position[1]));
		cneXml.set("scale", Std.string(psychChar.scale));
		cneXml.set("holdTime", Std.string(psychChar.sing_duration));

		cneXml.set("antialiasing", Std.string(!psychChar.no_antialiasing));
		cneXml.set("flipX", Std.string(psychChar.flip_x));
		if(psychChar._editor_isPlayer != null) cneXml.set("isPlayer", Std.string(psychChar._editor_isPlayer));

		cneXml.set("icon", Std.string(psychChar.healthicon));

		if(psychChar.healthbar_colors != null && psychChar.healthbar_colors.length > 2) {
			var _psychColor:FlxColor = FlxColor.fromRGB(psychChar.healthbar_colors[0], psychChar.healthbar_colors[1], psychChar.healthbar_colors[2]);
			cneXml.set("color", _psychColor.toWebString());
		}

		for(animObj in psychChar.animations) {
			var animXml:Xml = Xml.createElement('anim');

			if(animObj.offsets != null && animObj.offsets.length > 1) {
				//We subtract the offset by the character position because CNE animation positions
				//are addons to the existing position
				animXml.set("x", Std.string(animObj.offsets[0] - psychChar.position[0]));
				animXml.set("y", Std.string(animObj.offsets[1] - psychChar.position[1]));
			}

			animXml.set("name", animObj.anim);
			animXml.set("anim", animObj.name);
			if(animObj.indices != null && animObj.indices.length > 0) {
				animXml.set("indices", formatXMLIndices(animObj.indices, ","));
			}

			animXml.set("loop", Std.string(animObj.fps));
			
			cneXml.addChild(animXml);
		}

		return "<!DOCTYPE codename-engine-character>\n<!-- Created with T-Bar Engine v" + openfl.Lib.application.meta["version"] + " -->\n" + Printer.print(cneXml, true);
	}

	public static function convertToVSlice(psychChar:CharacterFile, ?charRenderType:String = "sparrow"):String {
		var vsliceChar:VSliceCharacter = {
			version: "1.0.0",
			animations: [],
			name: "Test Character",
			assetPath: "characters/BOYFRIEND",
			renderType: "sparrow",
			offsets: [0, 0],
			cameraOffsets: [0, 0],
			singTime: 5,
			scale: 5,
			isPixel: false,
			flipX: false,
			healthIcon: {
				flipY: false,
				isPixel: false,
				offsets: [0, 0],
				scale: 1,
				id: "name",
				flipX: false
			}
		}

		//Image
		Reflect.setField(vsliceChar, "assetPath", psychChar.image);
		
		//use `character.isAnimateAtlas`. Can be "sparrow" or "animateatlas"
		Reflect.setField(vsliceChar, "renderType", charRenderType);

		//Camera and Game Positions
		var charPos:Array<Float> = [0, 0];
		if(Reflect.hasField(psychChar, "position"))
			Reflect.setField(vsliceChar, "offsets", Reflect.field(psychChar, "position"));

		charPos = [0, 0];
		if(Reflect.hasField(psychChar, "camera_position"))
			Reflect.setField(vsliceChar, "cameraOffsets", Reflect.field(psychChar, "camera_position"));

		//Misc.
		if(Reflect.hasField(psychChar, "healthicon")) {
			var _healthIcon:String = Std.string(Reflect.field(psychChar, "healthicon"));
			
			Reflect.setField(vsliceChar.healthIcon, "id", (_healthIcon.startsWith("icon-") ? _healthIcon.substr(5) : _healthIcon));
		}

		if(Reflect.hasField(psychChar, "scale"))
			Reflect.setField(vsliceChar, "scale", Reflect.field(psychChar, "scale"));
		if(Reflect.hasField(psychChar, "flip_x"))
			Reflect.setField(vsliceChar, "flipX", Reflect.field(psychChar, "flip_x"));
		if(Reflect.hasField(psychChar, "no_antialiasing"))
			Reflect.setField(vsliceChar, "isPixel", (Reflect.field(psychChar, "no_antialiasing") == true));

		if(Reflect.hasField(psychChar, "sing_duration"))
			Reflect.setField(vsliceChar, "singTime", Reflect.field(psychChar, "sing_duration"));

		//Animations
		for(psychAnim in psychChar.animations) {
			var charAnim:VSliceAnimation = {name: "NO_NAME", prefix: "NO_ANIMATION", looped: false, frameIndices: [], offsets: [0, 0], frameRate: 24};

			Reflect.setField(charAnim, "name", Reflect.field(psychAnim, "anim"));
			Reflect.setField(charAnim, "prefix", Reflect.field(psychAnim, "name"));

			if(Reflect.hasField(psychAnim, "loop"))
				Reflect.setField(charAnim, "looped", Reflect.field(psychAnim, "loop"));

			if(Reflect.hasField(psychAnim, "indices"))
				Reflect.setField(charAnim, "frameIndices", Reflect.field(psychAnim, "indices"));
			if(Reflect.hasField(psychAnim, "offsets"))
				Reflect.setField(charAnim, "offsets", Reflect.field(psychAnim, "offsets"));
			if(Reflect.hasField(psychAnim, "fps"))
				Reflect.setField(charAnim, "frameRate", Reflect.field(psychAnim, "fps"));

			vsliceChar.animations.push(charAnim);
		}

		Reflect.setField(vsliceChar, "generatedBy", "T-Bar Engine v" + openfl.Lib.application.meta["version"]);
		return Json.stringify(vsliceChar, null, "\t");
	}

	/*
	 * BACKEND FUNCTIONS
	 */

	//https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/utils/CoolUtil.hx#L1116
	static function parseXMLIndices(charAnim:String):Array<Int> {
		var result:Array<Int> = [];
		var parts:Array<String> = charAnim.split(",");

		for (part in parts) {
			part = part.trim();
			var idx = part.indexOf("..");
			if (idx != -1) {
				var start = Std.parseInt(part.substring(0, idx).trim());
				var end = Std.parseInt(part.substring(idx + 2).trim());

				if(start == null || end == null) {
					continue;
				}

				if (start < end) {
					for (j in start...end+1) {
						result.push(j);
					}
				} else {
						for (j in end...start+1) {
							result.push(start+end - j);
						}
					}
			} else {
				var num = Std.parseInt(part);
				if (num != null) {
					result.push(num);
				}
			}
		}
		return result;
	}

	//https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/utils/CoolUtil.hx#L1157
	static function formatXMLIndices(numbers:Array<Int>, separator:String = ","):String {
		if (numbers.length == 0) return "";

		var result:Array<String> = [];
		var i = 0;

		while (i < numbers.length) {
			var start = numbers[i];
			var end = start;
			var direction = 0; // 0: no sequence, 1: increasing, -1: decreasing

			if (i + 1 < numbers.length) { // detect direction of sequence
				if (numbers[i + 1] == end + 1) {
					direction = 1;
				} else if (numbers[i + 1] == end - 1) {
					direction = -1;
				}
			}

			if(direction != 0) {
				while (i + 1 < numbers.length && (numbers[i + 1] == end + direction)) {
					end = numbers[i + 1];
					i++;
				}
			}

			if (start == end) { // no direction
				result.push('${start}');
			} else if (start + direction == end) { // 1 step increment
				result.push('${start},${end}');
			} else { // store as range
				result.push('${start}..${end}');
			}

			i++;
		}

		return result.join(separator);
	}
}

/* VSlice JSON stuff */
typedef VSliceCharacter = {
	var version:String;
	var name:String;
	var renderType:String;
	var assetPath:String;
	var scale:Null<Float>;
	var healthIcon:Null<VSliceHealthIcon>;
	var offsets:Null<Array<Float>>;
	var cameraOffsets:Array<Float>;
	var isPixel:Null<Bool>;
	var singTime:Null<Float>;
	var flipX:Null<Bool>;
	var animations:Array<VSliceAnimation>;
}

typedef VSliceAnimation = {
	var name:String;
	var prefix:String;
	var offsets:Null<Array<Float>>;
	var looped:Bool;
	var frameRate:Null<Int>;
	var frameIndices:Null<Array<Int>>;
	@:optional @:default("") var assetPath:Null<String>;
	@:optional @:default(false) var flipX:Null<Bool>;
}

typedef VSliceHealthIcon = {
	var id:Null<String>;
	var scale:Null<Float>;
	var flipX:Null<Bool>;
	var isPixel:Null<Bool>;
	var offsets:Null<Array<Float>>;
	@:optional @:default(false) var flipY:Null<Bool>;
}