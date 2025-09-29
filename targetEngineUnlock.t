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

	isReady = ((configReady() == true) && (atTarget() == true))

	// Lookup table, keys are keys, values are vectors of the objects
	// we've tried that key on
	keysTried = nil

	setTarget(v) {
		_debug('setting target');
		return(inherited(v));
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

	getUntriedKeyFor(obj) {
		local i, l;

		l = getPlausibleKeysFor(obj);
		if(l.length < 1)
			return(nil);

		for(i = 1; i <= l.length; i++) {
			if(isKeyUntried(l[i], obj))
				return(l[i]);
		}

		return(nil);
	}

	configReady() {
		_debug('target count = <<toString(targetCount())>>');
		return(inherited());
	}

	matchTarget(a, obj) {
		if(inherited(a, obj) != true) return(nil);
		if(!a.canTouch(obj.target)) return(nil);
		return(getUntriedKeyFor(obj.target) != nil);
	}

	takeAction() {
		local a, k, t;

		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		a = getActor();
		if((k = getUntriedKeyFor(t.target)) == nil)
			return;

		addTriedKey(k, t.target);
		if(forceExecCommandAs(a, 'unlock <<t.target.name>> with <<k.name>>')) {
			_debug('unlocked <<t.target.name>>');
			a.open(t.target);
			targetSuccess(t);
		} else {
			_debug('key <<k.name>> failed for <<t.target.name>>');
			a.getAgendaMatching(Open).addFailed(t.target);
			return;
		}
	}
;
