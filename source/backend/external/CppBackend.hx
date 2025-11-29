package backend.external;

#if(cpp && windows)
import backend.util.CppAPI.MessageBoxIcon;
import backend.util.CppAPI.MessageBoxType;
#end

#if(cpp && windows)
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
')
#elseif(cpp && linux)
@:cppFileCode("#include <stdio.h>")
#end
class CppBackend
{
	#if(cpp && windows)
	@:functionCode("
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);

		return (allocatedRAM / 1024);
	")
	#elseif(cpp && linux)
	@:functionCode('
		FILE *meminfo = fopen("/proc/meminfo", "r");
		if(meminfo == NULL)	return -1;

		char line[256];
		while(fgets(line, sizeof(line), meminfo)) {
			int ram;
			if(sscanf(line, "MemTotal: %d kB", &ram) == 1) {
				fclose(meminfo);
				return (ram / 1024);
			}
		}

		fclose(meminfo);
		return -1;
	')
	#end
	public static function obtainRAM() { return 0; }

	#if(cpp && windows)
	/*
	 * Thanks CodenameCrew 
	 * https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/utils/native/Windows.hx#L208
	 */
	@:functionCode('
		// https://stackoverflow.com/questions/15543571/allocconsole-not-displaying-cout
		if(!AllocConsole()) return;

		freopen("CONIN$", "r", stdin);
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
	')
	public static function allocConsole() {}

	@:functionCode('
		system("CLS");
		std::cout<< "" <<std::flush;
	')
	public static function clearConsole() {}

	@:functionCode("
        HWND window = GetActiveWindow();
		int isDark = isDarkMode ? 1 : 0;

        if (DwmSetWindowAttribute(window, 19, &isDark, sizeof(isDark)) != S_OK) {
            DwmSetWindowAttribute(window, 20, &isDark, sizeof(isDark));
        }
        UpdateWindow(window);
    ")
	public static function setWindowColorMode(isDarkMode:Bool) {}
	
	@:functionCode("
        HWND window = GetActiveWindow();

		COLORREF finalColor;
		if(color[0] == -1 && color[1] == -1 && color[2] == -1 && color[3] == -1) {
			finalColor = 0xFFFFFFFF; // Default border
		} else if(color[3] == 0) {
			finalColor = 0xFFFFFFFE; // No border (must have setBorder as true)
		} else {
			finalColor = RGB(color[0], color[1], color[2]); // Use your custom color
		}

		if (window != NULL) {
			if(setHeader) DwmSetWindowAttribute(window, 35, &finalColor, sizeof(COLORREF));
			if(setBorder) DwmSetWindowAttribute(window, 34, &finalColor, sizeof(COLORREF));

			UpdateWindow(window);
		}
    ")
	public static function setWindowBorderColor(color:Array<Int>, setHeader:Bool = true, setBorder:Bool = false) {}

	@:functionCode('
	HWND window = GetActiveWindow();

	COLORREF finalColor;
	if(color[0] == -1 && color[1] == -1 && color[2] == -1 && color[3] == -1) {
		finalColor = 0xFFFFFFFF; // Default border
	} else {
		finalColor = RGB(color[0], color[1], color[2]); // Use your custom color
	}

	if (window != NULL) {
		DwmSetWindowAttribute(window, 36, &finalColor, sizeof(COLORREF));
		UpdateWindow(window);
	}
	')
	public static function setWindowTitleColor(color:Array<Int>) {}

	public static function makeMessageBox(title:String, text:String, icon:MessageBoxIcon, msgType:MessageBoxType):Int {
		return untyped __cpp__('MessageBoxA(GetActiveWindow(), text, title, icon | msgType)');
	}
	#end
}
