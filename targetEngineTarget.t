#charset "us-ascii"
//
// targetEngineTarget.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class TargetEngineTarget: TargetEngineObject
	syslogID = 'TargetEngineTarget'

	// The Thing instance we're after.  Could be an object, actor, room,
	// whatever.
	target = nil

	// A callback function to invoke when the target is "done".
	callback = nil

	targetEngine = nil

	construct(t?, cb?) {
		if(t) target = t;
		if(cb) callback = cb;
	}
;
