#charset "us-ascii"
//
// targetEngineFind.t
//
//	Agenda for finding an object in an unknown location.
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Find: TargetEngineAgendaItem
	syslogID = 'Find'

	agendaOrder = 175

	taskIndex = 0

	/*
	setTarget(t) {
		local a;

		if(!inherited(t))
			return(nil);

		a = getActor();
		if(isThing(t.target))
			a.obtain(t.target, bind(&done, self));
		a.explore(t.target);
		a.search(t.target);
		aioSay('\n===start===\n ');

		return(true);
	}

	done(t) {
		local a;

		aioSay('\n===DONE===\n ');

		if(!isTargetEngineTarget(t))
			return(nil);
		a = getActor();
		a.clearExplore(t.target);
		a.clearSearch(t.target);

		return(true);
	}
	*/
;
