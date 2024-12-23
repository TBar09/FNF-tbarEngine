package backend;

import flixel.FlxG;
import flixel.FlxCamera;

#if HXSCRIPT_ALLOWED
import hscript.HScript;
#end

using StringTools;
//Used for custom states so you don't have to build off of the base states
class ModScriptState extends MusicBeatState
{
	public static var instance:ModScriptState;
	public function new(stateName:String) {
		super();
		instance = this;
		this.useCustomStateName = true;
		this.className = stateName;
	}

	public function resetState() MusicBeatState.switchState(new backend.ModScriptState(className));

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
