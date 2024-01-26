#charset "us-ascii"
//
// targetEngineActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

modify Actor
	useTargetEngine = nil

	targetEngine = nil

	targetEngineClass = TargetEngine

	setTargetEngine(obj) {
		if(useTargetEngine != true)
			return(nil);

		if((obj == nil) || !obj.ofKind(targetEngineClass))
			return(nil);

		targetEngine = obj;
		obj.actor = self;

		return(true);
	}

	initializeTargetEngineActor() {
		_initializeTargetEngine();
		_initializeTargetEngineAgendas();
	}

	_initializeTargetEngine() {
		if((targetEngine != nil) || (useTargetEngine != true))
			return;

		setTargetEngine(targetEngineClass.createInstance());
	}

	_initializeTargetEngineAgendas() {
		if((targetEngine == nil) || (useTargetEngine != true))
			return;

		targetEngine.initializeTargetEngineAgendas();
	}

	// Convenience wrapper methods for seek engine stuff.
	moveTo(v, cb?) { return(targetEngine ? targetEngine.moveTo(v, cb?) : nil); }
	observe(v, cb?) {
		return(targetEngine ? targetEngine.observe(v, cb?) : nil);
	}
	obtain(v, cb?) { return(targetEngine ? targetEngine.obtain(v, cb?) : nil); }
/*
	executeAgenda() {
		inherited();
		aioSay('\nexecuteAgenda\n ');
	}
*/
;
