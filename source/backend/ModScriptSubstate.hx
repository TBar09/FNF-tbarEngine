package backend;

using StringTools;
//Same as ModScriptState, but for substates
class ModScriptSubstate extends MusicBeatSubstate
{
	public static var instance:ModScriptSubstate;
	public var data:Dynamic = null;
	
	public function new(stateName:String, ?_data:Dynamic) {
		if(_data != null) this.data = _data;

		super();
		instance = this;
		this.useCustomStateName = true;
		this.className = stateName;
	}
	
	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
