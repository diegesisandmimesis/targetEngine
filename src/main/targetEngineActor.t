#charset "us-ascii"
//
// targetEngineActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

modify Actor
	// Set to boolean true to have the actor use a target engine
	useTargetEngine = nil

	// Property to hold our TargetEngine instance.
	targetEngine = nil

	// Class of target engine to create if one isn't declared in source.
	targetEngineClass = TargetEngine

	// Assigns the given target engine to this actor.
	setTargetEngine(obj) {
		// Make sure we want a target engine.
		if(useTargetEngine != true)
			return(nil);

		// Make sure the arg is a valid target engine.
		if((obj == nil) || !obj.ofKind(targetEngineClass))
			return(nil);

		// Do the assignment.
		targetEngine = obj;
		obj.actor = self;

		return(true);
	}

	// Called at preinit.
	initializeTargetEngineActor() {
		_initializeTargetEngine();
		_initializeTargetEngineAgendas();
	}

	// If we've been configured to use a target engine and one wasn't
	// declared for us, create one now.
	_initializeTargetEngine() {
		if((targetEngine != nil) || (useTargetEngine != true))
			return;

		setTargetEngine(targetEngineClass.createInstance());
	}

	// Tell our target engine to create the agendas it needs to
	// function if they don't already exist.
	_initializeTargetEngineAgendas() {
		if((targetEngine == nil) || (useTargetEngine != true))
			return;

		targetEngine.initializeTargetEngineAgendas();
	}

	getAgendaMatching(cls) {
		return(targetEngine ? targetEngine._getAgendaMatching(cls)
			: nil);
	}

	invokeAgendaMatching(cls) {
		local a;

		if(targetEngine == nil)
			return(nil);
		if((a = targetEngine._getAgendaMatching(cls)) == nil)
			return(nil);
		a.invokeItem();
		return(true);
	}

	// Find pseudo-agenda.  Follows the same general semantics as the
	// other agendas but is just a frontend for several.
	find(t, cb?) {
		if(!isThing(t))
			return(nil);

		// Add the object to the obtain target list.  If and when
		// it obtains the target it'll call our _clearFind() method.
		obtain(t, bind(&_clearFind, self, t, cb));

		// Additional agendas to actually send the actor out to
		// find the target.
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
		if(isThing(t))
			clearObtain(t);
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
