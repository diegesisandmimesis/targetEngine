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
	/*
	//explore(v?, cb?)
		//{ return(targetEngine ? targetEngine.explore(v, cb) : nil); }
	find(v?, cb?)
		{ return(targetEngine ? targetEngine.find(v, cb) : nil); }
	interrogate(v?, cb?) {
		return(targetEngine ? targetEngine.interrogate(v, cb) : nil);
	}
	moveTo(v, cb?)
		{ return(targetEngine ? targetEngine.moveTo(v, cb) : nil); }
	observe(v, cb?)
		{ return(targetEngine ? targetEngine.observe(v, cb) : nil); }
	obtain(v, cb?)
		{ return(targetEngine ? targetEngine.obtain(v, cb) : nil); }
	obtainCustom(v, cb?) {
		return(targetEngine ? targetEngine.obtainCustom(v, cb) : nil);
	}
	randomWalk(v?, cb?)
		{ return(targetEngine ? targetEngine.randomWalk(v, cb) : nil); }
	search(v?, cb?)
		{ return(targetEngine ? targetEngine.search(v, cb) : nil); }
	
	open(v?, cb?)
		{ return(targetEngine ? targetEngine.open(v, cb) : nil); }
	unlock(v?, cb?)
		{ return(targetEngine ? targetEngine.unlock(v, cb) : nil); }

	//clearExplore(v) {
		//return(targetEngine ? targetEngine.clearExplore(v) : nil); }
	clearFind(v) {
		return(targetEngine ? targetEngine.clearFind(v) : nil); }
	clearInterrogate(v) {
		return(targetEngine ? targetEngine.clearInterrogate(v) : nil);
	}
	clearMoveTo(v) {
		return(targetEngine ? targetEngine.clearMoveTo(v) : nil);
	}
	clearObserve(v) {
		return(targetEngine ? targetEngine.clearObserve(v) : nil);
	}
	clearObtain(v) {
		return(targetEngine ? targetEngine.clearObtain(v) : nil);
	}
	clearObtainCustom(v) {
		return(targetEngine ? targetEngine.clearObtainCustom(v) : nil);
	}
	clearRandomWalk(v) {
		return(targetEngine ? targetEngine.clearRandomWalk(v) : nil); }
	clearSearch(v) {
		return(targetEngine ? targetEngine.clearSearch(v) : nil); }

	clearOpen(v)
		{ return(targetEngine ? targetEngine.clearOpen(v) : nil); }
	clearUnlock(v)
		{ return(targetEngine ? targetEngine.clearUnlock(v) : nil); }
		*/
	
	/*
	actorTargetMethods(explore, Explore)
	actorTargetMethods(find, Find)
	actorTargetMethods(interrogate, Interrogate)
	actorTargetMethods(moveTo, MoveTo)
	actorTargetMethods(observe, Observe)
	actorTargetMethods(obtain, Obtain)
	actorTargetMethods(obtainCustom, ObtainCustom)
	actorTargetMethods(randomWalk, RandomWalk)
	actorTargetMethods(search, Search)
	actorTargetMethods(open, Open)
	actorTargetMethods(unlock, Unlock)
	*/

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
;
