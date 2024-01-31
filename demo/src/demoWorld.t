#charset "us-ascii"
//
// demoWorld.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

pebbleRoom: Room 'Pebble Room'
	"This is the starting room for the pebble. "
	north = middleRoom
;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";

middleRoom: Room 'Middle Room'
	"This is the middle room used in the three-room demos. "
	north = aliceRoom
	south = pebbleRoom
;

aliceRoom: Room 'Alice\'s Room'
	"This is Alice's starting room. "
;
