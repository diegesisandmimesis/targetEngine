#charset "us-ascii"
//
// targetEngineInterrogate.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

#ifndef THIRD_PERSON_ACTION_TALK_TO
#error "The Interrogate agenda (in the targetEngine module) requires the"
#error "game to be compiled with the -D THIRD_PERSON_ACTION_TALK_TO flag."
#endif // THIRD_PERSON_ACTION_TALK_TO

class Interrogate: TargetEngineAgendaItem
	syslogID = 'Interrogate'

	// TargetEngine agendas are in the range 101-199.
	agendaOrder = 120

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
