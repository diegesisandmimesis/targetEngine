#charset "us-ascii"
//
// targetEngineObtain.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Obtain: TargetEngineAgendaItem
	syslogID = 'Obtain'

	// TargetEngine agendas are in the range 101-199.  Obtain has a
	// priority lower than observation but higher than movement.
	agendaOrder = 125

	isReady = ((configReady() == true) && (atTarget() == true))

	invokeItem() {
		takeTarget();
	}

	takeTarget() {
		local a, t;

		a = getActor();
		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		if(a.canTouch(t.target)) {
			if(execCommandAs(a, 'take <<t.target.name>>')) {
				clearTarget(t, true);
				if(targetCount() == 0)
					success();
			} else {
				clearTarget(t, nil);
			}
		}
	}
;
