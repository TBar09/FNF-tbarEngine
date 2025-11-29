package backend.debug;

import flixel.util.FlxStringUtil;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.system.System;
import flixel.FlxG;
#if(gl_stats && !disable_cffi && (!html5 || !canvas))
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if cpp 
import cpp.vm.Gc;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 13, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		// prevents the overlay from updating every frame, why would you need to anyways
		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while(times[0] < now - 1000) times.shift();

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText();
		deltaTimeout += deltaTime;
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = 'FPS: ${currentFPS}'
		+ (ClientPrefs.data.showMemory ? '\nMemory: ${FlxStringUtil.formatBytes(memoryMegas)}' : '');

		#if (gl_stats && !disable_cffi && (!html5 || !canvas))
		text += '\ntotalDC: ' + Context3DStats.totalDrawCalls()
		+ '\nstageDC: ' + Context3DStats.contextDrawCalls(DrawCallContext.STAGE)
		+ '\nstage3DDC: ' + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
		#end

		if (currentFPS < FlxG.drawFramerate * 0.5) textColor = 0xFFFF0000;
		else textColor = (currentFPS >= FlxG.drawFramerate - 5 ? 0xFF4CFF00 : 0xFFFFFFFF);
	}

	inline function get_memoryMegas():Float { //more accurate
		#if cpp 
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#else
		return cast(System.totalMemory, UInt);
		#end
	}
}
