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

	agendaOrder = 130

	unlockList = nil
	unlockScopeList = nil

	// Lookup table, keys are keys, values are vectors of the objects
	// we've tried that key on
	keysTried = nil

	checkProgress() { return(nil); }

	configReady() {
		if(getActor() == nil) return(nil);

		// If we have nothing we want to lock *in general* then
		// we have nothing to do.
		unlockList = getActor().targetEngine.unlockList;
		if((unlockList == nil) || (unlockList.length < 1))
			return(nil);

		// Now we figure out if anything we want to unlock in
		// general (the unlockList) is in our current scope.
		// The elements of this list will satisfy:
		//	-on the engine's unlockList
		//	-in the current scope
		//	-we're carrying a plausible key for it
		//	-we haven't tried the plausible key previously
		unlockScopeList = getUnlockScopeList();

		return(unlockScopeList.length > 0);
	}

	getUnlockScopeList() {
		return(filterScopeList({ x: candidateForUnlocking(x) }));
	}

	// See if the object is a candidate for unlocking.  It is if we
	// have it on the unlockList for this actor, and the actor is
	// carrying a plausible key that they haven't tried yet.
	candidateForUnlocking(obj) {
		// See if it's on the list of locked things we're generally
		// interested in.
		if(unlockList.indexOf(obj) == nil)
			return(nil);

		if(getUntriedKeyFor(obj) == nil)
			return(nil);

		// Default:  nope.
		return(nil);
	}

	getUntriedKeyFor(obj) {
		local i, l;

		// See if we have any plausible keys for the locked object.
		l = getPlausibleKeysFor(obj);
		if(l.length < 1)
			return(nil);

		// See if any of the plausible keys are untried on this
		// object.
		for(i = 1; i <= l.length; i++) {
			if(isKeyUntried(l[i], obj))
				return(l[i]);
		}

		return(nil);
	}

	isKeyUntried(key, obj) {
		if(keysTried == nil)
			return(true);
		if(keysTried[key] == nil)
			return(true);
		return(keysTried[key].indexOf(obj) == nil);
	}

	addTriedKey(key, obj) {
		if(keysTried == nil)
			keysTried = new LookupTable();
		if(keysTried[key] == nil)
			keysTried[key] = new Vector();
		keysTried[key].appendUnique(obj);
	}

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

	takeAction() {
		local a, k, obj;

		a = getActor();

		// Should never happen.
		if((unlockScopeList == nil) || (unlockScopeList.length < 1))
			return;

		obj = unlockScopeList[1];
		k = getUntriedKeyFor(obj);
		if((k == nil) || (obj == nil))
			return;

		addTriedKey(k, obj);
		if(execCommandAs(a, 'unlock <<obj.name>> with <<k.name>>') == nil) {
			_debug('key <<k.name>> failed for <<obj.name>>');
			return;
		}
	}
;
