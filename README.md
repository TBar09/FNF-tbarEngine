# TBar-Engine
## When 3D and Psych Engine combine
T-Bar Engine is a 0.6.3 Psych Engine fork that adds 3D model support + some Codename Engine quality-of-life features.
Features from both 0.7.3 Psych Engine and Codename Engine, while still trying it's best to keep the 0.6.3 feel with

# Features
## Away3D
The big one: 3D model support! Using haxe scripting, you can add your own 3D models into the game, which is fully compatible with the mods folder, so you
can make modpacks with models.

## Haxe Scripting
You can now use haxe scripts as an alternative to lua scripting. Haxe scripts use the same callback names as Psych (example: onCreate, onUpdate, goodNoteHit, etc)
while also using some functionalities from Codename scripting.

## Softcoded Menus
Using haxe scripting and the "states" folder in mods, you can modify existing menus and even make your own menus for your modpacks! 
See [unfinished] for the api on all the callbacks and menu specific callbacks.

## More Lua Functions
Lua Scripts have way more lua functions added, some from 0.7.3 and even some completely new ones!

## New Crash Handler
The new crash handler will no longer close the game (unless it's an uncaught error /shrug). Instead, it will reset to the main menu.

## New Videos Handler
T-Bar Engine now uses hxvlc, making it possible to do unskippable cutscenes, midsong cutscenes, and even play videos from an online source.

Example:
```
setWindowColorMode(true, hasWindowsVersion("10"))
getDataFromURL('https://www.youtube.com')
doTweenNumber('coolTween', 1, 45, 3, 'sineInOut')

makeLuaBackdrop("coolBackdrop", "characters/BOYFRIEND", 10, 10, 'x', 0, 0)
addLuaBackdrop("coolBackdrop", true)
```

There are even hardcoded versions of [Ghostutil](https://github.com/AlsoGhostglowDev/Ghost-s-Utilities) functions!

Example:
```
setWindowProperty('borderless', true)
windowAlert('Hi, I'm a message', 'Title Lol')
windowTweenY('windowGoBurY', 100, 7, 'linear')
```

## Installation:
(You must have the components to compile Psych 0.6.3)

Some of the libraries use codename forks, so install them using:
```
haxelib git hscript-improved https://github.com/CodenameCrew/hscript-improved
haxelib git hxdiscord_rpc https://github.com/CodenameCrew/hxdiscord_rpc
haxelib git away3d https://github.com/CodenameCrew/away3d
```

For videos, run:
```
haxelib install hxvlc 1.9.2
```

## Credits
### T-Bar Engine
* T-Bar - Main Programmer / Creator
* Ghostglowdev: Support / Owner of Ghost Utilities
* Swagaruney: Playtesting

### Special Thanks
* Psych Crew - Creating Psych Engine
* Codename Crew - Improved classes, code, and some fixes (Like ndll support on HScript).

# Friday Night Funkin' - Psych Engine
Engine originally used on [Mind Games Mod](https://gamebanana.com/mods/301107), intended to be a fix for the vanilla version's many issues while keeping the casual play aspect of it. Also aiming to be an easier alternative to newbie coders.

## Installation:
You must have [the most up-to-date version of Haxe](https://haxe.org/download/), seriously, stop using 4.1.5, it misses some stuff.

open up a Command Prompt/PowerShell or Terminal, type `haxelib install hmm`

after it finishes, simply type `haxelib run hmm install` in order to install all the needed libraries for *Psych Engine!*

## Customization:

if you wish to disable things like *Lua Scripts* or *Video Cutscenes*, you can read over to `Project.xml`

inside `Project.xml`, you will find several variables to customize Psych Engine to your liking

to start you off, disabling Videos should be simple, simply Delete the line `"VIDEOS_ALLOWED"` or comment it out by wrapping the line in XML-like comments, like this `<!-- YOUR_LINE_HERE -->`

same goes for *Lua Scripts*, comment out or delete the line with `LUA_ALLOWED`, this and other customization options are all available within the `Project.xml` file

## Credits:
* Shadow Mario - Programmer
* RiverOaken - Artist
* Yoshubs - Assistant Programmer

### Special Thanks
* bbpanzu - Ex-Programmer
* Yoshubs - New Input System
* SqirraRNG - Crash Handler and Base code for Chart Editor's Waveform
* KadeDev - Fixed some cool stuff on Chart Editor and other PRs
* iFlicky - Composer of Psync and Tea Time, also made the Dialogue Sounds
* PolybiusProxy - .MP4 Video Loader Library (hxCodec)
* Keoiki - Note Splash Animations
* Smokey - Sprite Atlas Support
* Nebula the Zorua - LUA JIT Fork and some Lua reworks
_____________________________________

# Features

## Attractive animated dialogue boxes:

![](https://user-images.githubusercontent.com/44785097/127706669-71cd5cdb-5c2a-4ecc-871b-98a276ae8070.gif)


## Mod Support
* Probably one of the main points of this engine, you can code in .lua files outside of the source code, making your own weeks without even messing with the source!
* Comes with a Mod Organizing/Disabling Menu.


## Atleast one change to every week:
### Week 1:
  * New Dad Left sing sprite
  * Unused stage lights are now used
### Week 2:
  * Both BF and Skid & Pump does "Hey!" animations
  * Thunders does a quick light flash and zooms the camera in slightly
  * Added a quick transition/cutscene to Monster
### Week 3:
  * BF does "Hey!" during Philly Nice
  * Blammed has a cool new colors flash during that sick part of the song
### Week 4:
  * Better hair physics for Mom/Boyfriend (Maybe even slightly better than Week 7's :eyes:)
  * Henchmen die during all songs. Yeah :(
### Week 5:
  * Bottom Boppers and GF does "Hey!" animations during Cocoa and Eggnog
  * On Winter Horrorland, GF bops her head slower in some parts of the song.
### Week 6:
  * On Thorns, the HUD is hidden during the cutscene
  * Also there's the Background girls being spooky during the "Hey!" parts of the Instrumental

## Cool new Chart Editor changes and countless bug fixes
![](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/docs/img/chart.png?raw=true)
* You can now chart "Event" notes, which are bookmarks that trigger specific actions that usually were hardcoded on the vanilla version of the game.
* Your song's BPM can now have decimal values
* You can manually adjust a Note's strum time if you're really going for milisecond precision
* You can change a note's type on the Editor, it comes with two example types:
  * Alt Animation: Forces an alt animation to play, useful for songs like Ugh/Stress
  * Hey: Forces a "Hey" animation instead of the base Sing animation, if Boyfriend hits this note, Girlfriend will do a "Hey!" too.

## Multiple editors to assist you in making your own Mod
![Screenshot_3](https://user-images.githubusercontent.com/44785097/144629914-1fe55999-2f18-4cc1-bc70-afe616d74ae5.png)
* Working both for Source code modding and Downloaded builds!

## Story mode menu rework:
![](https://i.imgur.com/UB2EKpV.png)
* Added a different BG to every song (less Tutorial)
* All menu characters are now in individual spritesheets, makes modding it easier.

## Credits menu
![Screenshot_1](https://user-images.githubusercontent.com/44785097/144632635-f263fb22-b879-4d6b-96d6-865e9562b907.png)
* You can add a head icon, name, description and a Redirect link for when the player presses Enter while the item is currently selected.

## Awards/Achievements
* The engine comes with 16 example achievements that you can mess with and learn how it works (Check Achievements.hx and search for "checkForAchievement" on PlayState.hx)

## Options menu:
* You can change Note colors, Delay and Combo Offset, Controls and Preferences there.
 * On Preferences you can toggle Downscroll, Middlescroll, Anti-Aliasing, Framerate, Low Quality, Note Splashes, Flashing Lights, etc.

## Other gameplay features:
* When the enemy hits a note, their strum note also glows.
* Lag doesn't impact the camera movement and player icon scaling anymore.
* Some stuff based on Week 7's changes has been put in (Background colors on Freeplay, Note splashes)
* You can reset your Score on Freeplay/Story Mode by pressing Reset button.
* You can listen to a song or adjust Scroll Speed/Damage taken/etc. on Freeplay by pressing Space.
