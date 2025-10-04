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
		local t;

		// Make sure our target is a room.
		if(!isTargetEngineTarget(v) || !isRoom(v.target))
			return(nil);

		// If the base target-setting logic fails, give up.
		if(inherited(v) != true)
			return(nil);

		t = libGlobal.totalTurns;

		v.target.getDijkstraNeighborhood(maxDijkstraDistance,
			getActor()).forEach({ x: updateRoomList(x, t) });

		return(true);
	}

	updateRoomList(rm, t) {
		if(roomList == nil)
			roomList = new LookupTable();
		roomList[rm] = t;
	}

	checkProgress() {
		if(targetCount() == 0) {
			clearConfig();
			return(true);
		}
		if(checkRoomList()) {
			return(nil);
		}

		clearConfig();

		return(true);
	}

	// See if we have any rooms left on the list.
	checkRoomList() {
		local a, m, r;

		if(roomList == nil)
			return(nil);

		a = getActor();

		// List of rooms we've seen since adding them to the list.
		r = new Vector();

		roomList.forEachAssoc(function(k, v) {
			// If we have no memory of the room, we still haven't
			// been there.
			if((m = a.getMemory(k)) == nil)
				return;

			// If we've seen the room since it was added to the
			// list we can remove it from the list.
			if(m.lastSeenTurn() > v)
				r.append(k);
		});

		// Remove all the rooms we've seen since they were added.
		r.forEach({ x: roomList.removeElement(x) });

		// See if we have any rooms left.
		return(roomList.keysToList().length > 0);
	}

	takeAction() {
		local a, l;

		// Should never happen.
		if(roomList == nil)
			return;

		l = roomList.keysToList();
		if(l.length < 1)
			return;

		a = getActor();

		// Remove the first element on the list.
		roomList.removeElement(l[1]);

		// ...have the actor try to move to it.
		a.moveTo(l[1]);

		// ...and ping the move agenda.  We do this because all
		// we (this agenda) is doing is thinking, and if we're
		// here then the agendaOrder for the move agenda is already
		// past, so we manually invoke it to prevent the NPC
		// wasting a turn twiddling their thumbs thinking about
		// where to go next.
		a.invokeAgendaMatching(MoveTo);
	}
;
