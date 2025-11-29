package backend.util;

#if(cpp && windows)
import backend.external.CppBackend;
#end

class CppAPI
{
	#if(cpp && (windows || linux))
	public static function obtainRAM():Int { return CppBackend.obtainRAM(); }
	#end

	#if(cpp && windows)
	//Detects if you are currently using a certain version of windows
	public static function hasWindowsVersion(vers:String = "windows 10"):Bool {
		return lime.system.System.platformLabel.toLowerCase().contains(vers.toLowerCase());
	}

	public static function setDarkMode()
		CppBackend.setWindowColorMode(true);

	public static function setLightMode()
		CppBackend.setWindowColorMode(false);

	public static function setWindowColorMode(isDarkMode:Bool = false, redrawHeader:Bool = false) {
		CppBackend.setWindowColorMode(isDarkMode);

		if(redrawHeader) redrawWindowHeader();
	}

	public static function setWindowBorderColor(color:Array<Int>, setHeader:Bool = true, setBorder:Bool = false) {
		if(color != null) CppBackend.setWindowBorderColor([color[0], color[1], color[2], color[3]], setHeader, setBorder);
		else CppBackend.setWindowBorderColor([-1, -1, -1, -1], setHeader, setBorder);
	}

	public static function setWindowTitleColor(color:Array<Int>) {
		if(color != null) CppBackend.setWindowBorderColor([color[0], color[1], color[2], color[3]]);
		else CppBackend.setWindowTitleColor([-1, -1, -1, -1]);
	}

	public static function redrawWindowHeader() {
		for(i in 0...2) {
			FlxG.stage.window.borderless = !FlxG.stage.window.borderless;
		}
	}

	public static function allocConsole() {
		CppBackend.allocConsole();
		CppBackend.clearConsole();
	}

	public static function clearConsole() {
		CppBackend.clearConsole();
	}
	#end

	public static function makeMessageBox(title:String, text:String, ?icon:MessageBoxIcon = MB_ICONINFORMATION, ?msgType:MessageBoxType = MB_OK):Int {
		#if (cpp && windows)
		if(title != null && text != null) return CppBackend.makeMessageBox(title, text, icon, msgType);
		else {
			trace('Error: "title" or "text" parameter is null.');
			return 0;
		}
		#else
		FlxG.stage.window.alert(text, title);
		return 0;
		#end
	}
}

enum abstract MessageBoxIcon(Int) {
	var MB_ICONWARNING = 0x00000030;
	var MB_ICONINFORMATION = 0x00000040;
	var MB_ICONQUESTION = 0x00000020;
	var MB_ICONERROR = 0x00000010;
	var MB_NONE = 0x00;
}

enum abstract MessageBoxType(Int) {
	var MB_ABORTRETRYIGNORE = 0x00000002;
	var MB_CANCELTRYCONTINUE = 0x00000006;
	var MB_HELP = 0x00004000;
	var MB_OKCANCEL = 0x00000001;
	var MB_RETRYCANCEL = 0x00000005;
	var MB_YESNO = 0x00000004;
	var MB_YESNOCANCEL = 0x00000003;
	var MB_OK = 0x00000000;
}