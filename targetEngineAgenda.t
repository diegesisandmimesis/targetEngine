#charset "us-ascii"
//
// targetEngineAgenda.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class TargetEngineAgendaItem: AgendaItem, TargetEngineObject
	// TargetEngine agendas are all in the range 101-199, with the intention
	// that they'll always "defer" to non-TargetEngine agendas.
	agendaOrder = 101
	initiallyActive = true

	// A list of objectives.  Elements are instances of TargetEngineTarget.
	targetList = nil

	// Standard adv3 agenda method.  Here we check to see if we have
	// a complete config.
	isReady = (configReady() == true)

	// Add a target to the list.
	addTarget(v) { return(setTarget(v)); }
	setTarget(v) {
		if((v == nil) || !v.ofKind(TargetEngineTarget))
			return(nil);

		if(targetList == nil)
			targetList = new Vector();

		targetList.append(v);

		return(true);
	}

	// Get a target by index.  If the arg is nil, returns the last
	// target.
	getTarget(idx?) {
		if((targetList == nil) || (targetList.length < 1))
			return(nil);

		if((idx == nil) || (idx > targetList.length))
			idx = targetList.length;

		if(idx < 0)
			idx = 0;

		return(targetList[idx]);
	}

	// Checks on the number of targets in the list.
	targetCount = (targetList ? targetList.length : 0)
	noTargets = (targetCount() == 0)

	// Returns true if the actor is at the target.
	atTarget = (getTargetAtLocation() != nil)
	getTargetAtLocation() {
		local a;

		if(((a = getActor()) == nil) || (targetCount() == 0))
			return(nil);

		return(targetList.valWhich(function(o) {
			return(o.target && (o.target.location == a.location));
		}));
	}
	getTargetsAtLocation() {
		local a, r;

		if(((a = getActor()) == nil) || (targetCount() == 0))
			return(nil);

		r = new Vector();
		targetList.forEach(function(o) {
			if(o.target && (o.target.location == a.location))
				r.append(o);
		});

		return(r);
	}

	// A complete config consists of something to seek and an actor
	// to do the seeking.
	configReady = ((getActor() != nil) && (targetCount() > 0))

	// Clear the config.  We don't clear the actor because it's the
	// one that owns the agenda.
	clearConfig() { targetList.setLength(0); }
	clearTarget(v, cb?) {
		targetList.removeElement(v);
		if(cb != true)
			return;
		v.callback();
	}
	removeTarget(v, cb?) { clearTarget(v, cb); }

	// Generic success method.
	success() {
		clearConfig();
	}

	// Generic failure method.
	failure() {
		clearConfig();
	}
;
