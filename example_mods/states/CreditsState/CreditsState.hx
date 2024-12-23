/**
 * A menu script that runs on the Credits menu.
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

function onCreditsOpen(credit:Array<String>) {
	// Triggered when you select a credit icon.
	// `credit` = An array of the selected credit (0 = Name, 1 = Icon name, 2 = Description, 3 = Link, 4 = BG Color).
	
	// return Function_Stop if you want to stop the game from select a credit icon/going to the credit's website.
	return Function_Continue;
}

function onChangeItemPre(change:Int) {
	// Triggered when you move on the menu.
	// `change` = A number form of how much you moved, usually moves by 1 (down) or -1 (up).
	
	// return Function_Stop if you want to stop the game from changing credits.
	return Function_Continue;
}

function onChangeItem(change:Int) {
	// Triggered at the end of the `changeItem` event.
	// `change` = A number form of how much you moved, usually moves by 1 (down) or -1 (up).
}