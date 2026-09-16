package psychlua.callbacks;

#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end

/*
 * Functions for script related manipulation
 */
class ScriptFunctions
{
	public static inline function implement(funk:FunkinLua, game:PlayState)
	{
		if(funk == null || game == null) return;
		var lua:State = funk.lua;

		Lua_helper.add_callback(lua, "getRunningScripts", function():Array<String> {
			var runningScripts:Array<String> = [];
			for(script in game.luaArray) {
				runningScripts.push(script.scriptName);
			}

			return runningScripts;
		});

		funk.addLocalCallback("setOnScripts", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(funk.scriptName)) exclusions.push(funk.scriptName);
			game.setOnScripts(varName, arg, exclusions);
		});
		funk.addLocalCallback("setOnHScript", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(funk.scriptName)) exclusions.push(funk.scriptName);
			game.setOnHScript(varName, arg, exclusions);
		});
		funk.addLocalCallback("setOnLuas", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(funk.scriptName)) exclusions.push(funk.scriptName);
			game.setOnLuas(varName, arg, exclusions);
		});

		funk.addLocalCallback("callOnScripts", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null) {
			if(excludeScripts == null) excludeScripts = [];
			if(ignoreSelf && !excludeScripts.contains(funk.scriptName)) excludeScripts.push(funk.scriptName);
			return game.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});
		funk.addLocalCallback("callOnLuas", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null) {
			if(excludeScripts == null) excludeScripts = [];
			if(ignoreSelf && !excludeScripts.contains(funk.scriptName)) excludeScripts.push(funk.scriptName);
			return game.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});
		funk.addLocalCallback("callOnHScript", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops:Bool = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null) {
			if(excludeScripts == null) excludeScripts = [];
			if(ignoreSelf && !excludeScripts.contains(funk.scriptName)) excludeScripts.push(funk.scriptName);
			return game.callOnHScript(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});

		Lua_helper.add_callback(lua, "callScript", function(luaFile:String, funcName:String, ?args:Array<Dynamic> = null):Dynamic {
			if(args == null) args = [];

			var foundScript:String = funk.findScript(luaFile);
			if(foundScript != null) {
				for (luaInstance in game.luaArray) {
					if(luaInstance.scriptName == foundScript) {
						return luaInstance.call(funcName, args);
					}
				}
			}
			return null;
		});

		Lua_helper.add_callback(lua, "getGlobalFromScript", function(luaFile:String, global:String):Dynamic { // returns the global from a script
			var foundScript:String = funk.findScript(luaFile);
			if(foundScript != null) {
				for (luaInstance in game.luaArray) {
					if(luaInstance.scriptName == foundScript) {
						return luaInstance.get(global);
					}
				}
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setGlobalFromScript", function(luaFile:String, global:String, val:Dynamic):Bool {
			var foundScript:String = funk.findScript(luaFile);
			if(foundScript != null) {
				for (luaInstance in game.luaArray) {
					if(luaInstance.scriptName == foundScript) {
						luaInstance.set(global, val);
						return true;
					}
				}
			}
			return false;
		});

		/*Lua_helper.add_callback(lua, "getGlobals", function(luaFile:String) { // returns a copy of the specified file's globals
			var foundScript:String = funk.findScript(luaFile);
			if(foundScript != null)
			{
				for (luaInstance in game.luaArray)
				{
					if(luaInstance.scriptName == foundScript)
					{
						Lua.newtable(lua);
						var tableIdx = Lua.gettop(lua);

						Lua.pushvalue(luaInstance.lua, Lua.LUA_GLOBALSINDEX);
						while(Lua.next(luaInstance.lua, -2) != 0) {
							// key = -2
							// value = -1

							var pop:Int = 0;

							// Manual conversion
							// first we convert the key
							if(Lua.isnumber(luaInstance.lua,-2)){
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -2));
								pop++;
							}else if(Lua.isstring(luaInstance.lua,-2)){
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -2));
								pop++;
							}else if(Lua.isboolean(luaInstance.lua,-2)){
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -2));
								pop++;
							}
							// TODO: table


							// then the value
							if(Lua.isnumber(luaInstance.lua,-1)){
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
								pop++;
							}else if(Lua.isstring(luaInstance.lua,-1)){
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
								pop++;
							}else if(Lua.isboolean(luaInstance.lua,-1)){
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
								pop++;
							}
							// TODO: table

							if(pop==2)Lua.rawset(lua, tableIdx); // then set it
							Lua.pop(luaInstance.lua, 1); // for the loop
						}
						Lua.pop(luaInstance.lua,1); // end the loop entirely
						Lua.pushvalue(lua, tableIdx); // push the table onto the stack so it gets returned

						return;
					}

				}
			}
		});*/
		Lua_helper.add_callback(lua, "isRunning", function(luaFile:String):Bool {
			var foundScript:String = funk.findScript(luaFile);
			if(foundScript != null) {
				for (luaInstance in game.luaArray) {
					if(luaInstance.scriptName == foundScript) return true;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "setVar", function(varName:String, value:Dynamic):Dynamic {
			PlayState.instance.variables.set(varName, value);
			return value;
		});
		Lua_helper.add_callback(lua, "getVar", function(varName:String):Dynamic {
			return PlayState.instance.variables.get(varName);
		});

		Lua_helper.add_callback(lua, "addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf.
			var foundScript:String = funk.findScript(luaFile);
			if(foundScript != null)
			{
				if(!ignoreAlreadyRunning) {
					for (luaInstance in game.luaArray) {
						if(luaInstance.scriptName == foundScript) {
							FunkinLua.luaTrace('addLuaScript: The script "' + foundScript + '" is already running!');
							return;
						}
					}
				}
				@:privateAccess game.luaArray.push(new FunkinLua(foundScript));
				return;
			}
			FunkinLua.luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addHScript", function(haxeFile:String, ?ignoreAlreadyRunning:Bool = false) {
			#if HSCRIPT_ALLOWED
			var foundScript:String = funk.findScript(haxeFile, Paths.HSCRIPT_EXT);
			if(foundScript != null)
			{
				if(!ignoreAlreadyRunning) {
					for (script in game.hscriptArray) {
						if(script.scriptName == foundScript) {
							FunkinLua.luaTrace('addHScript: The script "' + foundScript + '" is already running!');
							return;
						}
					}
				}

				@:privateAccess game.hscriptArray.push(new HScript(foundScript));
				return;
			}
			FunkinLua.luaTrace("addHScript: Script doesn't exist!", false, false, FlxColor.RED);
			#else
			FunkinLua.luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});
		Lua_helper.add_callback(lua, "removeLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) {
			var foundScript:String = funk.findScript(luaFile);
			if(foundScript != null) {
				for (luaInstance in game.luaArray) {
					if(luaInstance.scriptName == foundScript) {
						luaInstance.stop();
						game.luaArray.remove(luaInstance);
						trace('Closing script ' + luaInstance.scriptName);
						return true;
					}
				}
			}
			FunkinLua.luaTrace('removeLuaScript: Script "${luaFile}" isn\'t running!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "removeHScript", function(haxeFile:String, ?ignoreAlreadyRunning:Bool = false) {
			#if HSCRIPT_ALLOWED
			var foundScript:String = funk.findScript(haxeFile, Paths.HSCRIPT_EXT);
			if(foundScript != null) {
				for (script in game.hscriptArray) {
					if(script.scriptName == foundScript) {
						script.stop();
						game.hscriptArray.remove(script);
						trace('Closing script ' + (script.scriptName != null ? script.scriptName : haxeFile));
						return true;
					}
				}
			}
			FunkinLua.luaTrace('removeHScript: Script "${haxeFile}" isn\'t running!', false, false, FlxColor.RED);
			return false;
			#else
			FunkinLua.luaTrace("removeHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});
	}
}
