package;

import Sys.sleep;
//import discord_rpc.DiscordRpc;

import Sys.sleep;
import lime.app.Application;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

import openfl.display.BitmapData;
import flixel.util.typeLimit.OneOfTwo;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

using StringTools;


class DiscordClient
{
	public static var isInitialized:Bool = false;
	private static final _defaultID:String = "1180762119369666620";
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordRichPresence = DiscordRichPresence.create();
	public static var isDiscordUser:Bool = false;
	
	//discord info variables
	public static var userInfo:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	public static function check()
	{
		initialize();
		if(isInitialized) shutdown();
	}
	
	public static function prepare()
	{
		if(!isInitialized) initialize();

		Application.current.window.onClose.add(function() {
			if(isInitialized) shutdown();
		});
	}

	public dynamic static function shutdown() {
		Discord.Shutdown();
		isInitialized = false;
	}
	
	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		if (Std.parseInt(cast(requestPtr.discriminator, String)) != 0) //New Discord IDs/Discriminator system
			trace('(Discord) Connected to User (${cast(requestPtr.username, String)}#${cast(requestPtr.discriminator, String)})');
		else //Old discriminators
			trace('(Discord) Connected to User (${cast(requestPtr.username, String)})');
		
		isDiscordUser = true;
		updateDiscordInfo(request);
		changePresence();
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('Discord: Error ($errorCode: ${cast(message, String)})');
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('Discord: Disconnected ($errorCode: ${cast(message, String)})');
	}

	public static function initialize()
	{
		var discordHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), 1, null);

		if(!isInitialized) trace("Discord Client initialized");

		sys.thread.Thread.create(() ->
		{
			var localID:String = clientID;
			while (localID == clientID)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();

				// Wait 2 seconds until the next loop...
				Sys.sleep(2);
			}
		});
		isInitialized = true;
	}

	public static function changePresence(?details:String = 'In the Menus', ?state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{	
		var startTimestamp:Float = 0;
		if (hasStartTimestamp) startTimestamp = Date.now().getTime();
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		presence.details = details;
		presence.state = state;
		presence.largeImageKey = 'icon';
		presence.largeImageText = "T-Bar Engine Version: " + MainMenuState.tbarEngineVersion;
		presence.smallImageKey = smallImageKey;
		// Obtained times are in milliseconds so they are divided so Discord can use it
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		presence.button1Label = "Download Fork";
		presence.button1Url = "https://github.com/TBar09/TBar-Engine";
		presence.button2Label = "Youtube Channel";
		presence.button2Url = "https://www.youtube.com/@tbar7460";
		
		updatePresence();
		
		#if GLOBAL_SCRIPTS hscript.ScriptGlobal.callGlobalScript("onChangePresence", [presence]); #end
	}
	
	public static function updateDiscordInfo(request:cpp.RawConstPointer<DiscordUser>) {
		final discReq = cpp.ConstPointer.fromRaw(request).ptr;
		userInfo = [
			"userId" => cast(discReq.userId, String),
			"username" => cast(discReq.username, String),
			"discriminator" => Std.parseInt(cast(discReq.discriminator, String)),
			"avatar" => cast(discReq.avatar, String),
			"globalName" => cast(discReq.globalName, String),
			"bot" => cast(discReq.bot, Bool),
			"flags" => cast(discReq.flags, Int),
			"premiumType" => cast(discReq.premiumType, NitroType),
			"handle" => ((Std.parseInt(cast(discReq.discriminator, String)) != 0) ? '${cast(discReq.username, String)}#${Std.parseInt(cast(discReq.discriminator, String))}' : cast(discReq.username, String))
		];
	}
	
	#if MODS_ALLOWED
	public static function loadModRPC()
	{
		var pack:Dynamic = Paths.getPack();
		if(pack != null && pack.discordRPC != null && pack.discordRPC != clientID) clientID = pack.discordRPC;
		else clientID = _defaultID;
	}
	#end

	public static function updatePresence()Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	public static function resetClientID() clientID = _defaultID;

	private static function set_clientID(newID:String)
	{
		var change:Bool = (clientID != newID);
		clientID = newID;

		if(change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}
		return newID;
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changeDiscordPresence", changePresence);

		Lua_helper.add_callback(lua, "changeDiscordClientID", function(?newID:String = null) {
			if(newID == null) newID = _defaultID;
			clientID = newID;
		});
	}
	#end
}

enum abstract NitroType(Int) to Int from Int
{
	var NONE = 0;
	var NITRO_CLASSIC = 1;
	var NITRO = 2;
	var NITRO_BASIC = 3;
}
