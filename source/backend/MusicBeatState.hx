package backend;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import flixel.FlxSubState;
import backend.PsychCamera;

#if (SOFTCODED_STATES && HSCRIPT_ALLOWED)
import psychlua.HScript;
#end
import psychlua.LuaUtils;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;

	public var controls(get, never):Controls;
	private function get_controls() return Controls.instance;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables() { return getState().variables; }

	#if (SOFTCODED_STATES && HSCRIPT_ALLOWED)
	public var scripts:Array<HScript> = [];

	public var scriptsAllowed:Bool = true;
	public var useCustomStateName:Bool = false;
	public var className:String = '';
	#end

	var _psychCameraInitialized:Bool = false;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();

		#if (SOFTCODED_STATES && HSCRIPT_ALLOWED)
		if(scriptsAllowed) {
			var _className:String = (useCustomStateName ? className : CoolUtil.getStateName(this));
			runStateFiles(_className);
			className = _className;
		}
		#end

		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.6, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;

		callOnMenuScript("onCreatePost", []);
	}

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		callOnMenuScript("onUpdate", [elapsed]);

		//everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

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
		
		stagesFunc(function(stage:BaseStage) {
			stage.update(elapsed);
		});

		super.update(elapsed);
		
		callOnMenuScript("onUpdatePost", [elapsed]);
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

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState = null) {
		if(nextState == null) nextState = FlxG.state;
		if(nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if(FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() {
		if(FlxTransitionableState.skipNextTransIn) FlxG.resetState();
		else startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null)
	{
		if(nextState == null) nextState = FlxG.state;

		FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
		if(nextState == FlxG.state)
			CustomFadeTransition.finishCallback = function() FlxG.resetState();
		else
			CustomFadeTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function getState():MusicBeatState {
		return cast(FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage) {
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if (curStep % 4 == 0) beatHit();
		
		callOnMenuScript("onStepHit", []);
	}

	public var stages:Array<BaseStage> = [];
	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage) {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
		
		callOnMenuScript("onBeatHit", []);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage) {
			stage.curSection = curSection;
			stage.sectionHit();
		});
		
		callOnMenuScript("onSectionHit", []);
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if(stage != null && stage.exists && stage.active)
				func(stage);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	//Softcoded states stuff

	#if (SOFTCODED_STATES && HSCRIPT_ALLOWED)
	override public function openSubState(subState:FlxSubState) {
		if(callOnMenuScript("onOpenSubState", [subState]) != LuaUtils.Function_Stop) super.openSubState(subState);
	}

	override public function closeSubState() {
		if(callOnMenuScript("onCloseSubState", []) != LuaUtils.Function_Stop) super.closeSubState();
	}

	override public function onResize(w:Int, h:Int) {
		super.onResize(w, h);
		callOnMenuScript("onResize", [w, h]);
	}

	override public function draw() {
		if(callOnMenuScript("onDraw", []) != LuaUtils.Function_Stop) super.draw();
		callOnMenuScript("onDrawPost", []);
	}

	override public function onFocus() {
		super.onFocus();
		callOnMenuScript("onFocus", []);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		callOnMenuScript("onFocusLost", []);
	}

	override function destroy() {
		for (sc in scripts) {
			sc.call("onDestroy", []);
			sc.stop();
		}
		scripts = [];

		super.destroy();
	}

	public function runStateFiles(state:String) {
		if(!scriptsAllowed) return;
		//trace(state);
		
		#if sys
		var filesPushed = [];
		for (folder in Paths.getStateScripts(state)) {
			if(FileSystem.exists(folder)) {
				for(file in FileSystem.readDirectory(folder))
				{
					if (file.toLowerCase().endsWith(Paths.HSCRIPT_EXT) && !filesPushed.contains(file)) {
						scripts.push(new HScript(folder + file, this));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
	}
	#end

	public function setOnMenuScript(variable:String, arg:Dynamic) {
		#if (SOFTCODED_STATES && HSCRIPT_ALLOWED)
		if(scriptsAllowed)
			for (sc in scripts) sc.set(variable, arg);
		#end
	}

	public function callOnMenuScript(event:String, args:Array<Dynamic>, ignoreStops:Bool = true):Dynamic {
		var returnVal = LuaUtils.Function_Continue;

		#if (SOFTCODED_STATES && HSCRIPT_ALLOWED)
		if(scriptsAllowed) {
			for (sc in scripts) {
				var myValue = sc.call(event, args);
				if(!ignoreStops && myValue == LuaUtils.Function_StopHScript) break;

				if(myValue != null && myValue != LuaUtils.Function_Continue) {
					returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}
	
	#if(SOFTCODED_STATES && HSCRIPT_ALLOWED)
	public function importScript(path:String, absolute:Bool = false) {
		#if(MODS_ALLOWED && sys)
		var scriptPath = ((Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) ? Paths.mods(Mods.currentModDirectory + '/' + path) : Paths.mods(path));
		#else
		var scriptPath = Paths.getPath(path);
		#end
		if(absolute) scriptPath = path;

		if(#if sys FileSystem.exists(scriptPath) #else Paths.fileExists(scriptPath, TEXT) #end) {
			scripts.push(new HScript(scriptPath, this));
			return true;
		}

		LuaUtils.hxTrace('Path "$scriptPath" does not exist!', 0xFFFF0000);
		return false;
	}
	#end
}
