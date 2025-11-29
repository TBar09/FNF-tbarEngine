#if !macro
//Discord API
#if DISCORD_ALLOWED
import backend.util.DiscordClient;
#end

//Lua API
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if flxanimate
import flxanimate.*;
#end

//Psych Classes
#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

import backend.Paths;
import backend.Controls;
import backend.util.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;

import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;
import states.LoadingState;

//System classes
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

//Flixel Classes
#if (flixel >= "5.3.0") 
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;
#end
