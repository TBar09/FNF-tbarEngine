package psychlua;

#if HSCRIPT_ALLOWED
import hscript.Expr.Error;
import hscript.Expr;
import hscript.*;
#end

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import psychlua.LuaUtils;
import haxe.Log;
#if LUA_ALLOWED
import llua.Lua;
#end

#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

/*
 * The class that handles haxe scripts. The code was built off some mod's code, so props to them!
 */
using StringTools;
interface HscriptInterface {
    public var scriptName:String;
    public function set(variable:String, data:Dynamic):Void;
    public function call(func:String, args:Array<Dynamic>):Dynamic;
    public function stop():Void;
}

#if HSCRIPT_ALLOWED
class HScript implements HscriptInterface {

	/*
	 * All the classes pre-imported into every haxe script / runHaxeCode.
	 * These variables are free to be edited to allow for custom pre-imported classes.
	 */
    public static var classes:Map<String, Dynamic> = [
		//Base level haxe classes. Not recommended to edit these!
		"Math" => Math, "Std" => Std,
		"StringTools" => StringTools,
		"Reflect" => Reflect, 'Type' => Type,
		'Date' => Date, 'DateTools' => DateTools,
		#if sys
		'Sys' => Sys,
		"File" => sys.io.File,
		"FileSystem" => sys.FileSystem,
		#end

		//Flixel Classes
		"FlxG" => flixel.FlxG,
		"FlxSprite" => flixel.FlxSprite,
		"FlxTimer" => flixel.util.FlxTimer,
		"FlxTween" => flixel.tweens.FlxTween,
		"FlxEase" => flixel.tweens.FlxEase,
		"FlxText" => flixel.text.FlxText,

		//Friday Night Funkin' Classes
		"Paths" => backend.Paths,
		"Conductor" => backend.Conductor,
		"PlayState" => states.PlayState,
		"Boyfriend" => objects.Character, //compatibility
		"Character" => objects.Character,
		"CoolUtil"	=> backend.util.CoolUtil,
		"ClientPrefs" => backend.ClientPrefs,
		"Main" => Main, "Init" => Init, //Base level classes in Psych

		//T-Bar Engine specific classes
		#if(SOFTCODED_STATES && HSCRIPT_ALLOWED)
		"ModScriptState" => backend.scripts.ModScriptState,
		"ModScriptSubstate" => backend.scripts.ModScriptSubstate,
		"MusicBeatState" => backend.MusicBeatState,
		"MusicBeatSubstate" => backend.MusicBeatSubstate,
		#end

		//away3d specific classes
		#if(away3d && AWAY3D_ALLOWED)
		"Flx3DCamera" => flixel.flx3d.Flx3DCamera,
		"Flx3DView" => flixel.flx3d.Flx3DView,
		"FlxView3D" => flixel.flx3d.FlxView3D,
		"Flx3DUtil" => flixel.flx3d.Flx3DUtil,
		#end

		//Extras
		"Json" => { //Using the base Json library produces a null function pointer
			parse: function(txt:String):Dynamic { return haxe.Json.parse(txt); },
			stringify: function(value:Dynamic, ?replacer:(key:Dynamic, value:Dynamic) -> Dynamic, ?space:String) { return haxe.Json.stringify(value, replacer, space); }
		},
		"FlxBasic" => flixel.FlxBasic,
		"FlxCamera" => flixel.FlxCamera,
		"FlxMath" => flixel.math.FlxMath,
		"FlxGroup" => flixel.group.FlxGroup,
		"FlxTypedGroup" => flixel.group.FlxGroup.FlxTypedGroup,
		"FlxSpriteGroup" => flixel.group.FlxSpriteGroup,
		"FlxSound" => #if(flixel >= "5.3.0") flixel.sound.FlxSound #else flixel.system.FlxSound #end,
		#if(flxanimate) "FlxAnimate" => flxanimate.FlxAnimate, #end
		#if(!flash) "FlxRuntimeShader" => flixel.addons.display.FlxRuntimeShader, #end
		"ShaderFilter"	=> openfl.filters.ShaderFilter,

		//Abstracts
		"FlxPoint" => LuaUtils.getMacroAbstractClass("flixel.math.FlxPoint"),
		"FlxAxes" => LuaUtils.getMacroAbstractClass("flixel.util.FlxAxes"),
		"FlxColor" => LuaUtils.getMacroAbstractClass("flixel.util.FlxColor")
    ];

	/*
	 * All of the variables set by using `static var`. These variables can be accessed by all scripts.
	 * (Note: Be sure to clear this map on mod change to prevent any other mods from using your vars)
	 */
	public static var staticVariables:Map<String, Dynamic> = [];

    public var parser:Parser;
    public var interp:Interp;
    public var expr:Expr;

	public var variables(get, never):Map<String, Dynamic>;
	public function get_variables() return interp.variables;

    public var scriptName:String;
	public var modFolder:Null<String>;

	//Scripts attached to this script. You can make some goofy chains with this.
	public var subScripts:Array<psychlua.HScript> = [];

	/**
	 * Creates a new haxe script instance that runs interpreted haxe code.
	 *
	 * @param	path			The path to the haxe script.
	 *							NOTE: This does not support direct code strings. See the
	 *							`HaxeCode` class for a version supporting code strings.
	 * @param	_parentClass	The parent state instance this script will be assigned to. 
	 * @param	_autoRunScript	(This is used internally by `HaxeCode` and is not recommened to use)
	 * @param  	_ignoreErrors	Whether the script should ignore the critical error popup if an error is found.
	 */
    public function new(path:String, ?_parentClass:Dynamic = null, ?_autoRunScript:Bool = true, ?_ignoreErrors:Bool = false) {
		if(!_autoRunScript) return;

        if(parser == null) initParser();
		if(interp == null) initInterp();
        scriptName = path;

		#if MODS_ALLOWED
		if(scriptName != null && scriptName.length > 0)
		{
			var myFolder:Array<String> = scriptName.trim().split('/');
			if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
				this.modFolder = myFolder[1];
		}
		#end

		try {
			parser.line = 1; //Reset the parser position.
			expr = parser.parseString(#if sys File.getContent(path) #else Assets.getText(path) #end, path);

			interp.variables.set("this", this);
			for(varToBring => val in classes) interp.variables.set(varToBring, val);

			this.setParent((_parentClass != null ? _parentClass : LuaUtils.getHScriptScriptObject()));
			addHScriptExtras(this.interp, LuaUtils.isPlayStateScript(interp.scriptObject));

			interp.variables.set("getModSetting", function(saveTag:String, ?modName:String = null) {
				if(modName == null) {
					if(this.modFolder == null) {
						LuaUtils.hxTrace('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', 0xFFFF0000);
						return null;
					}
					modName = this.modFolder;
				}
				return LuaUtils.getModSetting(saveTag, modName);
			});

			interp.execute(expr);
			call("onCreate", []);
		} catch(e) {
			if(!_ignoreErrors) FlxG.stage.window.alert('Error on haxe script.\n${e.toString()}', 'Error on Haxe Script!');
		}
	}

	public static function addHScriptExtras(obj:Interp, isPlayState:Bool = false) {
		if(obj == null) return;

		if(isPlayState) {
			obj.variables.set("game", PlayState.instance); //runHaxeCode moment
			obj.variables.set("add", function(basic:FlxBasic, ?frontOfChars:Bool = false) {
				if (frontOfChars) {
					PlayState.instance.add(basic);
					return;
				}

				var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
				if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
				else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);

				PlayState.instance.insert(position, basic);
			});

			obj.variables.set('insert', PlayState.instance.insert);
			obj.variables.set('remove', PlayState.instance.remove);
			obj.variables.set('addBehindGF', PlayState.instance.addBehindGF);
			obj.variables.set('addBehindDad', PlayState.instance.addBehindDad);
			obj.variables.set('addBehindBF', PlayState.instance.addBehindBF);
			obj.variables.set('setVar', function(name:String, value:Dynamic) {
				PlayState.instance.variables.set(name, value);
				return value;
			});
			obj.variables.set('getVar', function(name:String) {
				var result:Dynamic = null;
				if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
				return result;
			});
			obj.variables.set('removeVar', function(name:String) {
				if(PlayState.instance.variables.exists(name)) {
					PlayState.instance.variables.remove(name);
					return true;
				}
				return false;
			});

			obj.variables.set('customSubstate', CustomSubstate.instance);
			obj.variables.set('customSubstateName', CustomSubstate.name);
		} else {
			obj.variables.set("game", obj.scriptObject);
			obj.variables.set('add', obj.scriptObject.add);
			obj.variables.set('insert', obj.scriptObject.insert);
			obj.variables.set('remove', obj.scriptObject.remove);

			if(obj.scriptObject.variables != null) {
				obj.variables.set('setVar', function(name:String, value:Dynamic) {
					obj.scriptObject.variables.set(name, value);
					return value;
				});
				obj.variables.set('getVar', function(name:String) {
					var result:Dynamic = null;
					if(obj.scriptObject.variables.get(name) != null) result = obj.scriptObject.variables.get(name);
					return result;
				});
				obj.variables.set('removeVar', function(name:String) {
					if(obj.scriptObject.variables.get(name) != null) {
						obj.scriptObject.variables.remove(name);
						return true;
					}
					return false;
				});
			}
		}

		obj.variables.set("Function_Stop", LuaUtils.Function_Stop);
		obj.variables.set("Function_Continue", LuaUtils.Function_Continue);
		obj.variables.set("Function_StopHScript", LuaUtils.Function_StopHScript);
		obj.variables.set("Function_StopLua", LuaUtils.Function_StopLua);
		obj.variables.set("Function_StopAll", LuaUtils.Function_StopAll);

		//TODO: replace this with "$type". This should work for now
		obj.variables.set("__type__", function(target:Dynamic):String {
			return switch(Type.typeof(target)) {
				case TInt: "Int";
				case TFloat: "Float";
				case TBool: "Bool";
				case TObject: "Object";
				case TFunction: "Function";
				case TClass(clsInst): //also houses "String". TODO: Support for scripted classes & enums
					Type.getClassName(clsInst);
				case TEnum(enmInst):
					Type.getEnumName(enmInst);
				case TUnknown: "Unknown";
				default: "Null";
			}
		});

		obj.variables.set("debugPrint", function(text:Dynamic = "", color:FlxColor = null) {
			#if(LUA_ALLOWED || HSCRIPT_ALLOWED)
			if(FlxG.state is PlayState)
				PlayState.instance.addTextToDebug(text, (color == null ? FlxColor.WHITE : color));
			else #end
				backend.macros.MacroUtil.print(text);
		});

		//other variables
		obj.variables.set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		obj.variables.set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		obj.variables.set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		obj.variables.set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
		obj.variables.set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
		obj.variables.set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));

		obj.variables.set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		obj.variables.set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		obj.variables.set('gamepadJustPressed', function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		obj.variables.set('gamepadPressed', function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		obj.variables.set('gamepadReleased', function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		obj.variables.set('keyJustPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT_P;
				case 'down': return Controls.instance.NOTE_DOWN_P;
				case 'up': return Controls.instance.NOTE_UP_P;
				case 'right': return Controls.instance.NOTE_RIGHT_P;
				default: return Controls.instance.justPressed(name);
			}
			return false;
		});
		obj.variables.set('keyPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT;
				case 'down': return Controls.instance.NOTE_DOWN;
				case 'up': return Controls.instance.NOTE_UP;
				case 'right': return Controls.instance.NOTE_RIGHT;
				default: return Controls.instance.pressed(name);
			}
			return false;
		});
		obj.variables.set('keyReleased', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT_R;
				case 'down': return Controls.instance.NOTE_DOWN_R;
				case 'up': return Controls.instance.NOTE_UP_R;
				case 'right': return Controls.instance.NOTE_RIGHT_R;
				default: return Controls.instance.justReleased(name);
			}
			return false;
		});

		obj.variables.set("state", FlxG.state);
		obj.variables.set('buildTarget', LuaUtils.getBuildTarget());
		obj.variables.set("engine", {
			title: openfl.Lib.application.meta["name"],
			file: openfl.Lib.application.meta["file"],
			version: openfl.Lib.application.meta["version"],
			dimensions: {width: 1280, height: 720}
		});

		#if LUA_ALLOWED
		obj.variables.set("createGlobalCallback", function(name:String, func:Dynamic) {
			if(FlxG.state is PlayState) {
				for(script in PlayState.instance.luaArray) {
					if(script != null && script.lua != null && !script.closed) 
						Lua_helper.add_callback(script.lua, name, func);
				}
			}

			FunkinLua.customFunctions.set(name, func);
		});

		obj.variables.set("createCallback", function(name:String, func:Dynamic, ?lua:FunkinLua) {
			if(lua == null) {
				LuaUtils.hxTrace('createCallback: no script was found or 3rd argument was null!', 0xFFFF0000);
				return false;
			}

			lua.addLocalCallback(name, func);
			return true;
		});
		#end
	}

	//CALLBACKS FOR HSCRIPT

	var _librariesAllowed:Bool = true;
	function onImportFailed(cl:Array<String>, classAlias:Null<String>):Bool {
		if(_librariesAllowed) { //Custom hscript libraries
			var scriptPath = Paths.getScriptPath("libraries/" + cl.join("/") + Paths.HSCRIPT_EXT, this.modFolder);
			if(#if sys FileSystem.exists(scriptPath) #else Assets.exists(scriptPath) #end) {
				return _includeSubscript(scriptPath, true);
			}
		}

		return false;
	}

    function onHaxeTrace(v:Dynamic) {
		var posInfos = interp.posInfos();
		Log.trace(Std.string(v), {fileName: posInfos.fileName, lineNumber: posInfos.lineNumber, className: null, methodName: null});
    }

    function onError(e:Error) {
		LuaUtils.hxTrace(Printer.errorToString(e), 0xFFFF0000);
    }

	function onWarn(e:Error) {
		LuaUtils.hxTrace("[WARNING] " + Printer.errorToString(e), 0xFFFFFF00);
	}

	//BACKEND FUNCTIONS

	public function setPublicMap(map:Map<String, Dynamic>) {
		if(interp != null) interp.publicVariables = map;
		return this;
	}

	public function setParent(parent:Dynamic) {
		if(interp != null) {
			interp.scriptObject = parent;
			if(parent.variables != null) interp.publicVariables = parent.variables;
		}
		return this;
	}

	public function getScriptParent():Dynamic
		return interp.scriptObject;

	function _includeSubscript(path:String, absolute:Bool = false):Bool {
		var scriptPath = (absolute ? path : Paths.getScriptPath(path, this.modFolder));

		if(#if sys FileSystem.exists(scriptPath) #else Assets.exists(scriptPath) #end) {
			var hscriptToPush = new HScript(scriptPath, this.getScriptParent(), true, true);
			hscriptToPush.call("onScriptImported", [this]);
			subScripts.push(hscriptToPush);
			return true;
		}

		LuaUtils.hxTrace('Path "$scriptPath" does not exist!', 0xFFFF0000);
		return false;
	}

	public function initParser() {
		parser = new hscript.Parser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = parser.allowRegex = true;
		parser.preprocessorValues = LuaUtils.getHScriptPreprocessors();
	}

	public function initInterp() {
		interp = new Interp();
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		interp.staticVariables = staticVariables;

		interp.onMetadata = onMetadata;
		interp.errorHandler = onError;
		interp.warnHandler = onWarn;
		interp.importFailedCallback = onImportFailed;
	}

	/*
	 * All of the custom metadatas (@:exampleMeta) that can be used in hscript.
	 */
	public function onMetadata(name:String, args:Array<Expr>, exp:Expr) {
		switch(name) {
			case ":ignoreException": this.parser.resumeErrors = true;
			case ":noDebug": this.interp.errorHandler = (e) -> {};
			case ":noLibraries": this._librariesAllowed = false;

			/* //Useless
			case ":allowJSON":
				switch(args[0].e) {
					case EIdent(id): this.parser.allowJSON = (id.trim() == "true");
					default: //nothing
				}
				return null;
			*/

			case ":include": //legacy importScript from older versions
				var _isAbsolute:Bool = false;
				if(args.length > 1) _isAbsolute = switch(args[1].e) { case EIdent(abs): (abs.trim() == "true"); default: false; }

				switch(args[0].e) {
					case EConst(CString(scriptPath)): _includeSubscript(Std.string(scriptPath.trim()), _isAbsolute);
					default: //nothing
				}
				return null;
		}
		return null;
	}

	//SCRIPT CALLBACKS
	public function stop() {
		for(sub in subScripts) {
			sub.call("onDestroy", []);
			sub.stop();
		}
		subScripts = [];

		expr = null;
		interp = null;
	}

	public function get(name:String):Dynamic
		return (interp != null ? interp.variables.get(name) : null);

	public function set(variable:String, data:Dynamic)
		if(interp != null) interp.variables.set(variable, data);

	public function call(func:String, args:Array<Dynamic>):Dynamic {
		if(interp == null) return null;

		var functionVar = interp.variables.get(func);
		if(functionVar == null || !Reflect.isFunction(functionVar)) return null;
		return (args != null && args.length > 0) ? Reflect.callMethod(null, functionVar, args) : functionVar();
	}
}

#else

/* Ignore this. It's for if hscript is removed */
class HScript {
	public function new(path:String, ?_parentClass:Dynamic, ?_autoRunScript:Bool, ?_ignoreErrors:Bool) {
		throw "HScript is not supported on this platform!";
	}
}

#end

class HaxeCode extends HScript {
	#if LUA_ALLOWED
	public var parentLua:FunkinLua;
	#else
	public var parentLua:Dynamic;
	#end

	#if LUA_ALLOWED
	override public function new(?parent:FunkinLua)
	#else
	override public function new(?parent:Dynamic)
	#end
	{
		super(null, null, false, false); //legally forced to put this by the haxe gods

		#if HSCRIPT_ALLOWED
		if(parser == null) this.initParser();
		if(interp == null) this.initInterp();

		if(FlxG.state is PlayState) this.setParent(PlayState.instance);
		else this.setParent(LuaUtils.getHScriptScriptObject());

		for(key => value in HScript.classes) interp.variables.set(key, value);

		interp.variables.set('this', this);
		interp.variables.set('Alphabet', objects.Alphabet);
		interp.variables.set('CustomSubstate', psychlua.CustomSubstate);

		HScript.addHScriptExtras(interp, LuaUtils.isPlayStateScript(interp.scriptObject));

		if(parent != null) {
			this.parentLua = parent;
			interp.variables.set('parentLua', #if LUA_ALLOWED parent #else null #end);
			interp.variables.set('scriptName', #if LUA_ALLOWED parent.scriptName #else null #end);
		}
		#end
	}

	#if HSCRIPT_ALLOWED
	override function initInterp() {
		interp = new Interp();
		interp.onMetadata = this.onMetadata;
		interp.importFailedCallback = this.onImportFailed;
	}

	public function execute(codeToRun:String):Dynamic {
		if(parser == null) initParser();
		parser.line = 1;

		return interp.execute(parser.parseString(codeToRun, (parentLua != null ? '${parentLua.scriptName}:runHaxeCode' : 'hscript')));
	}

	public function destroy() {
		expr = null;
		interp = null;
		parser = null;
	}
	#end

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua) {
		if(funk == null) return;

		funk.addLocalCallback("runHaxeCode", function(codeToRun:String):Dynamic {
			var returnVal:Dynamic = null;
			#if HSCRIPT_ALLOWED
			try {
				returnVal = funk.hscript.execute(codeToRun);
				return (LuaUtils.isLuaSupported(returnVal) ? returnVal : null);
			} catch(e:Dynamic) {
				FunkinLua.luaTrace('${funk.scriptName}:${funk.lastCalledFunction} - $e', false, false, FlxColor.RED);
			}
			#else
			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
			return returnVal;
		});

		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			#if HSCRIPT_ALLOWED
			if(!funk.hscript.variables.exists(funcToRun)) {
				FunkinLua.luaTrace('${funk.scriptName}:${funk.lastCalledFunction} - Function "${funcToRun}" does not exist!', false, false, FlxColor.RED);
				return null;
			}

			try {
				return funk.hscript.call(funcToRun, funcArgs);
			} catch(e:Dynamic) {
				FunkinLua.luaTrace('${funk.scriptName}:${funk.lastCalledFunction} - $e', false, false, FlxColor.RED);
			}
			#else
			FunkinLua.luaTrace("runHaxeFunction: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end

			return null;
		});

		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			#if HSCRIPT_ALLOWED
			if(funk.hscript == null) return;

			var str:String = '';
			if(libPackage.length > 0) str = libPackage + '.';
			else if(libName == null) libName = '';

			var classObj:Dynamic = Type.resolveClass(str + libName);
			if(classObj == null) classObj = LuaUtils.getMacroAbstractClass(str + libName); //If the class doesn't exist, then it checks for an hscript generated abstract class
			if(classObj == null) classObj = Type.resolveEnum(str + libName); //If the class STILL doesn't exist, then it checks for an enum

			try {
				if(classObj != null)
					funk.hscript.variables.set(libName, classObj);
				else
					FunkinLua.luaTrace("addHaxeLibrary: Library \"" + (str + libName) + "\" does not exist!", false, false, FlxColor.RED);

			} catch(e:Dynamic) {
				FunkinLua.luaTrace('${funk.scriptName}:${funk.lastCalledFunction} - $e', false, false, FlxColor.RED);
			}
			FunkinLua.luaTrace("addHaxeLibrary is deprecated! Import classes using the \"import\" keyword instead!", false, true);

			#else
			FunkinLua.luaTrace("addHaxeLibrary: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
		});
	}
	#end
}