#charset "us-ascii"
//
// agendaTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the targetEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f agendaTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

versionInfo: GameID
        name = 'targetEngine Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the targetEngine library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the targetEngine library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;

gameMain: GameMainDef
	initialPlayerChar = me

	inlineCommand(cmd) { "<b>&gt;<<toString(cmd).toUpper()>></b>"; }
	printCommand(cmd) { "<.p>\n\t<<inlineCommand(cmd)>><.p> "; }

	showIntro() {
		"This demo provides a <<inlineCommand('foozle')>>
		command that triggers a few agendas.  A couple turns after
		using it, Alice should arrive in the starting room and
		examine and then take the pebble. ";
		"<.p> ";
	}
;

startRoom: Room 'Void'
	"This is a featureless void. "
	north = middleRoom
;
+me: Person;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";

middleRoom: Room 'Middle Room'
	"This is the middle room. "
	north = northRoom
	south = startRoom
;

northRoom: Room 'North Room'
	"This is the north room. "
	south = middleRoom
;
+alice: Person 'Alice' 'Alice'
	"She looks like the first person you'd turn to in a problem. "
	isHer = true
	isProperName = true

	// This tells the module to add a TargetEngine to alice.
	useTargetEngine = true

	moveCallback(success) {
		"\^<<name>> arrives and says nothing.\n ";
	}
;

DefineSystemAction(Foozle)
	execSystemAction() {
		// Now Alice wants to move to the startRoom.
		alice.moveTo(startRoom, bind(&moveCallback, alice));

		// Now alice wants to obtain the pebble.
		alice.obtain(pebble);

		// Now alice wants to examine the pebble.
		alice.observe(pebble);

		defaultReport('Agendas started. ');
	}
;
VerbRule(Foozle) 'foozle': FoozleAction VerbPhrase = 'foozle/foozling';

