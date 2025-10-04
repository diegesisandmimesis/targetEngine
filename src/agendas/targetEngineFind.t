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


modify Actor
	// Find pseudo-agenda.  Follows the same general semantics as the
	// other agendas but is just a frontend for several.
	find(t, cb?) {
		if(!isThing(t) || (targetEngine == nil))
			return(nil);

		// Add the object to the obtain target list.  If and when
		// it obtains the target it'll call our _clearFind() method.
		obtain(t, bind(&_clearFind, self, t, cb));

		// Additional agendas to actually send the actor out to
		// find the target.
		retrieve(t);
		explore(t);
		search(t);

		return(true);
	}

	// Entry point for manually cancelling the find agenda.  This
	// removes the target from the obtain agenda's target list.
	// This can't be part of _clearFind() because we use that as the
	// callback when we call the obtain agenda, so calling clearObtain()
	// in it would cause recursion.
	clearFind(t) {
		if(isThing(t)) {
			clearObtain(t);
			clearRetrieve(t);
		}
		_clearFind(t);
	}

	// Callback for our use of the obtain agenda.  This is called when
	// the obtain agenda succeeds in obtaining the target or decides
	// to permanently fail.  In either case we want to clear out the
	// other agendas we started for this target.
	_clearFind(t, cb?, args?) {
		if(isFunction(cb)) {
			(cb)(t, args...);
		}
		clearExplore(t);
		clearSearch(t);
	}
;
