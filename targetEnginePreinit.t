#charset "us-ascii"
//
// targetEnginePreinit.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

targetEnginePreinit: PreinitObject
	execute() {
		initTargetEngines();
		initTargetEngineActors();
	}

	initTargetEngines() {
		forEachInstance(TargetEngine, function(o) {
			o.initializeTargetEngine();
		});
	}

	initTargetEngineActors() {
		forEachInstance(Actor, function(o) {
			o.initializeTargetEngineActor();
		});
	}
;
