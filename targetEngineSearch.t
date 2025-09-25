#charset "us-ascii"
//
// targetEngineSearch.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Search: TargetEngineAgendaItem
	syslogID = 'Search'

	// TargetEngine agendas are in the range 101-199.  We're after
	// Observe and Obtain and before the movement-related agendas.
	agendaOrder = 130

	// Per-turn list of searchable objects in the actor's current context.
	searchList = nil

	_lockedList = nil
	_neededKeys = nil

	_triedList = nil

	checkProgress() { return(nil); }

	configReady() {
		if(getActor() == nil) return(nil);
		if(targetCount() == 0) return(nil);

		searchList = getSearchList();

		return((searchList != nil) && (searchList.length > 0));
	}

	getSearchList() {
		return(filterScopeList({ x: isSearchable(x) }));
	/*
		local a, lst;

		a = getActor();
		lst = a.scopeList();
		lst = lst.subset({ x: x != a });
		lst = lst.subset(
			{ x: a.contents.valWhich({ y: y == x }) == nil });
		lst = lst.subset({ x: isSearchable(x) });

		return(lst);
	*/
	}

	addToLockedList(obj) {
		if(_lockedList == nil)
			_lockedList = new Vector();
		_lockedList.appendUnique(obj);
	}

	isOnLockedList(obj) {
		return((_lockedList != nil)
			&& (_lockedList.valWhich({ x: x == obj }) != nil));
	}

	addToTriedList(obj) {
		if(_triedList == nil)
			_triedList = new Vector();
		_triedList.appendUnique(obj);
	}

	isOnTriedList(obj) {
		return((_triedList != nil)
			&& (_triedList.valWhich({ x: x == obj }) != nil));
	}

	isSearchable(obj) {
		// If we already tried it, skip it.
		if(isOnTriedList(obj)) return(nil);

		// Openable but closed containers are search targets.
		if(obj.ofKind(OpenableContainer) && !obj.isOpen()) {
			// Skip containers we know we can't open.
			if(isOnLockedList(obj)) return(nil);

			return(true);
		}

		// Default:  nope.
		return(nil);
	}

	takeAction() {
		local a, obj;

		a = getActor();

		// Should never happen.
		if((searchList == nil) || (searchList.length < 1)) {
			return;
		}

		obj = searchList[1];

		if(execCommandAs(a, 'open <<obj.name>>') == nil) {
			// Remember this object.
			if(obj.isLocked()) {
				// Remember that the container is locked, in
				// the interest of checking later if we have
				// the key.
				addToLockedList(obj);
			} else {
				// Remember a failure for reasons other than
				// the container being locked.  By default
				// we won't retry these.
				addToTriedList(obj);
			}
			_debug('takeAction(): attempt to open <<obj.name>>
				failed');
			return;
		}
	}
;
