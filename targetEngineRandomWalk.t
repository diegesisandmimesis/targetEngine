#charset "us-ascii"
//
// targetEngineRandomWalk.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class RandomWalk: TargetEngineAgendaItem
	syslogID = 'RandomWalk'

	// TargetEngine agendas are in the range 101-199.  We're here
	// to allow observation and scavenging to happen before movement.
	agendaOrder = 199

	currentTarget = nil
	randomWalkTimer = 0

	atTarget = nil
	getTargetAtLocation = nil
	getTargetsAtLocation = nil

	checkTargets() {
		if((currentTarget == nil) || (currentTarget.target == nil))
			return;
		if(randomWalkTimer >= currentTarget.target) {
			clearTarget(currentTarget);
			currentTarget = nil;
			randomWalkTimer = 0;
			return;
		}
	}

	incrementRandomWalkCounter() {
		if(currentTarget.target == nil )
			return;

		randomWalkTimer += 1;
		_debug('randomWalkTimer = <<toString(randomWalkTimer)>>
			of <<toString(currentTarget.target)>>');

	}

	takeAction() {
		local dst;

		if(currentTarget == nil) {
			currentTarget = getTarget(1);
			randomWalkTimer = 0;
		}

		incrementRandomWalkCounter();

		if((dst = getNextMove()) == nil) {
			clearConfig();
			return;
		}

		if(!tryMove(dst)) {
			clearConfig();
			return;
		}
	}

	getNextMove() {
		local a, dst, l;

		a = getActor();
		if((l = getExitList(a.location)) == nil)
			return(nil);

		if((dst = getRandomDirection(l)) == nil) {
			_debug('tryMove():  out of random directions');
			return(nil);
		}

		return(dst);
	}

	tryMove(dst) {
		local a;

		a = getActor();

		_debug('tryMove():  current location = <q><<a.location.name>>
			</q>');

		if(execCommandAs(a, dst.dir_.name) == nil) {
			_debug('tryMove():  movement command failed');
			return(nil);
		}

		return(true);
	}

	getRandomDirection(lst) {
		local idx;

		idx = rand(lst.length) + 1;

		return(lst[idx]);
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
