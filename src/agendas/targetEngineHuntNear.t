#charset "us-ascii"
//
// targetEngineHuntNear.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

modify Room
	// Returns a list of all rooms within n steps of this room.
	// Second arg is the actor to use to test travel connectors.
	getDijkstraNeighborhood(n?, actor?) {
		local dHash;

		// Default to 1 step if not specified.
		n = (isInteger(n) ? n : 1);

		// Default to gActor if no actor is specified.
		actor = (isActor(actor) ? actor : gActor);

		// Hash table to hold our work.
		// Keys will be rooms, values will be the distance from us.
		dHash = new LookupTable();

		// This room will be present at distance 0.
		dHash[self] = 0;

		// Recursively search around ourselves out to n steps.
		updateDijkstraHash(dHash, 0, n, actor);

		// Return the (unsorted) list of rooms.
		return(dHash.keysToList());
	}

	// Given a hash of Dijkstra distances (first arg) and a current
	// distance, recursively call ourselves until the hash contains
	// all rooms with distances m and less.
	updateDijkstraHash(dh, n, m, actor?) {
		// Check values, assign defalts if necessary.
		n = (isInteger(n) ? n : 1);
		m = (isInteger(m) ? m : n);
		actor = (isActor(actor) ? actor : gActor);

		// If we're at the maximum distance we're done.
		if(n >= m)
			return;

		// Check every exit.  exitList() returns a list of
		// DestInfo instances, .dest_ is the room for each.
		exitList(actor).forEach(function(x) {
			// If we don't already have a distance for this
			// room, it's our distance plus one.
			if(dh[x.dest_] == nil) {
				dh[x.dest_] = n + 1;

				// Recurse.
				x.dest_.updateDijkstraHash(dh, n + 1,
					m, actor);
			} else if(dh[x.dest_] > (n + 1)) {
				// See if we just found a shortcut.
				dh[dest_] = n + 1;
			}
		});
	}
;

class HuntNear: TargetEngineAgendaItem
	syslogID = 'HuntNear'

	agendaOrder = 190

	maxDijkstraDistance = 2
	roomList = nil

	setTarget(v) {
		if(!isTargetEngineTarget(v) || !isRoom(v.target))
			return(nil);
		if(inherited(v) != true)
			return(nil);

		roomList = v.target.getDijkstraNeighborhood(maxDijkstraDistance,
			getActor());

		/*
		aioSay('\nroomList for <<v.target.roomName>>:\n ');
		roomList.forEach(function(x) {
			aioSay('\n\t<<x.roomName>>\n ');
			x.exitList(getActor()).forEach(function(y) {
				aioSay('\n\t\t<<y.dest_.roomName>>\n ');
			});
		});
		*/

		return(true);
	}
;
