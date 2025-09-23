#charset "us-ascii"
//
// targetEngineExplore.t
//
//	Agenda for exploring unvisited locations.
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

// Data structure for remembering search options we didn't take.
// When we're in a location with two exits we haven't tried we pick
// one and remember the other by creating an instance of UnexploredExit
// and storing it in Find._unexploredStack.
class UnexploredExit: object
	dstInfo = nil		// unvisited destination info
	from = nil		// location containing exit to dst
	construct(v0, v1) { dstInfo = v0; from = v1; }
;

class Explore: TargetEngineAgendaItem
	syslogID = 'Explore'

	// By default we do a depth-first search.  That means that if the
	// NPC sees an exit they haven't tried in their current location,
	// they'll prefer trying it over backtracking.  When backtracking
	// they'll return to the most recent room they've been to that
	// has one or more unvisited exits.
	// With breadth-first searching the NPC will preferentially backtrack
	// to try all exits out of the earliest-remembered room with unvisited
	// exits, exhaust all of those exits, before moving on to the
	// next-oldest room with unvisited exits.  This will _generally_
	// involve more backtracking that depthFirst, but it really
	// depends on the actual layout of the map.
	depthFirst = true

	// The Explore agenda has a priority between the Move (which goes
	// before) and RandomWalk (which goes after)
	agendaOrder = 180

	// Vector holding UnexploredExit instances, to keep track of
	// exits we haven't visited but can't take when we notice them.
	_unexploredStack = nil

	// Flag that indicates whether or not we've tried to initialize
	// the unvisited exits list via traversing all Room instances.
	// We only do that once per target.
	_unexploredInit = nil

	clearConfig() {
		_unexploredStack = nil;		// clear the unvisited exit list
		_unexploredInit = nil;		// clear the init flag

		// The normal housekeeping.
		inherited();
	}

	checkProgress() {
		// First, check to see if there are any unexplored exits
		// in the current location.
		updateUnexplored();

		// Fallback.  If the unexplored exit stack is nil (and not
		// just empty) then that probably means we were initialized
		// already knowing about the rooms around us.  To deal with
		// that, we'll try iterating over all rooms and add exits
		// to rooms we HAVEN'T visited that we "remember" from
		// the rooms we HAVE visited.
		if(_unexploredStack == nil)
			initUnexplored();

		// Clean up the stack.  This removes exits to rooms we
		// might have visited since they were added to the stack.
		verifyUnexplored();

		// If we still have no unexplored exits to check, we have
		// nothing to do.  Clear the config, we're done.
		if((_unexploredStack == nil) || (_unexploredStack.length < 1)) {
			clearConfig();
			return(true);
		}

		// Returning nil means "we're not done".
		return(nil);
	}

	// Remember all the unexplored exits from the current locaiton.
	updateUnexplored() { _updateUnexplored(getActor().location); }

	// Utility method that returns a list of all exits from the given
	// room that lead to destinations our actor hasn't seen.
	_getUnexploredExits(rm) {
		local a, lst;

		if((rm == nil) || !rm.ofKind(Room))
			return([]);

		if((lst = rm.exitList()) == nil)
			return([]);

		a = getActor();

		return(lst.subset({ x: !a.hasSeen(x.dest_) }));
	}

	// Remember all the unexplored exits from the given room.
	_updateUnexplored(rm) {
		_getUnexploredExits(rm).forEach({
			x: addUnexploredExit(x, rm) });
	}

	// Go through the stack of unexplored rooms and remove any that
	// have been visited since being added.
	verifyUnexplored() {
		local a;

		if(_unexploredStack == nil)
			return;

		a = getActor();
		_unexploredStack = _unexploredStack.subset({
			x: !a.hasSeen(x.dstInfo.dest_) });
	}

	// Attempt to initialize the list of unexplored exits.
	// By default the first thing the agenda does in a turn it's active
	// is to check the current location for exits to unvisted locations.
	// If we make it through that without initializing the stack of
	// unexplored exits, that means that we looked around and already
	// new every connecting locaiton.  That should only happen in
	// situations where the NPC has "memories" at the start of the
	// game:  we were initialized already "knowing" about surrounding
	// rooms.  To keep that from making us just give up (because we're
	// looking for unexplored rooms and we just looked around and can't
	// see any and don't remember any) we iterate over all rooms, check
	// only those we've "seen", and take note of any unexplored exits
	// from them.
	initUnexplored() {
		local a;

		// Check the flag.  If we've already done this once, we
		// don't do it again.
		if(_unexploredInit == true)
			return(nil);
		_unexploredInit = true;

		a = getActor();

		// Iterate over all rooms.
		forEachInstance(Room, function(x) {
			// We only care about rooms this actor has seen.
			if(!a.hasSeen(x)) return;

			// Remember the unexplored exits in this room.
			_updateUnexplored(x);
		});

		return(true);
	}

	// Remember an unvisited exit.
	addUnexploredExit(d, f) {
		if((d == nil) || !d.ofKind(DestInfo))
			return;
		if(_unexploredStack == nil)
			_unexploredStack = new Vector();
		_unexploredStack.append(new UnexploredExit(d, f));
	}

	// Try to move.
	takeAction() {
		local dst;

		// Figure out if we're using depth- or breadth-first
		// searching.
		if(depthFirst == true)
			dst = depthFirstMove();
		else
			dst = breadthFirstMove();

		// The return value of our [whatever]Move() methods is:
		//
		//	nil	hard fail, give up
		//
		//	true	soft fail, just return. this will try to
		//		use the Move agenda to move us to a better
		//		location
		//
		//	[other]	success.  value should be a DestInfo instance
		//		for the chosen move
		//
		if(dst == nil) {
			_debug('failed, clearing');
			clearConfig();
			return;
		} else if(dst == true) {
			return;
		}

		// We DID get an exit to try above, so we try it.
		if(!tryMove(dst)) {
			_debug('move failed, should never happen');
			return;
		}
	}

	// Movement for a depth-first search.
	// Return value is a DestInfo instance on success, nil on failure,
	// and true if we've punted off to the move agenda.
	depthFirstMove() {
		local dst;

		// First we try to pick an exit from our current location that
		// leads somewhere we haven't been.
		if((dst = getUnexploredExit()) != nil)
			return(dst);

		// If the current location doesn't have any unvisited
		// exits, see if we remember any other places to try.
		if(backtrack() != nil)
			return(true);

		return(nil);
	}

	// Argument is a list of exits; see if any of them lead to someplace
	// we haven't been.
	getUnexploredExit() {
		local lst;

		lst = _getUnexploredExits(getActor().location);
		return((lst.length > 0) ? lst[1] : nil);
	}


	// If we're here, then there are no exits from our current location
	// that we haven't already tried.  So now we see if we can remember
	// some place we've been before that has an exit we haven't tried.
	// If so, we'll try to move to it and continue from there.
	backtrack() {
		local o;

		// Out of options, fail.
		if(_unexploredStack.length < 1) {
			_debug('backtrack(): out of options');
			return(nil);
		}

		// Pick the last (most recent) element of the stack, make
		// sure it's valid.
		o = _unexploredStack[_unexploredStack.length];
		if(!o.ofKind(UnexploredExit)) {
			_debug('backtrack(): invalid memory');
			return(nil);
		}

		// We choose the most recent location with an exit we
		// haven't tried and path to it.  We punt to the Move
		// agenda because that's what it's for.
		_debug('backtrack(): trying
			<q><<o.from.roomName>></q>');

		puntToMoveAgenda(o.from);

		// Return true, which tells our caller not to clear
		// our config; we're still searching.
		return(true);
	}

	// Movement for a breadth-first search.
	// Return value is a DestInfo instance on success, nil on failure,
	// and true if we've punted off to the move agenda.
	breadthFirstMove() {
		local a, lst, r;

		a = getActor();

		// Get the unexplored exits from the current location.
		// We only use this when checking to see if an exit in
		// the stack corresponds to one in the current room.
		lst = _getUnexploredExits(a.location);

		// Now we try to pick the first unvisited exit on the
		// list.  This will be the oldest entry on the list.
		while(_unexploredStack.length > 0) {
			// If we're already in the location the unvisited
			// exit leads out of, we don't have to go there
			// to try the exit.  So we just return it.
			if(a.location == _unexploredStack[1].from) {
				r = lst.valWhich({ x: x.dest_ ==
					_unexploredStack[1].dstInfo.dest_ });
				// Should never happen.
				if(r == nil)
					return(nil);
				return(r);
			} else {
				// We're NOT in the room we saw the exit
				// we want to try in, so now we move to
				// it.
				puntToMoveAgenda(_unexploredStack[1].from);
				return(true);
			}
		}

		return(nil);
	}

	// Try to move to the given location (given in a DestInfo instance).
	tryMove(dst) {
		local a;

		a = getActor();

		if(execCommandAs(a, dst.dir_.name) == nil) {
			_debug('tryMove():  movement command failed');
			return(nil);
		}
		_debug('tryMove():  <<a.name>> moved <<dst.dir_.name>>');

		return(true);
	}

	// Use the move agenda to move to the given room.
	puntToMoveAgenda(dst) {
		local a, m;

		a = getActor();

		// Set a new target for the actor's move agenda.
		a.moveTo(dst);

		// Get the move agenda itself.
		m = a.targetEngine._getAgendaMatching(
			a.targetEngine.moveAgendaClass);

		// Invoke it.  We do this because our agendaOrder is higher
		// than the move agenda and if we've reached this point we're
		// not going to take any action this turn ourselves.  This
		// prevents the actor from spending a turn doing nothing.
		m.invokeItem();
	}
;
