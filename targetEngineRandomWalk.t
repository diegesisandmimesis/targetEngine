#charset "us-ascii"
//
// targetEngineRandomWalk.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class RandomWalk: Move
	syslogID = 'RandomWalk'

	computeMove() {
		
		return(true);
	}

	tryMove() {
		return(true);
	}
;
