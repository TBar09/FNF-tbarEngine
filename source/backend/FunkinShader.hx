package backend;

import flixel.system.FlxAssets.FlxShader;
import flixel.addons.display.FlxRuntimeShader;
import lime.graphics.opengl.GLProgram;
import lime.app.Application;

using StringTools;
class FunkinShader extends FlxShader implements IErrorHandler
{
	public var shaderName:String = '';
	public dynamic function onError(error:Dynamic):Void {}
	public function new(?shaderName:String)
	{
		this.shaderName = shaderName;
		super();
	}

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			final res = super.__createGLProgram(vertexSource, fragmentSource);
			return res;
		}
		catch (error)
		{
			FunkinShader.crashSave(this.shaderName, error, onError);
			return null;
		}
	}
	
	public static function crashSave(shaderName:String, error:Dynamic, onError:Dynamic) // prevent the app from dying immediately
	{
		if(shaderName == null) shaderName = 'unnamed';
		var alertTitle:String = 'Error on Shader: "$shaderName"';

		trace(error);

		#if !debug
		// Save a crash log on Release builds
		var errMsg:String = "";
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");

		if (!sys.FileSystem.exists('./crash/'))
			sys.FileSystem.createDirectory('./crash/');

		var crashLogPath:String = './crash/shader_${shaderName}_${dateNow}.txt';
		sys.io.File.saveContent(crashLogPath, error);
		Application.current.window.alert('Error log saved at: $crashLogPath', alertTitle);
		#else
		Application.current.window.alert('Error logs aren\'t created on debug builds, check the trace log instead.', alertTitle);
		#end

		onError(error);
	}
}

class FunkinRuntimeShader extends FlxRuntimeShader implements IErrorHandler
{
	public var shaderName:String = '';
	public dynamic function onError(error:Dynamic):Void {}
	public function new(?shaderName:String, ?fragmentSource:String, ?vertexSource:String)
	{
		this.shaderName = shaderName;
		super(fragmentSource, vertexSource);
	}

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			final res = super.__createGLProgram(vertexSource, fragmentSource);
			return res;
		}
		catch (error)
		{
			FunkinShader.crashSave(this.shaderName, error, onError);
			return null;
		}
	}
}

interface IErrorHandler
{
	public var shaderName:String;
	public dynamic function onError(error:Dynamic):Void;
}