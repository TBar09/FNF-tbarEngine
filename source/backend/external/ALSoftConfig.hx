package backend.external;

import haxe.io.Path;
#if(android || ios)
import lime.system.System;
#end

/*
 * A class that simply points OpenALSoft to a custom configuration file when
 * the game starts up.
 *
 * The config overrides a few global OpenALSoft settings with the aim of
 * improving audio quality on desktop targets.
 */
@:keepInit class ALSoftConfig
{
	#if desktop
	static function __init__():Void {
		#if hl
		var origin:String = Sys.getCwd();
		#elseif(windows || mac || linux)
		var origin:String = Sys.programPath();
		#elseif(android || ios)
		var origin:String = System.applicationStorageDirectory;
		#end

		var configPath:String = Path.directory(Path.withoutExtension(origin));

		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#else //linux
		configPath += "/plugins/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
	}
	#end
}