/**
 * A menu script that runs on the Title screen.
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

function onStartIntro() {
	// Triggered when the intro has started.
}

function onStartIntroPost() {
	// Triggered at the end of "intro started".
}

function onSkipIntro(skippedIntro:Bool) {
	// Triggered when the intro was skipped, whether it was skipped manually or the game reached the end of the credits sequence.
	
	// `skippedIntro` = If you have skipped the intro before.
	// return Function_Stop if you want to stop the game from selecting (Good for creating custom events when the intro is skipped).
	return Function_Continue;
}

function onSkipIntroPost() {
	// Triggered at the end of "intro skipped".
}

function onBeatHit() {
	// Triggered when a beat is hit. Determined by the bpm parameter in `gfDanceTitle.json`.
	
	//(NOTE: use `curBeat` to check how many beats have passed since the first beat).
}

function onSelectedItem(isOutdated:Bool) {
	// Triggered when you press enter.
	
	// `isOutdated` = If your version of T-Bar Engine is lower than the current version.
	
	// return Function_Stop if you want to stop the game from selecting (Good for creating custom events when you press enter).
	return Function_Continue;
}