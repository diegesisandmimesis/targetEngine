#charset "us-ascii"
//
// targetEngineInterrogate.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Interrogate: TargetEngineAgendaItem
	syslogID = 'Interrogate'

	// TargetEngine agendas are in the range 101-199.
	agendaOrder = 110

	isReady = ((configReady() == true) && (atTarget() == true))

	takeAction() {
		local t;

		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		if(execCommandAs(getActor(), 'talk to <<t.target.name>>')) {
			targetSuccess(t);
		} else {
			targetFailure(t);
		}
		checkProgress();
	}
;
