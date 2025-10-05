#charset "us-ascii"
//
// targetEngineRevisitLocked.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

// Data structure for holding information about a revisit target.
class RevisitLockedTarget: object
	obj = nil
	room = nil
	construct(v0?, v1?) {
		if(isThing(v0)) obj = v0;
		if(isRoom(v1)) room = v1;
	}
;

class RevisitLocked: TargetEngineAgendaItem
	syslogID = 'RevisitLocked'

	agendaOrder = 195

	// Updated every turn, a list of containers we want to re-check.
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

	// Returns the list of containers that the Open agenda failed to
	// open, that we are carrying a plausible key for that we haven't
	// tried yet.
	getCheckableContainers() {
		local a, agO, agU, l0, l1;

		// If we have a cached list, return it.
		if(checkableContainers != nil)
			return(checkableContainers);

		// We need a memory engine on our actor.
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
			l1.append(new RevisitLockedTarget(x, m.room));
		});

		// Cache the results.
		checkableContainers = l1.toList();

		// ...and return them.
		return(checkableContainers);
	}

	takeAction() {
		local l;

		// Should never fail.
		l = getCheckableContainers();
		if(!isCollection(l) || (l.length < 1))
			return;

		// Grab the first container on the list, move to it.
		getActor().moveTo(l[1].room);
	}
;
