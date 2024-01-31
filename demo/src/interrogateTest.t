#charset "us-ascii"
//
// interrogateTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the targetEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f interrogateTest.t3m
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
		command that triggers Alice's interrogate agenda.
		<.p>
		The world is a 10x10 random map with two extra rooms,
		one in the southwest for the player and one in the northeast
		for Alice.
		<.p>
		The makefile for this demo uses -D SYSLOG to output
		logging information, so the player can see Alice's
		movements.
		<.p> ";
	}
;

modify pebbleRoom north = middleRoom;
+me: Person;

modify aliceRoom south = middleRoom;

modify FoozleAction
	execSystemAction() {
		alice.moveTo(pebbleRoom);
		alice.interrogate(me);

		defaultReport('Agendas started. ');
	}
;
/*
startRoom: Room 'Pebble Room'
	"This is the starting room for the pebble. "
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
	"This is the starting room for Alice. "
	south = middleRoom
;
+alice: Person 'Alice' 'Alice'
	"She looks like the first person you'd turn to in a problem. "
	isHer = true
	isProperName = true

	// This tells the module to add a TargetEngine to alice.
	useTargetEngine = true
;
// A very low-priority agenda.
// It being executed just demonstrates that none of the higher-priority
// agendas are still active.  It should also fire the turn after the pebble
// is obtained if Alice's nextRunTime hasn't been messed with.
++AgendaItem
	agendaOrder = 999
	initiallyActive = true
	isReady = true
	invokeItem() {
		"Alice idles. ";
	}
;

DefineSystemAction(Foozle)
	execSystemAction() {
		alice.moveTo(startRoom);
		alice.interrogate(me);

		defaultReport('Agendas started. ');
	}
;
VerbRule(Foozle) 'foozle': FoozleAction VerbPhrase = 'foozle/foozling';
*/
