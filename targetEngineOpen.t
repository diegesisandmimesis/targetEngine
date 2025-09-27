#charset "us-ascii"
//
// targetEngineOpen.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Open: TargetEngineAgendaItem
	syslogID = 'Unlock'

	agendaOrder = 132

	checkProgress() { return(nil); }

	configReady() {
		if(getActor() == nil) return(nil);
		if(targetCount() == 0) return(nil);

		searchList = getSearchList();

		return((searchList != nil) && (searchList.length > 0));
	}

	getSearchList() {
		return(filterScopeList({ x: isSearchable(x) }));
	}

	addToLockedList(obj) {
		if(_lockedList == nil)
			_lockedList = new Vector();
		_lockedList.appendUnique(obj);
		getActor().obtainCustom(bind(&matchKey, self),
			bind(&obtainedKey, self));
	}

	matchKey(obj) {
		local i;

		if(!obj.ofKind(Key))
			return(nil);

		if(_lockedList == nil)
			return(nil);

		for(i = 1; i <= _lockedList.length; i++) {
			if(_lockedList[i].keyIsPlausible(obj))
				return(true);
		}

		return(nil);
	}

	obtainedKey(obj) {
		_lockedList = _lockedList.subset({ x: !x.keyIsPlausible(obj) });
		//aioSay('\nobtained <<toString(obj)>>\n ');
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
