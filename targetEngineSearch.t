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
	agendaOrder = 134

	// Per-turn list of searchable objects in the actor's current context.
	searchList = nil

	checkProgress() { return(nil); }

	configReady() {
		if(getActor() == nil) return(nil);
		if(targetCount() == 0) return(nil);

		searchList = getSearchList();

		return((searchList != nil) && (searchList.length > 0));
	}

	getSearchList() { return(filterScopeList({ x: isSearchable(x) })); }

	isSearchable(obj) {
		// Openable but closed containers are search targets.
		if(obj.ofKind(OpenableContainer) && !obj.isOpen()) {
			return(true);
		}

		// Default:  nope.
		return(nil);
	}

	takeAction() {
		local a, i;

		a = getActor();

		// Should never happen.
		if((searchList == nil) || (searchList.length < 1))
			return;

		for(i = 1; i <= searchList.length; i++) {
			if(a.open(searchList[i]) == true) {
				a.invokeAgendaMatching(Open);
				return;
			}
		}
	}

		
;
