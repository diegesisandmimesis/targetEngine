#charset "us-ascii"
//
// findTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the targetEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f findTest.t3m
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
		command that triggers Alice's Explore agenda.
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

map: SimpleRandomMapGenerator mapWidth = 3;
me: Person;
pebble: Thing '(small) (round) pebble' 'pebble' "A small, round pebble. ";

modify FoozleAction
	execSystemAction() {
		pebble.moveInto(map.getRandomRoom());
		alice.moveInto(map.getRandomRoom());

		alice.find(pebble);
		//alice.explore(true);
		defaultReport('Placed <<alice.name>> in
			<q><<alice.location.roomName>></q>. ');
	}
;

modify InfoAction
	execSystemAction() {
		info(alice);
		info(pebble);
	}
;
