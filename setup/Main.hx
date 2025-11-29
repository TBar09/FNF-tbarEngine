package;

import _backend.CommandUtil;
import _backend.Commands;

typedef Command = {
	var callName:String;
	var funcToRun:String->String->Void;
	@:optional var desc:String;
	@:optional var helpDesc:String; //just thought it would be cool
}

class Main {
	static var commandLines(get, never):Array<Command>;
	static function get_commandLines() {
		return [{
				callName: "help", funcToRun: Main.runHelp,
				desc: "Gives information about every available command in the utility.",
				helpDesc: "Run this to get information about the utility or about a specific command."
			}, {
				callName: "setup", funcToRun: Commands.setup,
				desc: "Automatically installs all of the required haxelibs needed to compile T-Bar Engine.",
				helpDesc: "You can do \"setup visualstudio\" to download Visual Studio for windows compiling,\nor type in \"setup haxelib\" to install all of the haxelibs locally so they don't mess with your global haxelibs."
			}];
	}

	public static function main() {
		runTBarWizardLogo();

		var argToRun:String = Sys.args().shift();
		var argToRun2:String = null;
		if(Sys.args() != null && Sys.args().length > 1) argToRun2 = Sys.args()[1];

		if(argToRun == null || Sys.args() == null || Sys.args().length <= 0) {
			runHelp("none", null);
			return;
		}

		for(cmd in commandLines) {
			if(argToRun.toLowerCase() == cmd.callName.toLowerCase()) {
				cmd.funcToRun(argToRun, (argToRun2 != null ? argToRun2 : ""));
				return;
				break;
			}
		}

		CommandUtil.print('The T-Bar Engine wizard does not have the command "$argToRun".');
	}

	static function runHelp(_, help_target:String = null) {
		if(help_target != null && help_target.length > 0) {
			for(cmd in commandLines) {
				if(help_target.toLowerCase() == cmd.callName.toLowerCase() && cmd.helpDesc != null) {
					CommandUtil.print('══════\n${cmd.callName}:\n══════');
					CommandUtil.print('${cmd.desc}\n${cmd.helpDesc}');
					return;
					break;
				}
			}
		} else {
			CommandUtil.print('List of commands available:');
			for(cmd in commandLines) CommandUtil.print('"${cmd.callName}": ${cmd.desc}');
		}
	}

	static function runTBarWizardLogo() {
		var WIZARD_DRAWING:Array<String> = [
			"╔═════════════════════════════════════════╗ ",
			"║    T-BAR ENGINE COMMAND LINE UTILITY    ║╗",
			"╚═════════════════════════════════════════╝║",
			" ╚═════════════════════════════════════════╝"
		];
		for(txt in WIZARD_DRAWING) CommandUtil.print(txt);
	}
}