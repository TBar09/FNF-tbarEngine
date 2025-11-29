package backend.scripts;

/*
 * A "blank canvas" substate specifically made for scripts.
 * `openSubState(new ModScriptSubstate("substateScriptName"));`
 */
class ModScriptSubstate extends MusicBeatSubstate {
	#if SOFTCODED_STATES
	public static var instance:ModScriptSubstate;
	public var data:Dynamic = null;

	public function new(stateName:String, ?_data:Dynamic) {
		if(_data != null) this.data = _data;

		super();
		instance = this;
		this.useCustomStateName = true;
		this.className = stateName;
	}

	override function destroy() {
		instance = null;
		super.destroy();
	}
	#else
	public function new(stateName:String, ?_data:Dynamic) {
		super();
	}
	#end
}