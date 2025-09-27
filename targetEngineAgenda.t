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

	// All our agends are active by default.
	initiallyActive = true

	// A list of objectives.  Elements are instances of TargetEngineTarget.
	targetList = nil

	// Standard adv3 agenda method.  Here we check to see if we have
	// a complete config.
	isReady = (configReady() == true)

	// A complete config consists of something to seek and an actor
	// to do the seeking.
	configReady = ((getActor() != nil) && (targetCount() > 0))

	// Add a target to the list.
	setTarget(v) {
		if((v == nil) || !v.ofKind(TargetEngineTarget))
			return(nil);

		if(targetList == nil)
			targetList = new Vector();

		targetList.appendUnique(v);

		return(true);
	}

	// Synonym for setTarget()
	addTarget(v) { return(setTarget(v)); }


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

	// Returns the current number of targets.
	targetCount = (targetList ? targetList.length : 0)

	// Returns boolean true if there are no current targets.
	noTargets = (targetCount() == 0)

	// Returns true if the actor is at a target.
	atTarget = (getTargetAtLocation() != nil)

	// Returns the first target at the actor's location.
	getTargetAtLocation() {
		local a;

		if(((a = getActor()) == nil) || (targetCount() == 0))
			return(nil);

		return(targetList.valWhich({ x: matchTarget(a, x) }));
	}

	filterScopeList(fn) {
		local a, lst;

		a = getActor();

		// Base scope list.
		lst = a.scopeList();

		// Exclude ourselves.
		lst = lst.subset({ x: x != a });

		// Exclude anything we're carrying.
		lst = lst.subset(
			{ x: a.contents.valWhich({ y: y == x }) == nil });

		if(isFunction(fn))
			lst = lst.subset(fn);

		return(lst);
	}

	matchTarget(actor, obj) {
		return(_matchTargetExact(actor, obj));
	}

	_matchTargetByClass(actor, obj) {
		local i, l;

		l = actor.scopeList();
		for(i = 1; i <= l.length; i++) {
			if(l[i].ofKind(obj.target))
				return(true);
		}

		return(nil);
	}

	// Matches a specific, individual object in the actor's location.
	_matchTargetExact(actor, obj) {
		return(obj.target && ((obj.target.location == actor.location)
			|| (obj.target == actor.location)));
	}

	// Returns a vector of all targets at the actor's location.
	getTargetsAtLocation() {
		local a, r;

		if(((a = getActor()) == nil) || (targetCount() == 0))
			return(nil);

		r = new Vector();
		targetList.forEach(function(o) {
			if(o.target && ((o.target.location == a.location)
				|| (o.target == a.location))) {
				r.appendUnique(o);
			}
		});

		return(r);
	}

	// Clear the config.  We don't clear the actor because it's the
	// one that owns the agenda.
	clearConfig() { targetList.setLength(0); }

	// Clear a specific target.
	clearTarget(v, [args]) {
		v.callback(args...);
		if(targetList != nil)
			targetList.removeElement(v);
	}
	removeTarget(v, [args]) { clearTarget(v, args...); }

	clearTargetObj(v) {
		local b, r;

		if((v == nil) || (targetList == nil))
			return(nil);

		if(v == true) {
			targetList = nil;
			return(true);
		}

		if(v.ofKind(TargetEngineTarget))
			v = v.target;

		b = nil;
		while((r = targetList.valWhich({ x: x.target == v })) != nil) {
			targetList.removeElement(r);
			b = true;
		}

		return(b);
	}

	targetSuccess(v) { clearTarget(v, true); }
	targetFailure(v) { clearTarget(v, nil); }
	targetFailed(v) { targetFailure(v); }

	invokeItem() {
		if(checkProgress())
			return;
		takeAction();
	}

	// Stub main action method.
	takeAction() {}

	// Stub method.  Subclasses should check the given target
	// and clear it if it's succeeded or failed.
	checkTarget(t) {}
	checkTargets() {}

	// Check to see if we're out of targets.
	checkProgress() {
		checkTargets();

		if(targetCount() != 0)
			return(nil);

		clearConfig();

		return(true);
	}

	getExitList(rm, cb?) {
		local a, c, dst, r;

		a = getActor();
		r = new Vector(Direction.allDirections.length());

		Direction.allDirections.forEach(function(d) {
			if((c = rm.getTravelConnector(d, a)) == nil)
				return;

			if(!c.isConnectorApparent(rm, a))
				return;

			if((dst = c.getDestination(rm, a)) == nil)
				return;

			if((cb != nil) && ((cb)(d, dst) != true))
				return;

			r.append(new DestInfo(d, dst, nil, nil));
		});

		return(r);
	}
;
