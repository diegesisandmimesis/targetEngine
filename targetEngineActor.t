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

	// Convenience methods to add specific kinds of targets.
	moveTo(v, cb?) {
		return(targetEngine ? targetEngine.moveTo(v, cb) : nil);
	}
	observe(v, cb?) {
		return(targetEngine ? targetEngine.observe(v, cb) : nil);
	}
	obtain(v, cb?) {
		return(targetEngine ? targetEngine.obtain(v, cb) : nil);
	}
;
