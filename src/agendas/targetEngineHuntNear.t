#charset "us-ascii"
//
// targetEngineHuntNear.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class HuntNear: TargetEngineAgendaItem
	syslogID = 'HuntNear'

	agendaOrder = 190

	maxDijkstraDistance = 3
	roomList = nil

	setTarget(v) {
		if(inherited(v) != true)
			return(nil);

		return(true);
	}
;
