package backend.util;

import haxe.Http;
import haxe.io.Bytes;

/*
 * A small utility class for fetching online data, most likely from the fork's github repo.
 */
class OnlineUtil {
	//[default value, raw data path]
	public static var onlineData:Map<String, Dynamic> = [
		"introText" =>     ["", "online_data/intro_text.data"],
		"latestVersion" => ["0.1.0", "online_data/latest_version.data"],
		"modWebsite" =>    ["https://github.com/TBar09/FNF-tbarEngine/", "online_data/engine-url.data"],
	];

	public static final _githubLink:String = "https://github.com/TBar09/FNF-tbarEngine/";
	public static final _githubRaw:String = "https://raw.githubusercontent.com/TBar09/FNF-tbarEngine/refs/heads/main/";

	public static function loadOnlineData() {
		for(webData => dataValue in onlineData) {
			var _http:Http = new Http(_githubRaw + dataValue[1]);
			_http.onData = function(data:String) {
				onlineData.set(webData, [data.trim(), onlineData.get(webData)[1]]);
			}
			_http.onError = function (error) {
				trace('error: $error');
			}
			_http.request();
		}
		trace("Online data loaded!");
	}

	public static function getDataFromURL(url:String, isBytes:Bool = false):Dynamic {
		var dataFromUrl:Dynamic = null;
		if(url != null && url.length > 0) {
			var _http:Http = new Http(url);
			if(isBytes) {
				_http.onBytes = function(byteData:Bytes) {
					if(dataFromUrl == null) dataFromUrl = byteData;
				}
			} else {
				_http.onData = function(data:String) {
					if(dataFromUrl == null) dataFromUrl = data;
				}
			}
			_http.onError = function(error:Dynamic) {
				trace('Error getting data from ${url}: ${error}');
			}

			_http.request();
		}
		return dataFromUrl;
	}
}