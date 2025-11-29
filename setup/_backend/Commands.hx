package _backend;

import _backend.CommandUtil; //shouldn't need to import this since this is in the same directory but ehh
import sys.io.Process;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

typedef Haxelib = {
	var name:String;
	var type:String;
	var ?version:String;
	var ?githubUrl:String;
}

class Commands {
	public static function setup(str:String, target:String = null) {
		CommandUtil.print("╔════════════════════════╗");
		CommandUtil.print("║  T-BAR ENGINE - SETUP  ║");
		CommandUtil.print("╚════════════════════════╝");

		switch(target) {
			case "msvs"|"visualstudio"|"visual-studio": //Microsoft Visual Studio only
				if(Sys.systemName().toLowerCase() != "windows") {
					CommandUtil.print('Warning: You only need Microsoft Visual Studio for compiling windows targets!');
					return;
				}

				CommandUtil.print("(This might take a while depending on your PC specs)");
				CommandUtil.print("Downloading Visual Studio Community. Please wait...");
				_setupVisualStudio();

			default: //haxelib or anything else
				CommandUtil.print("Downloading the libraries required to compile T-Bar Engine...");
				_setupHaxelibs();
		}
	}

	/*
	 * Backend stuff
	 */
	public static function _setupVisualStudio() {
		Sys.command("curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe");
		Sys.command("vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p");
		Sys.command("del vs_Community.exe");

		CommandUtil.print("Finished installing Visual Studio Community.");
	}

	public static function _setupHaxelibs() {
		var haxeVersion:String = CommandUtil.defines.get('haxe');
		if(haxeVersion != "4.2.5" && haxeVersion < "4.3.0") {
			CommandUtil.print('════════════════════════════════════════════════════════════════');
			CommandUtil.print('Warning: Your current version of haxe (version ${haxeVersion})');
			CommandUtil.print('has not been tested with T-Bar Engine 2.0 and could end up');
			CommandUtil.print('breaking some classes if used. Try using version 4.2.5 or');
			CommandUtil.print('version 4.3.0 and above.');
			CommandUtil.print('════════════════════════════════════════════════════════════════');
			CommandUtil.print('Proceeding...');
		}

		if(!FileSystem.exists('.haxelib')) FileSystem.createDirectory('../.haxelib');
		if(!FileSystem.exists("./_backend/haxelibs.json")) {
			CommandUtil.print("WARNING: the haxelib.json file doesn't exist!");
			return;
		}

		var jsonData:Array<Haxelib> = Json.parse(File.getContent("./_backend/haxelibs.json")).haxelibs;
		if(jsonData != null) {
			for(lib in jsonData) {
				if(lib.name == null) return;
				switch(lib.type) {
					case "haxelib": //standard haxelib
						//Sys.command('haxelib install ${lib.name} ' + (lib.version != null ? lib.version : "") + ' --skip-dependencies');
						CommandUtil.print('haxelib install ${lib.name}' + (lib.version != null ? ' ${lib.version}' : "") + ' --skip-dependencies');
					case "git":
						//if(lib.githubUrl != null) Sys.command('haxelib git ${lib.name} ${lib.githubUrl} --skip-dependencies');
						if(lib.githubUrl != null) CommandUtil.print('haxelib git ${lib.name} ${lib.githubUrl} --skip-dependencies');
					default:
						CommandUtil.print("WARNING: the haxelib \"" + lib.name + "\" does not have a valid type! Please use \"haxelib\" or \"git\".");
				}
			}
		}

		CommandUtil.print("Finished installing haxelibs.");
		CommandUtil.print("(Note: If a '.haxelib' folder appeared in your repo, then move that folder into the root directory of your source code folder)");
	}
}