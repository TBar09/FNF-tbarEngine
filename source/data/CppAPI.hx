package data;

using StringTools;
class CppAPI
{
	#if cpp
	public static function obtainRAM():Int
		return CppBackend.obtainRAM();
	
	//Detects if you are currently using a certain version of windows
	public static function hasWindowsVersion(vers:String = "10")
	{
		if(lime.system.System.platformLabel.contains(vers)) return true;
		
		return false;
	}

	public static function setDarkMode()
	{
		CppBackend.setWindowColorMode(true);
	}
	
	public static function setLightMode()
	{
		CppBackend.setWindowColorMode(false);
	}
	
	public static function setWindowColorMode(isDarkMode:Bool = false, redrawHeader:Bool = false)
	{
		CppBackend.setWindowColorMode(isDarkMode);
		
		if(redrawHeader) {
			flixel.FlxG.stage.window.borderless = true;
			flixel.FlxG.stage.window.borderless = false;
		}
	}

	public static function setWindowBorderColor(color:Array<Int>, setHeader:Bool = true, setBorder:Bool = false)
	{
		if(color != null)
			CppBackend.setWindowBorderColor([color[0], color[1], color[2], color[3]], setHeader, setBorder);
		else
			CppBackend.setWindowBorderColor([-1, -1, -1, -1], setHeader, setBorder);
	}
	
	public static function setWindowTitleColor(color:Array<Int>)
	{
		if(color != null)
			CppBackend.setWindowBorderColor([color[0], color[1], color[2], color[3]]);
		else
			CppBackend.setWindowTitleColor([-1, -1, -1, -1]);
	}
	
	public static function redrawWindowHeader()
    {
		flixel.FlxG.stage.window.borderless = true;
		flixel.FlxG.stage.window.borderless = false;
    }
	#end
}
