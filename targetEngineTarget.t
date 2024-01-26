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
	cb = nil

	targetEngine = nil

	construct(t?, fn?) {
		if(t) target = t;
		if(dataTypeXlat(fn) != TypeNil)
			setMethod(&cb, fn);
	}

	callback([args]) {
		if(propType(&cb) == TypeNil) return;
		(cb)(args...);
	}
;
