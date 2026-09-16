package states.editors.backend;

/*
 * A utility class for converting "T-Bar Engine" charts (Which are just Psych Engine charts) to & from
 * various formats.
 */

import haxe.io.Path;
#if moonchart
import moonchart.formats.fnf.legacy.FNFFpsPlus;
import moonchart.formats.fnf.legacy.FNFLegacy;
import moonchart.formats.fnf.legacy.FNFPsych;
import moonchart.formats.fnf.FNFCodename;
import moonchart.formats.fnf.FNFVSlice;
#end

class ChartUtil {
	#if moonchart
	public static function convertToVSlice(songName:String, legacyData:String, saveFolder:String, ?diff:String = "normal") {
		try {
			saveFolder = Path.addTrailingSlash(saveFolder.replace("\\", "/"));

			var funkinPsych = new FNFPsych().fromJson(legacyData, null, diff);
			var funkinVSlice = new FNFVSlice().fromFormat(funkinPsych);

			var vsliceChart = funkinVSlice.stringify();
			#if sys
			File.saveContent(saveFolder + songName + "-chart.json", vsliceChart.data);
			File.saveContent(saveFolder + songName + "-metadata.json", vsliceChart.meta);
			#end
		} catch(e) {
			trace('Error converting T-Bar Engine chart to VSlice: ' + Std.string(e));
		}
	}

	public static function convertToCodename(songName:String, legacyData:String, saveFolder:String, ?diff:String = "normal") {
		try {
			saveFolder = Path.addTrailingSlash(saveFolder.replace("\\", "/"));

			var funkinPsych = new FNFPsych().fromJson(legacyData, null, diff);
			var funkinCodename = new FNFCodename().fromFormat(funkinPsych);

			var cneChart = funkinCodename.stringify();
			#if sys
			File.saveContent(saveFolder + songName + "-chart.json", cneChart.data);
			File.saveContent(saveFolder + songName + "-meta.json", cneChart.meta);
			#end
		} catch(e) {
			trace('Error converting T-Bar Engine chart to Codename: ' + Std.string(e));
		}
	}

	public static function convertToFPSPlus(songName:String, legacyData:String, saveFolder:String, ?diff:String = "normal") {
		try {
			saveFolder = Path.addTrailingSlash(saveFolder.replace("\\", "/"));

			var funkinPsych = new FNFPsych().fromJson(legacyData, null, diff);
			var funkinFPS = new FNFFpsPlus().fromFormat(funkinPsych);

			var fpsChart = funkinFPS.stringify();
			#if sys
			File.saveContent(saveFolder + songName + diff + "-chart.json", fpsChart.data);
			#end
		} catch(e) {
			trace('Error converting T-Bar Engine chart to FPS+: ' + Std.string(e));
		}
	}

	public static function convertToLegacy(songName:String, legacyData:String, saveFolder:String, ?diff:String = "normal") {
		try {
			saveFolder = Path.addTrailingSlash(saveFolder.replace("\\", "/"));

			var funkinPsych = new FNFPsych().fromJson(legacyData, null, diff);
			var funkinLegacy = new FNFLegacy().fromFormat(funkinPsych);

			var legacyChart = funkinLegacy.stringify();
			#if sys
			File.saveContent(saveFolder + songName + diff + ".json", legacyChart.data);
			#end
		} catch(e) {
			trace('Error converting T-Bar Engine chart to Legacy: ' + Std.string(e));
		}
	}

	public static function convertTo(type:String, songName:String, legacyData:String, saveFolder:String, ?diff:String = "normal") {
		try {
			saveFolder = Path.addTrailingSlash(saveFolder.replace("\\", "/"));

			var funkinPsych = new FNFPsych().fromJson(legacyData, null, diff);
			var __funkinChartType = Type.createInstance(Type.resolveClass("moonchart.formats." + type), []);
			var funkinChart = __funkinChartType.fromFormat(funkinPsych);

			var funkChart = funkinChart.stringify();
			#if sys
			File.saveContent(saveFolder + songName + (diff.toLowerCase() == "normal" ? "" : '-${diff}') + ".json", funkChart.data);
			#end
		} catch(e) {
			trace('Error converting T-Bar Engine chart to ${type}: ' + Std.string(e));
		}
	}

	// Convert from //

	public static function convertFromVSlice(fromData:String, ?fromMetadata:Null<String>, ?diff:String = "normal"):Null<Dynamic> {
		try {
			var funkinChartType = new FNFVSlice().fromJson(fromData, fromMetadata, diff);
			var psychChart = new FNFPsych().fromFormat(funkinChartType);

			return psychChart.stringify();
		} catch(e) {
			trace('Error converting VSlice chart to T-Bar Engine chart: ' + Std.string(e));
		}
		return null;
	}

	public static function convertFromCodename(fromData:String, ?fromMetadata:Null<String>, ?diff:String = "normal"):Null<Dynamic> {
		try {
			var funkinChartType = new FNFCodename().fromJson(fromData, addCodenameMetadataDefaults(fromMetadata, diff), diff);
			var psychChart = new FNFPsych().fromFormat(funkinChartType);

			return psychChart.stringify();
		} catch(e) {
			trace('Error converting Codename chart to T-Bar Engine chart: ' + Std.string(e));
		}
		return null;
	}

	public static function convertFromFPSPlus(fromData:String, ?diff:String = "normal"):Null<Dynamic> {
		try {
			var funkinChartType = new FNFFpsPlus().fromJson(fromData, null, diff);
			var psychChart = new FNFPsych().fromFormat(funkinChartType);

			return psychChart.stringify();
		} catch(e) {
			trace('Error converting FPS+ chart to T-Bar Engine chart: ' + Std.string(e));
		}
		return null;
	}

	public static function convertFromLegacy(fromData:String, ?diff:String = "normal"):Null<Dynamic> {
		try {
			var funkinChartType = new FNFLegacy().fromJson(fromData, null, diff);
			var psychChart = new FNFPsych().fromFormat(funkinChartType);

			return psychChart.stringify();
		} catch(e) {
			trace('Error converting Legacy chart to T-Bar Engine chart: ' + Std.string(e));
		}
		return null;
	}

	public static function convertFrom(type:String, fromData:String, ?fromMetadata:Null<String>, ?diff:String = "normal"):Null<Dynamic> {
		try {
			var __funkinChartType = Type.createInstance(Type.resolveClass("moonchart.formats." + type), []);
			var funkinChartType = __funkinChartType.fromJson(fromData, fromMetadata, diff);

			var legacyChart = new FNFPsych().fromFormat(funkinChartType);
			return legacyChart.stringify();
		} catch(e) {
			trace('Error converting ${type} chart to T-Bar Engine chart: ' + Std.string(e));
		}
		return null;
	}
	#end

	/*
	 * Some Codename Engine metadata jsons doesn't have some default values, which causes moonchart
	 * to crash when importing the chart.
	 */
	public static function addCodenameMetadataDefaults(metadata:String, ?defaultDiff:Null<String>):String {
		var data = #if tjson tjson.TJSON.parse(metadata) #else haxe.Json.parse(metadata) #end;
		if(data == null) return "{}";

		if(Reflect.hasField(data, "stepsPerBeat") == false) Reflect.setField(data, "stepsPerBeat", 4);
		if(Reflect.hasField(data, "beatsPerMeasure") == false) Reflect.setField(data, "beatsPerMeasure", 4);
		if(Reflect.hasField(data, "difficulties") == false) Reflect.setField(data, "difficulties", [defaultDiff]);
		if(Reflect.hasField(data, "opponentModeAllowed") == false) Reflect.setField(data, "opponentModeAllowed", true);
		if(Reflect.hasField(data, "coopAllowed") == false) Reflect.setField(data, "coopAllowed", true);

		return haxe.Json.stringify(data);
	}
}