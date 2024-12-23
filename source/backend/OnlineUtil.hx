package backend;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class OnlineUtil {
	// [value, github link ext]
	public static var onlineData:Map<String, Dynamic> = [
		"introText" =>     ["", "online_data/IntroText.data"],
		"latestVersion" => ["", "online_data/CurrentVersion.data"],
		"modWebsite" =>    ["", "online_data/MainEngineWebsite.data"],
	];
	public static final _githubLink:String = "https://raw.githubusercontent.com/TBar09/TBar-Engine/main/";
	
	public static function loadOnlinePrefs()
	{
		for (webData => dataValue in onlineData) {
			var http = new haxe.Http('${_githubLink}${dataValue[1]}');
			http.onData = function (data:String)
			{
				onlineData.set(webData, [data.split('\n')[0], onlineData.get(webData)[1]]);
			}
			http.onError = function (error) {
				trace('error: $error');
			}
			http.request();
		}
	}
	
	public static function loadDataFromSite(url:String) {
		var dataFromUrl = "Data not found!";
		if(url != null && url.length > 0) {
			var http = new haxe.Http('$url');
			http.onData = function (data:String)
			{
				dataFromUrl = data; //you might need to trim it
			}
			http.onError = function (error) {
				trace('error: $error');
			}
			http.request();
		}
		return dataFromUrl;
	}
}
