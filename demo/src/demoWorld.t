#charset "us-ascii"
//
// demoWorld.t
//
//	Rudimentary gameworld used by the three-room demos.
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Pebble: Thing '(small) (round) pebble' 'pebble'
	"A small, round pebble. "
	isEquivalent = true
;

class Rock: Thing '(ordinary) rock' 'rock'
	"An ordinary rock. "
	isEquivalent = true
;

pebbleRoom: Room 'Pebble Room'
	"This is the starting room for the pebble. "
	north = middleRoom
;

middleRoom: Room 'Middle Room'
	"This is the middle room used in the three-room demos. "
	north = aliceRoom
	south = pebbleRoom
;

aliceRoom: Room 'Alice\'s Room'
	"This is Alice's starting room. "
;
