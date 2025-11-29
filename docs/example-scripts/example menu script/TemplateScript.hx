// HScript stuff for menu scripting

function onCreate()
{
	// triggered when the hscript file is created. Some / most variables weren't fully initialized yet
}

function onCreatePost()
{
	// end of "create"
}

function onUpdate(elapsed:Float)
{
	// triggered on the start of "update", some variables weren't updated yet
}

function onUpdatePost(elapsed:Float)
{
	// triggered at the end of "update"
}

function onDraw()
{
	// triggered at the start of "draw"
	// return Function_Stop if you want to stop the state from redrawing
	return Function_Continue;
}

function onDrawPost()
{
	// triggered at the end of "draw"
}

function onSectionHit()
{
	// triggered after it goes to the next section (must have song)
}

function onBeatHit()
{
	// triggered 4 times per section
}

function onStepHit()
{
	// triggered 16 times per section
}

function onOpenSubState(subState:FlxSubState)
{
	// triggered when a substate is opened from the state (example: Pause menu)
	// return Function_Stop if you want to stop the state from opening a substate
	return Function_Continue;
}

function onCloseSubState()
{
	// triggered when a substate is closed.
	// return Function_Stop if you want to stop the state from closing it's substate
	return Function_Continue;
}

function onResize(width:Int, height:Int)
{
	// triggered when the window is resized while in a state.
	// `width` and `height` being the new dimensions of the window.
}

function onFocus()
{
	// triggered when the window is focused on while in a state.
}

function onFocusLost()
{
	// triggered when the window has lost focus while in a state.
}

function onDestroy()
{
	// triggered when the script is destroyed
}

