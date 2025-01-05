package hscript;

import hscript.Expr.Error;
import hscript.*;

import flixel.FlxG;
#if sys
import sys.io.File;
#else
import openfl.utils.Assets;
#end

using StringTools;
//Code is a modified version of another mod's code, props to them.
interface HscriptInterface {
    public var scriptName:String;
    public function set(variable:String, data:Dynamic):Void;
    public function call(func:String, args:Array<Dynamic>):Dynamic;
    public function stop():Void;
}

class HScript implements HscriptInterface {

    public static var classes:Map<String, Dynamic> = [ //All the default classes
		//Haxe Classes
        "Math" => Math,
        "Std" => Std,
		"StringTools" => StringTools,
		"Reflect" => Reflect,

		//Flixel Classes
        "FlxG" => flixel.FlxG,
        "FlxSprite" => flixel.FlxSprite,
        "FlxTimer" => flixel.util.FlxTimer,
        "FlxTween" => flixel.tweens.FlxTween,
        "FlxEase" => flixel.tweens.FlxEase,
        "FlxText" => flixel.text.FlxText,
        "FlxTrail" => flixel.addons.effects.FlxTrail,
        "FlxBackdrop" => flixel.addons.display.FlxBackdrop,
		#if sys
        "File" => sys.io.File,
        "FileSystem" => sys.FileSystem,
		#end
		
		//Friday Night Funkin' Classes
        "Paths" => Paths,
        "Conductor" => Conductor,
        "PlayState" => PlayState,
        "Boyfriend" => Boyfriend,
        "Character" => Character,
		"CoolUtil"	=> CoolUtil,
        "ClientPrefs" => ClientPrefs,
		
		//Away3d
		#if away3d
		"Flx3DCamera" => flx3d.Flx3DCamera,
        "Flx3DView" => flx3d.Flx3DView,
        "FlxView3D" => flx3d.FlxView3D,
        "Flx3DUtil" => flx3d.Flx3DUtil,
		#end
		
		//Extras
		"Json" => haxe.Json,
		"Assets" => openfl.utils.Assets,
		"FlxBasic" => flixel.FlxBasic,
		"FlxCamera" => flixel.FlxCamera,
		"FlxSound" => #if (flixel >= "5.3.0") flixel.sound.FlxSound #else flixel.system.FlxSound #end,
		"FlxAssets" => flixel.system.FlxAssets,
		"FlxMath" => flixel.math.FlxMath,
		"FlxGroup" => flixel.group.FlxGroup,
		"FlxTypedGroup" => flixel.group.FlxGroup.FlxTypedGroup,
		"FlxSpriteGroup" => flixel.group.FlxSpriteGroup,
		"FlxTypeText" => flixel.addons.text.FlxTypeText,
		#if (!flash) "FlxRuntimeShader" => flixel.addons.display.FlxRuntimeShader, #end
		"ShaderFilter"	=> openfl.filters.ShaderFilter,

		//T-Bar Engine
		#if SOFTCODED_STATES
		"ModScriptState" => backend.ModScriptState,
		"ModScriptSubstate" => backend.ModScriptSubstate,
		"MusicBeatState" => MusicBeatState,
		"MusicBeatSubstate" => MusicBeatSubstate,
		#end
		#if NDLL_ALLOWED "NdllUtil" => backend.NdllUtil, #end

		//Extras with abstracts
		"FlxPoint" => CoolUtil.getMacroAbstractClass("flixel.math.FlxPoint"),
		"FlxAxes" => CoolUtil.getMacroAbstractClass("flixel.util.FlxAxes"),
		"FlxColor" => CoolUtil.getMacroAbstractClass("flixel.util.FlxColor")
    ];
	public static var staticVariables:Map<String, Dynamic> = [];

    public var parser:Parser;
    public var interp:Interp;
    public var expr:Expr;
    public var scriptName:String;
	public var modFolder:String;
	public var subScripts:Array<hscript.HScript> = []; //Scripts attached to this script. You can make some goofy chains with this.

    public function new(path:String) {
        if (parser == null) initParser();
        scriptName = path;
		
		#if MODS_ALLOWED
		if (scriptName != null && scriptName.length > 0)
		{
			var myFolder:Array<String> = scriptName.trim().split('/');
			if(myFolder[0] + '/' == Paths.mods() && (Paths.currentModDirectory == myFolder[1] || Paths.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
				this.modFolder = myFolder[1];
		}
		#end

        interp = new Interp();

        interp.staticVariables = staticVariables;
        interp.allowStaticVariables = interp.allowPublicVariables = true;
        interp.errorHandler = traceError;

        try {
            parser.line = 1; //Reset the parser position.
            expr = parser.parseString(#if sys File.getContent(path) #else Assets.getText(path) #end, path);

			interp.variables.set("this", this);

			for (val in classes.keys()) interp.variables.set(val, classes[val]);

            if (FlxG.state is PlayState) {
                interp.scriptObject = PlayState.instance;
				interp.publicVariables = PlayState.instance.variables;
				
				interp.variables.set("game", PlayState.instance); //runHaxeCode moment
                interp.variables.set("add", function(basic:flixel.FlxBasic, ?frontOfChars:Bool = false) {
                    if (frontOfChars) {
                        PlayState.instance.add(basic);
                        return;
                    }

                    var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
                    if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
                    else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
					
                    PlayState.instance.insert(position, basic);
                });
				
				interp.variables.set('insert', PlayState.instance.insert);
				interp.variables.set('remove', PlayState.instance.remove);
				interp.variables.set('addBehindGF', PlayState.instance.addBehindGF);
				interp.variables.set('addBehindDad', PlayState.instance.addBehindDad);
				interp.variables.set('addBehindBF', PlayState.instance.addBehindBF);
				interp.variables.set('setVar', function(name:String, value:Dynamic) {
					PlayState.instance.variables.set(name, value);
					return value;
				});
				interp.variables.set('getVar', function(name:String) {
					var result:Dynamic = null;
					if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
					return result;
				});
				interp.variables.set('removeVar', function(name:String)
				{
					if(PlayState.instance.variables.exists(name))
					{
						PlayState.instance.variables.remove(name);
						return true;
					}
					return false;
				});
            } else {
				interp.scriptObject = (FlxG.state.subState == null ? FlxG.state : FlxG.state.subState);

				interp.variables.set("game", interp.scriptObject);
				interp.variables.set('add', interp.scriptObject.add);
				interp.variables.set('insert', interp.scriptObject.insert);
				interp.variables.set('remove', interp.scriptObject.remove);
				
				interp.variables.set('setVar', function(name:String, value:Dynamic) {
					interp.variables.set(name, value);
					return value;
				});
				interp.variables.set('getVar', function(name:String) {
					var result:Dynamic = null;
					if(interp.variables.get(name) != null) result = interp.variables.get(name);
					return result;
				});
				interp.variables.set('removeVar', function(name:String)
				{
					if(interp.variables.get(name) != null)
					{
						interp.variables.remove(name);
						return true;
					}
					return false;
				});
			}
			addHScriptExtras();
			
            interp.execute(expr);
            call("onCreate", []);
        } catch (e) {
            FlxG.stage.window.alert('Error on Haxe Script.\n${e.toString()}', 'Error on haxe script!');
        }
    }
	
	function addHScriptExtras() {
		interp.variables.set("state", FlxG.state);
		interp.variables.set("trace", hscriptTrace);
		interp.variables.set('Function_StopLua', FunkinLua.Function_StopLua);
		interp.variables.set('Function_Stop', FunkinLua.Function_Stop);
		interp.variables.set('Function_Continue', FunkinLua.Function_Continue);
		interp.variables.set('buildTarget', CoolUtil.getBuildTarget());
		interp.variables.set('importScript', function(path:String, absolute:Bool = false) {
			var scriptPath = ((Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0) ? Paths.mods(Paths.currentModDirectory + '/' + path) : Paths.mods(path));
			try {
				subScripts.push(new HScript((absolute ? path : scriptPath)));
				return true;
			} catch (e) {
				CoolUtil.hxTrace('importScript: Path "${(absolute ? path : scriptPath)}" does not exist!', 0xFFFF0000);
				return false;
			}
	
			return false;
		});
		interp.variables.set('getModSetting', function(saveTag:String, ?modName:String = null) {
			if(modName == null)
			{
				if(this.modFolder == null)
				{
					CoolUtil.hxTrace('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', 0xFFFF0000);
					return null;
				}
				modName = this.modFolder;
			}
			return CoolUtil.getModSetting(saveTag, modName);
		});
		interp.variables.set("app", {
			title: openfl.Lib.application.meta["name"],
			file: openfl.Lib.application.meta["file"],
			version: MainMenuState.tbarEngineVersion,
			dimensions: {width: 1280, height: 720}
		});
	}

    function hscriptTrace(v:Dynamic) {
        var posInfos = interp.posInfos();
        trace(posInfos.fileName + ":" + posInfos.lineNumber + ": " + Std.string(v));
    }

    function traceError(e:Error) {
        var errorString:String = e.toString();
		CoolUtil.hxTrace(errorString, 0xFFFF0000);
    }

    public function get(name:String) {
        if (interp == null) return null;
        return interp.variables.get(name);
    }

    public function set(variable:String, data:Dynamic)
        if (interp != null) interp.variables.set(variable, data);

    public function call(func:String, args:Array<Dynamic>):Dynamic {
        if (interp == null) return null;

        var functionVar = interp.variables.get(func);
        var hasParams = (args != null && args.length > 0);
        if (functionVar == null || !Reflect.isFunction(functionVar)) return null;
        return hasParams ? Reflect.callMethod(null, functionVar, args) : functionVar();
    }
	
	public function setParent(parent:Dynamic)
		if(interp != null) interp.scriptObject = parent;
	
	public function setPublicMap(map:Map<String, Dynamic>) {
		if(interp != null) interp.publicVariables = map;
		return this;
	}
	
	public function getScriptParent():Dynamic
		return (FlxG.state.subState == null ? FlxG.state : FlxG.state.subState);
	
    public function stop() {
		for (sub in subScripts) {
			sub.call("onDestroy", []);
			sub.stop();
		}
		subScripts = [];
		
        expr = null;
        interp = null;
    }

    public function initParser() {
        parser = new hscript.Parser();
        parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
        parser.preprocesorValues = CoolUtil.getHScriptPreprocessors();
    }
}