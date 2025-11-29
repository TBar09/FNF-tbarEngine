package objects;

#if VIDEOS_ALLOWED
import flixel.FlxG;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.flixel.FlxVideo;

class FunkinVideo extends FlxVideoSprite {
	public var onFinish:(skipped:Bool) -> Void;

	public static final video_options:Map<String, String> = [
		"looping" => ":input-repeat=65535",
		"muted" => ":no-audio"
	];

	public var skippable:Bool = false;
	public var loaded:Bool = false;
	public var autoHandleVolume:Bool = true;
	
	var isDestroyed:Bool = false;

	public function new(canSkip:Bool = true) {
		this.skippable = canSkip;

		super();

		antialiasing = ClientPrefs.data.antialiasing;
		scrollFactor.set();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		bitmap.onFormatSetup.add(function() {
			if (this != null && bitmap != null && bitmap.bitmapData != null) {
				final scale:Float = Math.min(FlxG.width / bitmap.bitmapData.width, FlxG.height / bitmap.bitmapData.height);

				setGraphicSize(Std.int(bitmap.bitmapData.width * scale), Std.int(bitmap.bitmapData.height * scale));
				updateHitbox();
				screenCenter();

				#if FLX_SOUND_SYSTEM
				if(autoHandleVolume) {
					autoVolumeHandle = false;
					bitmap.volume = getVolumeFromFlxG(3); //The video is just too quiet...
				}
				#end
			}
		});

		bitmap.onEndReached.add(function() {
			if(!isDestroyed) {
				if(onFinish != null) onFinish(false);
				this.destroy();
			}
		});
	}

	public function loadVideo(filePath:String, ?loop:Dynamic = false):Bool {
		if(!loaded) {
			this.load(filePath, loop ? ['input-repeat=65545'] : null);
			loaded = true;
			return true;
		}
		trace("WARNING: Video already has it's data loaded!");
		return false;
	}

	public function playVideo():Bool {
		if(!loaded) {
			trace("WARNING: Cannot play video because it has not been loaded!");
			return false;
		}
		this.play();
		return true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if FLX_SOUND_SYSTEM
		if(!isDestroyed && autoHandleVolume) bitmap.volume = getVolumeFromFlxG(3);
		#end
		if(skippable && FlxG.keys.justPressed.SPACE && !isDestroyed) {
			if(onFinish != null) onFinish(true);
			this.destroy();
		}
	}

	override function destroy() {
		if(isDestroyed) return;

		onFinish = null;
		if(FlxG.state != null) { //idk Psych 1.0 had it so
			if(FlxG.state.members.contains(this)) FlxG.state.remove(this);
			if(FlxG.state.subState != null && FlxG.state.subState.members.contains(this)) FlxG.state.subState.remove(this);
		}

		super.destroy();
		isDestroyed = true;
	}

	inline function getVolumeFromFlxG(multiplier:Float = 3):Int {
		return Std.int(multiplier * ((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume) * 100);
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State, game:PlayState) {
		if(lua == null || game == null) return;

		Lua_helper.add_callback(lua, "startVideo", function(videoFile:String, ?skippable:Bool = true, ?loop:Bool = false) {
			if(FileSystem.exists(Paths.video(videoFile)) || videoFile.startsWith("https://")) {
				game.startVideo(videoFile, skippable, loop);
				return true;
			} else {
				psychlua.FunkinLua.luaTrace('startVideo: Video file not found: $videoFile', false, false, FlxColor.RED);
			}
			return false;
		});
	}
	#end
}
#else
class FunkinVideo {
	public function new(?canSkip:Bool) {
		throw "Videos are not supported on this platform!";
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State, game:PlayState) {
		if(lua == null || game == null) return;

		Lua_helper.add_callback(lua, "startVideo", function(videoFile:String, ?skippable:Bool = true, ?loop:Bool = false) {
			if(game.endingSong) game.endSong();
			else game.startCountdown();

			return true;
		});
	}
	#end
}
#end
