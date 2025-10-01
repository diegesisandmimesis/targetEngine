#charset "us-ascii"
//
// targetEngineUnlock.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Unlock: TargetEngineAgendaItem
	syslogID = 'Unlock'

	agendaOrder = 140

	isReady = ((configReady() == true) && (atTarget() == true))

	// Lookup table, keys are keys, values are vectors of the objects
	// we've tried that key on
	keysTried = nil

	// Returns boolean true if the key (first arg) has been tried on
	// the container (second arg).
	isKeyUntried(key, obj) {
		// If we have no tried keys we haven't tried this key.
		if(keysTried == nil)
			return(true);

		// If we have no record of trying this key at all, we haven't
		// tried it on this container.
		if(keysTried[key] == nil)
			return(true);

		// The main check.
		return(keysTried[key].indexOf(obj) == nil);
	}

	// Rmemeber that we tried the key (first arg) on the container
	// (second arg).
	addTriedKey(key, obj) {
		if(keysTried == nil)
			keysTried = new LookupTable();
		if(keysTried[key] == nil)
			keysTried[key] = new Vector();
		keysTried[key].appendUnique(obj);
	}

	// Returns all the plausible keys for the given container that
	// we're currently carrying.
	getPlausibleKeysFor(obj) {
		local i, l, r;

		l = getActor().contents.subset({ x: x.ofKind(Key) });
		if(l.length < 1)
			return([]);

		r = new Vector(l.length);
		for(i = 1; i <= l.length; i++) {
			if(l[i].ofKind(Key) && obj.keyIsPlausible(l[i]))
				r.append(l[i]);
		}

		return(r.toList());
	}

	// Given a container, return a plausible key in our possession that
	// we haven't already tried on that container, or nil if we
	// don't have one.
	getUntriedKeyFor(obj) {
		local i, l;

		// Get a list of all the plausible keys for the container
		// that we currently have.
		l = getPlausibleKeysFor(obj);
		if(l.length < 1)
			return(nil);

		// Return the first one we haven't already tried.
		for(i = 1; i <= l.length; i++) {
			if(isKeyUntried(l[i], obj))
				return(l[i]);
		}

		// Nope, failed.
		return(nil);
	}

	// See if the object is a valid target.
	// The inherited() logic just checks to see if the object is on
	// our target list, then we make sure we can touch the object and
	// we have at least one plausibe, untried key for it.
	matchTarget(a, obj) {
		if(inherited(a, obj) != true) return(nil);
		if(!a.canTouch(obj.target)) return(nil);
		return(getUntriedKeyFor(obj.target) != nil);
	}

	takeAction() {
		local a, k, t;

		// Should never fail.
		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		a = getActor();

		// Pick a plausible, untried key.  Should never fail (because
		// if we have none matchTarget() should have failed, preventing
		// us from being invoked this turn).
		if((k = getUntriedKeyFor(t.target)) == nil)
			return;

		// Remember that we tried this key, whether or not it
		// succeeds.
		addTriedKey(k, t.target);

		// Try to unlock the container with this key.
		if(forceExecCommandAs(a,
			'unlock <<t.target.name>> with <<k.name>>')) {
			// Add the container to the Open agenda's target list
			a.open(t.target);

			// Clear the target from the Open agenda's failed
			// target list.
			a.getAgendaMatching(Open).clearFailed(t.target);

			// Mark ourselves as a success.
			targetSuccess(t);
		} else {
			// Mark the target as failed in the Open agenda's
			// list.  This is probably redundant;  we will normally
			// only be called if the Open agenda itself tried and
			// failed.
			a.getAgendaMatching(Open).addFailed(t.target);
			return;
		}
	}
;
