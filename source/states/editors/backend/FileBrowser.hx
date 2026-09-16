package states.editors.backend;

import openfl.utils.ByteArray;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.events.IOErrorEvent;
import haxe.io.Path;

import lime.ui.FileDialog;
import lime.ui.FileDialogType;

class FileSave {
	public var _file:FileReference;

	public var onComplete:Void->Void;
	public var onCancel:Void->Void;
	public var onError:Void->Void;

	public function new() {
		_file = new FileReference();
	}

	public function start(fileData:String, fileName:String):FileSave {
		if(_file == null) _file = new FileReference();
		_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _onComplete);
		_file.addEventListener(Event.CANCEL, _onCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, _onError);
		_file.save(fileData, fileName);

		return this;
	}

	function _onComplete(_):Void {
		if(onComplete != null) onComplete();
		removeEventListeners();
	}

	function _onCancel(_):Void {
		if(onCancel != null) onCancel();
		removeEventListeners();
	}

	function _onError(_):Void {
		if(onError != null) onError();
		removeEventListeners();
	}

	inline function removeEventListeners() {
		//_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _onComplete);
		_file.removeEventListener(Event.SELECT, _onComplete);
		_file.removeEventListener(Event.COMPLETE, _onComplete);
		_file.removeEventListener(Event.CANCEL, _onCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, _onError);

		onComplete = null;
		onCancel = null;
		onError = null;
		_file = null;
	}
}

class FileBrowse {
	public var _file:FileReferenceCustom;
	public var onComplete:String->String->Void;

	public function new() {
		_file = new FileReferenceCustom();
	}

	public function start(fileFilters:Array<FileTypeFilter>, title:String, ?defaultName:String):FileBrowse {
		var _filters:Array<FileFilter> = [];
		for(file in fileFilters) {
			_filters.push(new FileFilter(file.fileTypeName, file.fileType));
		}

		if(_file == null) _file = new FileReferenceCustom();
		_file.addEventListener(Event.SELECT, on_load);
		_file.addEventListener(Event.CANCEL, on_cancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, on_error);
		_file.browseEx(OPEN, defaultName, title, _filters);

		return this;
	}

	function on_load(_):Void {
		_file.addEventListener(Event.COMPLETE, _onComplete);
		_file.load();
	}

	function on_cancel(_):Void {
		_file.removeEventListener(Event.SELECT, on_load);
		_file.removeEventListener(Event.COMPLETE, _onComplete);
		_file.removeEventListener(Event.CANCEL, on_cancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, on_error);
		onComplete = null;
		_file = null;
	}

	function on_error(_):Void {
		_file.removeEventListener(Event.SELECT, on_load);
		_file.removeEventListener(Event.COMPLETE, _onComplete);
		_file.removeEventListener(Event.CANCEL, on_cancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, on_error);
		onComplete = null;
		_file = null;
	}

	public var collectedData:String;
	public var collectedName:String;
	function _onComplete(_):Void {
		collectedData = _file.data.toString();
		collectedName = _file.name;

		if(onComplete != null) onComplete(collectedData, collectedName);

		_file.removeEventListener(Event.SELECT, on_load);
		_file.removeEventListener(Event.COMPLETE, _onComplete);
		_file.removeEventListener(Event.CANCEL, on_cancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, on_error);
		onComplete = null;
		_file = null;
	}
}

class FolderBrowse {
	public var _file:FileReferenceCustom;
	public var onComplete:Null<String>->Void;

	public function new() {
		_file = new FileReferenceCustom();
	}

	public function start(?title:String = null) {
		_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _onComplete);
		_file.browseEx(OPEN_DIRECTORY, null, title);
	}

	var path:Null<String>;
	function _onComplete(_):Void {
		@:privateAccess this.path = _file.__path;
		if(onComplete != null) onComplete(this.path);

		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _onComplete);
		onComplete = null;
		_file = null;
	}
}


//https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/states/editors/content/FileDialogHandler.hx#L178
class FileReferenceCustom extends FileReference
{
	var _trackSavedPath:String;
	override function saveFileDialog_onSelect(path:String):Void
	{
		_trackSavedPath = path;
		super.saveFileDialog_onSelect(path);
	}
	
	public function browseEx(browseType:FileDialogType = OPEN, ?defaultName:String, ?title:String = null, ?typeFilter:Array<FileFilter> = null):Bool
	{
		__data = null;
		__path = null;

		#if desktop
		var filter = null;
		if(typeFilter != null) {
			var filters = [];

			for(type in typeFilter) {
				filters.push(StringTools.replace(StringTools.replace(type.extension, "*.", ""), ";", ","));
			}

			filter = filters.join(";");
		}

		var openFileDialog = new FileDialog();
		openFileDialog.onCancel.add(openFileDialog_onCancel);
		openFileDialog.onSelect.add(openFileDialog_onSelect);
		openFileDialog.browse(browseType, filter, defaultName, title);
		return true;
		#elseif (js && html5)
		var filter = null;
		if(typeFilter != null) {
			var filters = [];
			for(type in typeFilter) {
				filters.push(StringTools.replace(StringTools.replace(type.extension, "*.", "."), ";", ","));
			}
			filter = filters.join(",");
		}
		if(filter != null) {
			__inputControl.setAttribute("accept", filter);
		}
		__inputControl.onchange = function() {
			var file = __inputControl.files[0];
			modificationDate = Date.fromTime(file.lastModified);
			creationDate = modificationDate;
			size = file.size;
			type = "." + Path.extension(file.name);
			name = Path.withoutDirectory(file.name);
			__path = file.name;
			dispatchEvent(new Event(Event.SELECT));
		}
		__inputControl.click();
		return true;
		#end

		return false;
	}
}

typedef FileTypeFilter = {
	fileTypeName:String,
	fileType:String
}