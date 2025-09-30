#charset "us-ascii"
//
// searchTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the targetEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f searchTest.t3m
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
		command that triggers Alice's searchTest agenda.
		<.p> ";
	}
;

modify pebbleRoom north = middleRoom;
modify aliceRoom south = middleRoom;
+me: Person 'player' 'player';
+searchableBox: OpenableContainer '(searchable) box' 'searchable box'
	"It's a searchable box. ";
;
+lockedBox: KeyedContainer '(lockable) box' 'lockable box'
	"It's a lockable box. "
	keyList = static [ key01 ]
;
+key02: Key '(fake) key' 'fake key'
	"A fake key. "
;
key01: Key '(ordinary) key' 'ordinary key'
	"An ordinary key. "
;

modify FoozleAction
	execSystemAction() {
		local a;

		if((a = alice.targetEngine._getAgendaMatching(Search)) == nil) {
			reportFailure('No search agenda found. ');
			exit;
		}
		if(a.targetCount() == 0) {
			alice.search(true);
			defaultReport('Alice is now searching. ');
		} else {
			alice.clearSearch(true);
			defaultReport('Alice is no longer searching. ');
		}
	}
;

modify InfoAction
	execSystemAction() {
		info(alice);
	}
;

DefineSystemAction(Magic)
	execSystemAction() {
		key01.moveInto(gActor.location);
		defaultReport('\^<<key01.theName>> appears. ');
	}
;
VerbRule(Magic) 'magic': MagicAction verbPhrase = 'magic/magicing';

