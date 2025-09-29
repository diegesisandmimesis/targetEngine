#charset "us-ascii"
//
// targetEngineOpen.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Open: TargetEngineAgendaItem
	syslogID = 'Unlock'

	agendaOrder = 132

	isReady = ((configReady() == true) && (atTarget() == true))

	failedList = nil

	// See if the given object is something we want to try opening.
	// The inherited() logic just check to see if it's on our target
	// list, and we add a check to see if it's something we've previously
	// tried and failed to open.
	matchTarget(actor, obj) {
		if(!inherited(actor, obj)) return(nil);
		if(onFailedList(obj.target)) return(nil);
		return(true);
	}

	takeAction() {
		local a, t;

		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		a = getActor();
		if(a.canTouch(t.target)) {
			if(forceExecCommandAs(a, 'open <<t.target.name>>')) {
				targetSuccess(t);
			} else {
				// Mark the target as failed.  This is so
				// we remember to not try to open it again
				// unless something else happens;  this is
				// needed because the Search agenda will
				// keep noticing that there's an unopened
				// container for us to search.
				addFailed(t.target);

				// See if the reason we failed is the target
				// is locked.
				if(t.target.isLocked()) {
					// Add the target to the Unlock agenda.
					a.unlock(t.target);

					// Add plausible keys for this
					// container to the obtainCustom
					// agenda's target list.
					a.obtainCustom(bind(&matchKey, self,
						t.target));

					// Make this target as a failure.
					targetFailure(t);
				}
			}
		}
		checkProgress();
	}

	// Filter method for the obtainCustom agenda to help find keys to
	// containers we haven't been able to open.
	matchKey(cont, obj) {
		// Object has to be a key.
		if(!obj.ofKind(Key))
			return(nil);

		// We don't care about keys we're already carrying.
		if(obj.getCarryingActor() == getActor())
			return(nil);

		// We only want keys that are plausible for the container
		// we're trying to open.
		if(cont.keyIsPlausible(obj))
			return(true);
		
		return(nil);
	}

	// Add a container to our failed list.
	// This is to keep track of containers we've tried and been unable to
	// open.  Something will have to externally remove things from this
	// list for us to try the container again.
	addFailed(obj) {
		if(failedList == nil)
			failedList = new Vector();
		failedList.appendUnique(obj);
		return(true);
	}

	// Remove a container from our failed list.  This is probably going
	// to be called by the Unlock agenda if and when it successfully
	// unlocks a container we've previously failed to open.  That's what
	// will prompt us to try again if we have the chance.
	clearFailed(obj, data?) {
		if(failedList == nil)
			return(nil);
		failedList = failedList.subset({ x: x != obj });
		return(true);
	}

	// Returns boolean true if the argument object is on our failed
	// list.
	onFailedList(obj) {
		if(failedList == nil)
			return(nil);
		return(failedList.valWhich({ x: x == obj }) != nil);
	}
;
