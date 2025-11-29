/*
 * A script that aims to "fix" the bug in T-Bar Engine hashlink builds where all of the "mustHitSection" stuff
 * are all played on the first section and end up keeping the camera on BF.
 * - This code is held together by a chewed up gum.
 */

#if hl
public var CURRENT_SECTION:Int = 0;
var _SECTION_ALLOWED:Bool = false;

function onSongStart() {
	_SECTION_ALLOWED = true;
	game.moveCameraSection(0);
}

function onSectionHit() {
	if(_SECTION_ALLOWED) {
		if(CURRENT_SECTION >= PlayState.SONG.notes.length) CURRENT_SECTION = 1;

		//game.moveCamera((game.SONG.notes[CURRENT_SECTION].mustHitSection == false)); //wdym "Access violation" :sob:
		game.moveCameraSection(CURRENT_SECTION);
		CURRENT_SECTION++;
	}
}
#end