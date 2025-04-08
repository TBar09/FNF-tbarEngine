/**
 * A menu script that runs on the Main menu.
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

function onSelectedItem(option:String, selectID:Int) {
	// Triggered when you select an option.
	
	// `option`   = The option name, example: "story_mode", "freeplay", "options". (Create custom ones by modifying the optionShit array).
	// `selectID` = A number form of what was selected, example: 0 = "story_mode", 1 = "freeplay", etc.
	
	// (NOTE: When pressing ESCAPE to go to the title screen, it returns {`option` = "back", `selectID` = -1})
	
	// return Function_Stop if you want to stop the game from selecting (Good for creating custom events when you select items).
	return Function_Continue;
}

function onChangeItemPre(change:Int) {
	// Triggered when you move on the menu.
	// `change` = A number form of how much you moved, usually moves by 1 (down) or -1 (up).
	
	// return Function_Stop if you want to stop the game from changing options.
	return Function_Continue;
}

function onChangeItem(change:Int) {
	// Triggered at the end of the `changeItem` event.
	// `change` = A number form of how much you moved, usually moves by 1 (down) or -1 (up).
}