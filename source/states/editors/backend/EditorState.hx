package states.editors.backend;

class EditorState extends MusicBeatState
{
	var _mouseSystemSetting:Bool = false;
	override function create() {
		_mouseSystemSetting = FlxG.mouse.useSystemCursor;
		FlxG.mouse.useSystemCursor = true;

		super.create();
	}

	override function destroy() {
		FlxG.mouse.useSystemCursor = _mouseSystemSetting;
		super.destroy();
	}
}
