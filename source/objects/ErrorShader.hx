package objects;

import flixel.system.FlxAssets.FlxShader;
import flixel.addons.display.FlxRuntimeShader;
import lime.graphics.opengl.GLProgram;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
#if (cpp && windows)
import backend.util.CppAPI;
#end

#if desktop
/*
 * An alias to FlxRuntimeShaders / FlxShaders that prints an error log and doesn't crash the game
 * when the shader fails compiling.
 */
class ErrorShader extends FlxShader implements IErrorHandler {
	public var shaderName:String = '';
	public dynamic function onError(error:Dynamic):Void {}

	public function new(?shaderName:String) {
		this.shaderName = shaderName;
		super();
	}

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram {
		try {
			return super.__createGLProgram(vertexSource, fragmentSource);
		} catch(error) {
			ErrorShader.crashSave(this.shaderName, error, onError);
			return null;
		}
	}
	
	public static function crashSave(shaderName:String, error:Dynamic, onError:Dynamic) {
		shaderName = (shaderName == null ? 'unnamed' : shaderName);

		#if (cpp && windows)
		final ret = CppAPI.makeMessageBox('Error on shader "${shaderName}"!', 'There has been an error compiling this shader!\n\nWould you like to save the shader crash log?', MB_ICONWARNING, MB_YESNO);
		if(ret == 6) {
			var errMsg:String = "";
			final dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
			if (!FileSystem.exists('./crash/')) FileSystem.createDirectory('./crash/');

			final crashLogPath:String = './crash/shader_${shaderName}_${dateNow}.txt';
			File.saveContent(crashLogPath, error);
			trace('Shader Crashlog saved at "${crashLogPath}"');
		}
		#else
		var errMsg:String = "";
		final dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
		if(!FileSystem.exists('./crash/')) FileSystem.createDirectory('./crash/');

		final crashLogPath:String = './crash/shader_${shaderName}_${dateNow}.txt';
		File.saveContent(crashLogPath, error);
		FlxG.stage.window.alert('Error log saved at: $crashLogPath', 'Error on shader "${shaderName}"!');
		#end

		onError(error);
	}
}

class ErrorRuntimeShader extends FlxRuntimeShader implements IErrorHandler {
	public var shaderName:String = '';
	public dynamic function onError(error:Dynamic):Void {}

	public function new(?shaderName:String, ?fragmentSource:String, ?vertexSource:String) {
		this.shaderName = shaderName;
		super(fragmentSource, vertexSource);
	}

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram {
		try {
			return super.__createGLProgram(vertexSource, fragmentSource);
		} catch(error) {
			ErrorShader.crashSave(this.shaderName, error, onError);
			return null;
		}
	}
}

interface IErrorHandler {
	public var shaderName:String;
	public dynamic function onError(error:Dynamic):Void;
}
#else
typedef ErrorShader = FlxShader;
typedef ErrorRuntimeShader = FlxRuntimeShader;
#end