#charset "us-ascii"
//
// targetEngineObtainCustom.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class ObtainCustom: Obtain
	syslogID = 'ObtainKey'

	agendaOrder = 126

	matchTarget(actor, obj) {
		return(matchCustom(actor, obj) != nil);
	}

	matchCustom(actor, obj) {
		local i, l;

		if(!isFunction(obj.target)) return(nil);
		l = actor.scopeList();
		for(i = 1; i <= l.length; i++) {
			if((obj.target)(l[i]) == true)
				return(l[i]);
		}

		return(nil);
	}

	takeTarget() {
		local a, i, t;

		a = getActor();
		for(i = 1; i <= targetList.length; i++) {
			if((t = matchCustom(a, targetList[i])) != nil) {
				if(a.canTouch(t)) {
					if(execCommandAs(a, 'take <<t.name>>'))
						targetList[i].callback(t);
				}
			}
		}
	}
;
