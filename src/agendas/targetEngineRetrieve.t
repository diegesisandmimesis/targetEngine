#charset "us-ascii"
//
// targetEngineRetrieve.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

modify TargetEngine
	retrieveTarget = nil

	addRetrieveTarget(t, rm) {
		if(retrieveTarget == nil)
			retrieveTarget = new LookupTable();
		retrieveTarget[t] = rm;
		return(true);
	}

	getRetrieveTarget(t)
		{ return(retrieveTarget ? retrieveTarget[t] : nil); }

	clearRetrieveTarget(t) {
		if(retrieveTarget == nil)
			return(nil);
		retrieveTarget[t] == nil;
		return(true);
	}
;

modify Actor
	retrieve(t, cb?) {
		local m;

		if(!isThing(t) || (targetEngine == nil))
			return(nil);

		// See if we remember seeing the target.  If we don't,
		// then we have nothing to do here.
		if((m = getMemory(t)) == nil)
			return(nil);

		// If we remember the object but not where we saw it that's
		// useless, bail.
		if(m.room == nil)
			return(nil);

		// We have a location, try moving there.
		moveTo(m.room);

		// Remember the target-to-room mapping.  We do this because
		// we use the target as the key for the retrive agenda and
		// the room as the key for the huntNear agenda, and the
		// room remembered for the target might get updated between
		// when we start and when we're cleared.
		targetEngine.addRetrieveTarget(t, m.room);
		huntNear(m.room);

		return(true);
	}

	clearRetrieve(t) {
		if(targetEngine)
			clearHuntNear(targetEngine.getRetrieveTarget(t));
	}
;
