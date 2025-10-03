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

	near = nil
	distance = nil

	// A callback function to invoke when the target is "done".
	cb = nil

	targetEngine = nil

	construct(t?, fn?) {
		if(t) target = t;

		// If we were passed a callback, set it as a method on
		// ourselves.
		if(dataTypeXlat(fn) != TypeNil)
			setMethod(&cb, fn);
	}

	// If we have a callback, call it.
	callback([args]) {
		if(propType(&cb) == TypeNil) return;
		(cb)(args...);
	}
;
