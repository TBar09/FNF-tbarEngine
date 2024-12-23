/**
 * A menu script that runs on the Options menu.
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

function onSelectedItem(label:String, selectID:Int) {
	// Triggered when an option category is selected.
	
	// `label`    = The option name (example: "Note Colors", "Controls", "Graphics", "Visuals and UI", "Gameplay", "Application", "Adjust Delay and Combo", "back").
	// `selectID` = A number form of what was selected (example: 0 = "Note Colors", 1 = "Controls", etc.).
	
	// (NOTE: When pressing ESCAPE to go to the main menu, it returns {`label` = "back", `selectID` = -1})
	// return Function_Stop if you want to stop the game from selecting an option category.
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