package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxBasic;
import flixel.FlxSprite;
#if (HXSCRIPT_ALLOWED && SOFTCODED_STATES)
import hscript.HScript;
#end
#if sys
import sys.FileSystem;
#end

using StringTools;
class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		quickCallMenuScript("onUpdate", [elapsed]);
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
		quickCallMenuScript("onUpdatePost", [elapsed]);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0) beatHit();
		quickCallMenuScript("onStepHit", []);
	}

	public function beatHit():Void
	{
		quickCallMenuScript("onBeatHit", []);
		//do literally nothing dumbass
	}
	
	#if SOFTCODED_STATES public var scriptsAllowed:Bool = true; #end
	public var menuScriptArray:Array<HScript> = [];
	public function runStateFiles(state:String, checkSpecificScript:Bool = false) {
		#if SOFTCODED_STATES
		if(!scriptsAllowed) return;
		var filesPushed = [];
		for (folder in Paths.getStateScripts(state))
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					#if HXSCRIPT_ALLOWED
					if (file.endsWith((checkSpecificScript ? (state + ".hx") : '.hx')) && !filesPushed.contains(file)) {
						menuScriptArray.push(new HScript(folder + file));
						filesPushed.push(file);
					}
					#else
					break;
					#end
				}
			}
		}
		#end
	}
	
	/*
	* Script
	*/
	public var className:String = "";
	public var useCustomStateName:Bool = false;
	#if SOFTCODED_STATES
	override function create() {
		runStateFiles((useCustomStateName ? className : Type.getClassName(Type.getClass(this))));

		super.create();
		quickCallMenuScript("onCreatePost", []);
	}

	override public function openSubState(subState:FlxSubState) {
		if(quickCallMenuScript("onOpenSubState", [subState]) != FunkinLua.Function_Stop) super.openSubState(subState);
	}
	
	override public function onResize(w:Int, h:Int) {
		super.onResize(w, h);
		quickCallMenuScript("onResize", [w, h]);
	}
	
	override public function draw() {
		if(quickCallMenuScript("onDraw", []) != FunkinLua.Function_Stop) super.draw();
		quickCallMenuScript("onDrawPost", []);
	}
	
	override public function onFocus() {
		super.onFocus();
		quickCallMenuScript("onFocus", []);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		quickCallMenuScript("onFocusLost", []);
	}
	
	override function close() {
		if (quickCallMenuScript("onClose", []) != FunkinLua.Function_Stop) {
			super.close();
			quickCallMenuScript("onClosePost", []);
		}
	}
	
	override function destroy() {
		for (sc in menuScriptArray) {
			sc.call("onDestroy", []);
			sc.stop();
		}
		menuScriptArray = [];
		
		super.destroy();
	}
	#end
	
	public function setOnMenuScript(variable:String, arg:Dynamic) {
		#if (HXSCRIPT_ALLOWED && SOFTCODED_STATES)
		if(!scriptsAllowed) return;
		for (i in 0...menuScriptArray.length) {
			menuScriptArray[i].set(variable, arg);
		}
		#end
	}
	
	public function quickCallMenuScript(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal = FunkinLua.Function_Continue;
		#if (HXSCRIPT_ALLOWED && SOFTCODED_STATES)
		if(!scriptsAllowed) return returnVal;
		for (sc in menuScriptArray) {
			var myValue = sc.call(event, args);
			if(myValue == FunkinLua.Function_StopLua) break;
			if(myValue != null && myValue != FunkinLua.Function_Continue) returnVal = myValue;
		}
		#end
		return returnVal;
	}
	
	public function callOnMenuScript(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal = FunkinLua.Function_Continue;
		#if (HXSCRIPT_ALLOWED && SOFTCODED_STATES)
		if(!scriptsAllowed) return returnVal;
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [];

		for (sc in menuScriptArray) {
			if(exclusions.contains(sc.scriptName)) continue;

			var myValue = sc.call(event, args);
			if(myValue == FunkinLua.Function_StopLua && !ignoreStops) break;
			
			if(myValue != null && myValue != FunkinLua.Function_Continue) returnVal = myValue;
		}
		#end
		return returnVal;
	}
}
