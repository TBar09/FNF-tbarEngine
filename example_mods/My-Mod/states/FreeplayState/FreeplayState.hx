/**
 * A menu script that runs on the Freeplay menu.
 */

function onCreate() {
	// Triggered when the script is started; some variables weren't created yet.
}

function onCreatePost() {
	// Triggered at the end of "create".
}

function onUpdate(elapsed:Float) {
	// Triggered when the game updates, some variables weren't updated yet.
}

function onUpdatePost(elapsed:Float) {
	// Triggered at the end of "update".
}

function onDestroy() {
	// Triggered when the script is destroyed (The menu is closed).
}

function onCloseSubstate() {
	// Triggered when a substate is closed.
}

function onAddSong(songName:String, weekNum:Int, songCharacter:String, color:Int) {
	// Triggered when a song is added to the freeplay song list.
	
	// `songName`      = The name of the song (example: Song Name).
	// `weekNum`       = The song's week number. 
	// `songCharacter` = The icon that the song uses (example: "icon-face").
	// `color`         = The color array for it's bg (example: [255, 0, 0]).
}

function onSelectedChanger(changer:String) {
	// Triggered when something other than a song is selected.
	
	// `substate` = The substate that was opened (example: "control", "reset", "back").
	// return Function_Stop if you want to stop the game from opening something other than a song.
	return Function_Continue;
}

function onSelectedSong(song, curSelected:Int) {
	// Triggered when a song is selected.
	
	// `song`        = The song data that was selected (example: song.songName, song.color).
	// `curSelected` = A number form of the song that was selected.
	// return Function_Stop if you want to stop the game from starting a song (Good for creating custom events when a song is selected).
	return Function_Continue;
}

function onPlaySong(song, curSelected:Int) {
	// Triggered when a song's instrumental is played.
	
	// `song`        = The song data that was selected (example: song.songName, song.color).
	// `curSelected` = A number form of the song that was selected.
	// return Function_Stop if you want to stop the game from playing a song (Good for creating custom events when a song is played).
	return Function_Continue;
}

function onChangeDifficultyPre(change:Int) {
	// Triggered when the difficulty is changed.
	
	// `change` = A number form of how much you moved, usually moves by 1 (right) or -1 (left).
	// return Function_Stop if you want to stop the game from changing the difficulty.
	return Function_Continue;
}

function onChangeDifficulty(change:Int) {
	// Triggered at the end of "difficulty change".
	
	// `change` = A number form of how much you moved, usually moves by 1 (right) or -1 (left).
}

function onChangeSelectionPre(change:Int, playSound:Bool) {
	// Triggered when the song is changed.
	
	// `change`    = A number form of how much you moved, usually moves by 1 (up) or -1 (down).
	// `playSound` = Does the even play a sound?
	// return Function_Stop if you want to stop the game from changing songs.
	return Function_Continue;
}

function onChangeSelection(change:Int, playSound:Bool) {
	// Triggered at the end of "song change".
	
	// `change` = A number form of how much you moved, usually moves by 1 (up) or -1 (down).
	// `playSound` = Does the even play a sound?
}