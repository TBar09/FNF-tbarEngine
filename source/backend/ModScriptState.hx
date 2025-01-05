package backend;

using StringTools;
//Used for custom states so you don't have to build off of the base states
class ModScriptState extends MusicBeatState
{
	public static var instance:ModScriptState;
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
