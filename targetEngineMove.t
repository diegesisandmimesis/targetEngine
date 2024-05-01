#charset "us-ascii"
//
// targetEngineMove.t
//
//	Agenda that takes care of moving to a requested location.
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

	// At any given point we're trying to move to only one target, even
	// if we have more.  This is the one we're currently moving toward.
	moveTarget = nil

	checkTargets() {
		local t;

		if((t = getTargetAtLocation()) != nil)
			targetSuccess(t);
	}

	// Called every turn as part of adv3's agenda logic.
	takeAction() {
		if(moveTarget == nil)
			moveTarget = getTarget(1);

		// Figure out what the next step is.
		if(computeMove() != true) {
			targetFailed(moveTarget);
			moveTarget = nil;
			path = nil;
			return;
		}

		// Try to take the next step.
		if(tryMove() != true) {
			targetFailed(moveTarget);
			moveTarget = nil;
			path = nil;
			return;
		}
	}

	// Make sure we have a next move.
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
		local a;

		// We don't recompute if we already have a path, unless
		// the force argument is boolean true.
		if((path != nil) && (force != true))
			return(true);

		// Use our pathfinder to get the path.
		a = getActor();
		if((moveTarget == nil) || (moveTarget.target == nil))
			return(nil);
		path = targetEnginePathfinder.findPath(a, a.location,
			moveTarget.target);

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

	// Actually try to take the next step in our computed path.
	tryMove() {
		local a;

		// The path should contain at least the actor's current
		// location and the target, so if we don't have a path
		// with at least two elements we're borked.
		if((path == nil) || (path.length < 2)) {
			_debug('tryMove():  invalid path');
			return(nil);
		}

		a = getActor();

		// Figure out what direction the next step is in.
		if((dir = nextMove(a, path[1], path[2])) == nil) {
			_debug('tryMove():  unable to compute move direction');
			return(nil);
		}

		// Try to take the computed move.
		if(execCommandAs(a, dir.name) == nil) {
			_debug('tryMove():  movement command failed');
			return(nil);
		}

		// Remove the old current location from the path.
		// If the remaining path has less than two elements,
		// we've reached the target.
		path = path.removeElementAt(1);
		if(path.length < 2) {
			moveTarget = nil;
			path = nil;
			return(checkProgress());
		}

		return(true);
	}

	// Returns the direction actor needs to move in order to get
	// from src to dst.
	nextMove(actor, src, dst) {
		return(Direction.allDirections.valWhich(function(d) {
			local conn;

			conn = src.getTravelConnector(d, actor);
			return((conn != nil) && conn.isConnectorListed
				&& conn.getDestination(src, actor) == dst);
		}));
	}
;
