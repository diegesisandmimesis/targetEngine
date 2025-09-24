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

	searchList = nil

	checkProgress() { return(nil); }

	configReady() {
		if(getActor() == nil) return(nil);

		searchList = getSearchList();

		return((searchList != nil) && (searchList.length > 0));
	}

	getSearchList() {
		local a, lst;

		a = getActor();
		lst = a.scopeList();
		lst = lst.subset({ x: x != a });
		lst = lst.subset({ x: a.contents.valWhich({ y: y == x }) == nil });
		lst = lst.subset({ x: isSearchable(x) });
	}

	isSearchable(obj) {
	}
;
