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
	agendaOrder = 130

	isReady = ((configReady() == true) && (atTarget() == true))

	takeAction() {
		takeTarget();
	}

	takeTarget() {
		local a, t;

		a = getActor();
		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		if(a.canTouch(t.target)) {
			if(execCommandAs(a, 'take <<t.target.disambigName>>'))
				targetSuccess(t);
			else
				targetFailure(t);
		}
		checkProgress();
	}
;
