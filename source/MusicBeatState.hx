package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxBasic;
#if sys
import sys.FileSystem;
#end
#if (HXSCRIPT_ALLOWED && SOFTCODED_STATES)
import hscript.HScript;
#end

using StringTools;
class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		runStateFiles((useCustomStateName ? className : Type.getClassName(Type.getClass(this))));

		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if(!skip) openSubState(new CustomFadeTransition(0.7, true));
		FlxTransitionableState.skipNextTransOut = false;
		
		quickCallMenuScript("onCreatePost", []);
	}

	override function update(elapsed:Float)
	{
		quickCallMenuScript("onUpdate", [elapsed]);
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
		
		quickCallMenuScript("onUpdatePost", [elapsed]);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
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

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0) beatHit();
		quickCallMenuScript("onStepHit", []);
	}

	public function beatHit():Void
	{
		quickCallMenuScript("onBeatHit", []);
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		quickCallMenuScript("onSectionHit", []);
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
	
	/*
	* Scripts
	*/
	public var className:String = "";
	public var useCustomStateName:Bool = false;
	#if SOFTCODED_STATES
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
	
	override function destroy() {
		for (sc in menuScriptArray) {
			sc.call("onDestroy", []);
			sc.stop();
		}
		menuScriptArray = [];
		
		super.destroy();
	}
	#end
	
	public var menuScriptArray:Array<HScript> = [];
	#if SOFTCODED_STATES public var scriptsAllowed:Bool = true; #end
	public function runStateFiles(state:String) {
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
					if (file.endsWith('.hx') && !filesPushed.contains(file)) {
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
	public function setOnMenuScript(variable:String, arg:Dynamic) {
		#if (HXSCRIPT_ALLOWED && SOFTCODED_STATES)
		if(!scriptsAllowed) return;
		for (script in menuScriptArray) {
			script.set(variable, arg);
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
			if(exclusions.contains(sc.scriptName))
				continue;

			var myValue = sc.call(event, args);
			if(myValue == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if(myValue != null && myValue != FunkinLua.Function_Continue) {
				returnVal = myValue;
			}
		}
		#end
		return returnVal;
	}
}