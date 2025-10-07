#charset "us-ascii"
//
// findTest4.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the targetEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f findTest4.t3m
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

	// The number of random boxes and keys to create.
	containerCount = 10

	showIntro() {
		"This is a non-interactive demo of the find() logic.<.p>
		Alice and <<spellInt(containerCount)>> boxes and their
		keys will be will be randomly placed in a random
		<<toString(map.mapWidth)>>x<<toString(map.mapWidth)>> maze.
		The pebble is placed in one of the boxes and Alice
		tries to find it.<.p> ";
	}
;

map: SimpleRandomMapGenerator mapWidth = 10;
me: Person;
pebble: Thing '(small) (round) pebble' 'pebble' "A small, round pebble. ";

class DemoBox: KeyedContainer 'container box' 'box'
	"It's a keyed container. "

	construct(n) {
		vocabWords = 'box (<<spellInt(n)>>)';
		name = 'box <<spellInt(n)>>';
		initializeVocab();
	}
;
class DemoKey: Key '(ordinary) key' 'key' "An ordinary key. "
	construct(n) {
		vocabWords = 'key (<<spellInt(n)>>)';
		name = 'key <<spellInt(n)>>';
		initializeVocab();
	}
;

box: KeyedContainer '(lockable) box' 'lockable box'
	"A lockable box. "
	keyList = [ key01 ]
;
key01: Key '(ordinary) key' 'ordinary key' "An ordinary key. ";

AutoTest
	autoTestMaxTurns = 1000
	autoTestSilent = true


	_boxes = perInstance(new Vector)
	_keys = perInstance(new Vector)

	// Generate containerCount random boxes and keys and place them
	// randomly.
	generateContainers() {
		local i;

		for(i = 0; i < gameMain.containerCount; i++)
			generateContainer(i);

		// Also move the pebble into one of the boxes.
		// We always pick the last one because the boxes are randomly
		// placed so the number doesn't matter.
		pebble.moveInto(_boxes[_boxes.length]);
	}

	// Generate box #n, its key, and place them in random rooms.
	generateContainer(n) {
		local box, key;

		box = new DemoBox(n);
		key = new DemoKey(n);
		box.keyList = [ key ];
		box.moveInto(map.getRandomRoom());
		key.moveInto(map.getRandomRoom());
		box.makeLocked(true);

		_boxes.append(box);
		_keys.append(key);
	}

	autoTestStartGame() {
		// Generate random boxes and keys and scatter them around
		// the gameworld.  The pebble is placed in one of them.
		generateContainers();

		// Place alice in a random room.
		alice.moveInto(map.getRandomRoom());

		// Have alice explore.  'foo' is a random ID for this
		// exploration task, and the second arg is a callback for
		// when the explore agenda runs out of unvisited rooms.
		alice.find(pebble, bind(&success, self));
		alice.revisitLocked('foo');

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
