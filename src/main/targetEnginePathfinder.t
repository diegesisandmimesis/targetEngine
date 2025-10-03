#charset "us-ascii"
//
// targetEnginePathfinder.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

targetEnginePathfinder: roomPathFinder
	includeRoom(loc) { return(true); }
/*
	includeRoom(loc) {
		return(actor_.knowsAbout(loc));
	}
*/
;
