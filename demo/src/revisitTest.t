#charset "us-ascii"
//
// revisitTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the targetEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f revisitTest.t3m
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

#include "autoTest.h"
#ifndef AUTO_TEST_H
#error "This demo requires the autoTest module."
#endif // AUTO_TEST_H

versionInfo: GameID;

gameMain: GameMainDef
	initialPlayerChar = me

	showIntro() {
	}
;

modify aliceRoom south = middleRoom;
+box: KeyedContainer '(lockable) box' 'lockable box'
	"It's a lockable box. "
	keyList = static [ key01 ]
;
++pebble: Thing '(small) (round) pebble' 'pebble' "A small, round pebble. ";
+me: Person;

modify pebbleRoom;
+key01: Key '(ordinary) key' 'ordinary key' "An ordinary key. ";


AutoTest
	autoTestMaxTurns = 100
	autoTestSilent = true
	autoTestStartGame() {
		alice.moveInto(aliceRoom);
		alice.search('foo');
		alice.revisitLocked('foo');
		alice.moveTo(pebbleRoom);
		alice.obtain(pebble, bind(&success, self));

		"\nPlaced <<alice.name>> in <q><<alice.location.roomName>></q>
			and <<pebble.theName>> in
			<q><<pebble.location.roomName>></q>.\n ";
	}

	// Called when alice obtains the pebble.
	success(t?, v?) {
		autoTestEnd();
	}

	autoTestEnd() {
		if(pebble.getCarryingActor() == alice)
			aioSay('\n===SUCCESS===\n ');
		else
			aioSay('\n===FAILURE===\n ');
		aioSay('\nExiting on turn <<toString(libGlobal.totalTurns)>>\n ');
		inherited();
	}
;

/*
modify FoozleAction
	execSystemAction() {
		alice.search('foo');
		alice.revisitLocked('foo');
		alice.obtain(pebble);
		alice.moveTo(pebbleRoom);
		defaultReport('Starting. ');
	}
;
*/
