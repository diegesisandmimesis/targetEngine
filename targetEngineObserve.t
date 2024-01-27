#charset "us-ascii"
//
// targetEngineObserve.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Observe: TargetEngineAgendaItem
	syslogID = 'Observe'

	// TargetEngine agendas are in the range 101-199.  Observation happens
	// very early, pre-empting movement and so on.
	agendaOrder = 105

	isReady = ((configReady() == true) && (atTarget() == true))

	takeAction() {
		local t;

		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		if(execCommandAs(getActor(), 'x <<t.target.name>>')) {
			targetSuccess(t);
		} else {
			targetFailure(t);
		}
		checkProgress();
	}
;
