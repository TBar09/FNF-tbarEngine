/**
 * A menu script that runs on the Story Menu.
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

function onOpenSubstate(substate:String) {
	// Triggered when a substate is opened (like gameplay changers).
	
	// `substate` = The substate that was opened (example: "GameplayChangers", "ResetScore").
	// return Function_Stop if you want to stop the game from opening a substate (Good for creating custom substates).
	return Function_Continue;
}

function onExit() {
	// Triggered when the menu is being left (by pressing `back`).
	
	// return Function_Stop if you want to stop the game from going back.
	return Function_Continue;
}

function onSelectWeek(week) {
	// Triggered when a week is selected.
	
	// `week` = The week data that was selected (example: week.fileName, week.songs).
	// return Function_Stop if you want to stop the game from starting a week (Good for creating custom events when a week is selected).
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

function onChangeWeekPre(change:Int) {
	// Triggered when the week is changed.
	
	// `change` = A number form of how much you moved, usually moves by 1 (up) or -1 (down).
	// return Function_Stop if you want to stop the game from changing weeks.
	return Function_Continue;
}

function onChangeWeek(change:Int) {
	// Triggered at the end of "week change".
	
	// `change` = A number form of how much you moved, usually moves by 1 (up) or -1 (down).
}
