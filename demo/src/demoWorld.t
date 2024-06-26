#charset "us-ascii"
//
// demoWorld.t
//
//	Rudimentary gameworld used by the three-room demos.
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

pebbleRoom: Room 'Pebble Room'
	"This is the starting room for the pebble. "
	north = middleRoom
;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
+rock: Thing '(ordinary) rock' 'rock' "An ordinary rock. ";

middleRoom: Room 'Middle Room'
	"This is the middle room used in the three-room demos. "
	north = aliceRoom
	south = pebbleRoom
;

aliceRoom: Room 'Alice\'s Room'
	"This is Alice's starting room. "
;
