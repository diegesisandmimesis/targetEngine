#charset "us-ascii"
//
// targetEngineMove.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Move: TargetEngineAgendaItem
	syslogID = 'Move'

	// TargetEngine agendas are in the range 101-199.  We're here
	// to allow observation and scavenging to happen before movement.
	agendaOrder = 150

	// Computed path
	path = nil
	// Number of times to retry path computation
	pathfindingRetries = 3

	invokeItem() {
		local t;

		// If we're at the destination, we're done.  Success.
		if((t = getTargetAtLocation()) != nil)
			clearTarget(t);

		if(noTargets()) {
			success();
			return;
		}

		// Figure out what the next step is.
		if(computeMove() != true) {
			failure();
			return;
		}

		// Try to take the next step.
		if(tryMove() != true) {
			failure();
			return;
		}
	}

	computeMove() {
		if(pathfinding() != true) {
			_debug('makeMove():  pathfinding failed');
			return(nil);
		}

		if(checkPath() != true) {
			_debug('makeMove():  path check failed');
			return(nil);
		}

		return(true);
	}

	// Compute the path to the target.
	pathfinding(force?) {
		local a, t;

		// We don't recompute if we already have a path, unless
		// the force argument is boolean true.
		if((path != nil) && (force != true))
			return(true);

		// Use our pathfinder to get the path.
		a = getActor();
		if(((t = getTarget(1)) == nil) || (t.target == nil))
			return(nil);
		path = targetEnginePathfinder.findPath(a, a.location,
			t.target);

		// Should never happen.
		if(path == nil)
			return(nil);

		return(true);
	}

	// See if we're in the first location in our path.  If we're
	// not for some reason, we need to recompute the path.
	checkPath() {
		local a, i;

		if(path == nil)
			return(nil);

		a = getActor();
		i = 0;

		// If the actor isn't in the first spot in the path,
		// force a recompute of the path and check again, failing
		// if we exceed our number retries.
		while((path != nil) && (path[1] != a.location)) {
			if(i >= pathfindingRetries) {
				_debug('checkPath():  retries exhausted');
				return(nil);
			}

			// Force a recompute of the path.
			pathfinding(true);
			i += 1;
		}

		return(true);
	}

	tryMove() {
		local a, r, rm0, rm1;

		if((path == nil) || (path.length < 2)) {
			_debug('tryMove():  invalid path');
			return(nil);
		}

		a = getActor();
		rm0 = path[1];
		rm1 = path[2];

		if((dir = nextMove(a, rm0, rm1)) == nil) {
			_debug('tryMove():  unable to compute move direction');
			return(nil);
		}

		if((r = execCommandAs(a, dir.name)) == nil) {
			_debug('tryMove():  movement command failed');
			if(r) {}
			return(nil);
		}

		path = path.removeElementAt(1);

		return(true);
	}

	nextMove(actor, src, dst) {
		return(Direction.allDirections.valWhich(function(d) {
			local conn;

			conn = src.getTravelConnector(d, actor);
			return((conn != nil) && conn.isConnectorListed
				&& conn.getDestination(src, actor) == dst);
		}));
	}
;
