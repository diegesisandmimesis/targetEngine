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

	isReady = ((configReady() == true) && (atTarget() == true))

	failedList = nil

	matchTarget(actor, obj) {
		if(!inherited(actor, obj)) return(nil);
		if(onFailedList(obj.target)) return(nil);
		return(true);
	}

	takeAction() {
		local a, t;

		if(((t = getTargetAtLocation()) == nil) || (t.target == nil))
			return;

		a = getActor();
		if(a.canTouch(t.target)) {
			if(forceExecCommandAs(a, 'open <<t.target.name>>')) {
				targetSuccess(t);
			} else {
				t.target.isLocked();
				a.unlock(t.target);
				a.obtainCustom(bind(&matchKey, self, t.target));
				targetFailure(t);
				addFailed(t.target);
			}
		}
		checkProgress();
	}

	matchKey(cont, obj) {
		if(!obj.ofKind(Key))
			return(nil);
		if(obj.getCarryingActor() == getActor())
			return(nil);
		if(cont.keyIsPlausible(obj))
			return(true);
		
		return(nil);
	}

	addFailed(obj) {
		if(failedList == nil)
			failedList = new Vector();
		failedList.appendUnique(obj);
		return(true);
	}

	clearFailed(obj, data?) {
		if(failedList == nil)
			return(nil);
		failedList = failedList.subset({ x: x != obj });
		return(true);
	}

	onFailedList(obj) {
		if(failedList == nil)
			return(nil);
		return(failedList.valWhich({ x: x == obj }) != nil);
	}
;
