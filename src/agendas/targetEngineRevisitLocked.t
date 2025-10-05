#charset "us-ascii"
//
// targetEngineRevisitLocked.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class RevisitLocked: TargetEngineAgendaItem
	syslogID = 'RevisitLocked'

	agendaOrder = 195

	checkableContainers = nil

	configReady() {
		if(getActor() == nil) return(nil);
		if(targetCount() < 1) return(nil);

		// Reset the checkable containers list.
		checkableContainers = nil;

		// Re-compute the checkable containers list.
		if(getCheckableContainers().length < 1) return(nil);

		return(true);
	}

	getCheckableContainers() {
		local a, agO, agU, l0, l1;

		// If we have a cached list, return it.
		if(checkableContainers != nil)
			return(checkableContainers);

		a = getActor();
		if(a.memoryEngine == nil)
			return([]);

		// Make sure we have all the agendas we need.  Should never
		// fail.
		if((agO = a.getAgendaMatching(Open)) == nil)
			return([]);
		if((agU = a.getAgendaMatching(Unlock)) == nil)
			return([]);

		// Vector to hold a list of containers we have untried
		// keys for.
		l0 = new Vector();

		// For each container the open agenda tried and failed to
		// open...
		agO.getFailedList().forEach(function(x) {
			// ...see if we have an untried key for it.
			if(agU.getUntriedKeyFor(x) == nil)
				return;

		aioSay('\nadding <<toString(x)>>\n ');
			// ...and if so, at it to our list.
			l0.append(x);
		});

		// Another vector, this one for the containers on our
		// list that we remember a location for.
		l1 = new Vector(l0.length);

		// Go through the containers we have plausible keys for.
		l0.forEach(function(x) {
			local m;

			// No memory, skip.
			if((m = a.getMemory(x)) == nil)
				return;

			// Don't remember the location, skip.
			if(!isRoom(m.room))
				return;

			// Add the container and remembered location to list.
			l1.append([ x, m.room ]);
		});

		// Cache the results.
		checkableContainers = l1.toList();

		// ...and return them.
		return(checkableContainers);
	}

	takeAction() {
		local l;

		l = getCheckableContainers();
		if(!isCollection(l) || (l.length < 1))
			return;

		getActor().moveTo(l[1][2]);
	}
;
