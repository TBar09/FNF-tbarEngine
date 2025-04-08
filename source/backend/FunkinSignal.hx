package backend;

/*
 * FunkinSignal: An alternative to FlxSignals that use tags and functions to identify signals, making it more
 * friendly to HScript support.
 */

typedef SignalParams = {
	var funcToRun:Dynamic;
	var singleUse:Bool;
}

class FunkinSignal {

	/*
	 * All of the signals in the current FunkinSignal.
	 */
	#if (haxe >= "4.0.0")
	public var signals:Map<String, SignalParams> = new Map();
	#else
	public var signals:Map<String, SignalParams> = new Map<String, SignalParams>();
	#end

	public function new() {};

	/*
	 * Add a function to the signal to be called, add a tag so it can be properly identified.
	 */
	public function add(tag:String, func:Dynamic) {
		if(tag != null && func != null) this.signals.set(tag, {funcToRun: func, singleUse: false});
	}

	/*
	 * Add a function to the signal to be called, but the function will only be called ONCE before being removed.
	 */
	public function addOnce(tag:String, func:Dynamic) {
		if(tag != null && func != null) this.signals.set(tag, {funcToRun: func, singleUse: true});
	}

	/*
	 * Remove a function from the signal by tag.
	 */
	public function remove(tag:String):Bool {
		if(tag != null && this.signals.exists(tag)) {
			this.signals.remove(tag);
			return true;
		}
		return false;
	}

	/*
	 * Remove ALL functions from the current signal. This is different from destroying the signal as this will
	 * still retain it's map property.
	 */
	public function removeAll() {
		this.signals.clear();
	}

	/*
	 * Check if a function exists by tag.
	 */
	public function has(tag:String):Bool
		return (tag != null && this.signals.exists(tag));

	/*
	 * Launch the function with a given set of parameters to all functions currently in the signal.
	 * (functions with the singleUse property will be destroyed after one usage)
	 */
	public function dispatch(params:Dynamic) {
		for(key => value in this.signals) {
			//if(value != null && value.funcToRun != null && Reflect.isFunction(value.funcToRun)) {
			if(value != null && value.funcToRun != null) {
				value.funcToRun(params);
				if(value.singleUse) {
					this.remove(key);
				}
			}
		}
	}

	/*
	 * Destroy the signal entirely, along with all of the signals attached to it.
	 */
	public function destroy() {
		this.signals = null;
	}
}