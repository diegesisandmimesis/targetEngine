#charset "us-ascii"
//
// huntNearTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the targetEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f huntNearTest.t3m
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
		"This is a non-interactive demo of the find() logic.<.p>
		Alice and a pebble will be randomly placed in a random
		<<toString(map.mapWidth)>>x<<toString(map.mapWidth)>> maze
		and then Alice will attempt to find the pebble.<.p> ";
	}
;

map: SimpleRandomMapGenerator mapWidth = 10;
me: Person;
pebble: Thing '(small) (round) pebble' 'pebble' "A small, round pebble. ";

modify alice;
+pebbleMemory: Memory ->pebble seen = true;

AutoTest
	autoTestMaxTurns = 1000
	//autoTestMaxTurns = 1

	autoTestSilent = true
	autoTestStartGame() {
		local l, rm;

		alice.moveInto(map.getRandomRoom());

		// Move the pebble into a random room.
		rm = map.getRandomRoom();
		pebble.moveInto(rm);

		// Pick a random room within 2 spaces of the pebble's
		// new location.
		l = rm.getDijkstraNeighborhood(2, alice);
		rm = l[rand(l.length) + 1];

		// Give alice the memory of having seen the pebble in
		// the random near-the-pebble location.
		pebbleMemory.room = rm;

		alice.obtain(pebble, bind(&success, self));
		alice.retrieve(pebble);
		"\nPlaced <<alice.name>> in <q><<alice.location.roomName>></q>\n ";
	}
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
