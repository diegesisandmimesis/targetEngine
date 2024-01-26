#charset "us-ascii"
//
// targetEngine.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

// Module ID for the library
targetEngineModuleID: ModuleID {
        name = 'Seek Engine Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class TargetEngineObject: Syslog syslogID = 'TargetEngine';

class TargetEngine: TargetEngineObject
	actor = nil

	moveAgendaClass = Move
	observeAgendaClass = Observe
	obtainAgendaClass = Obtain

	_agendaList = static [ moveAgendaClass, observeAgendaClass,
		obtainAgendaClass ]

	initializeTargetEngine() {
		_initializeTargetEngineLocation();
	}

	_initializeTargetEngineLocation() {
		if((location == nil) || !location.ofKind(Actor))
			return;

		location.setTargetEngine(self);
	}

	initializeTargetEngineAgendas() {
		local a;

		if(actor == nil)
			return;

		_agendaList.forEach(function(o) {
			if(_getAgendaMatching(o) != nil)
				return;
			a = o.createInstance();
			a.location = actor;
			actor.addToAgenda(a);
		});
	}

	_getAgendaList() { return(actor ? actor.agendaList : nil); }
	_getAgendaMatching(cls) {
		local l;

		if((l = _getAgendaList()) == nil)
			return(nil);
		return(l.valWhich(function(o) {
			return(o.ofKind(cls) || (o == cls));
		}));
	}
	_setTarget(v, cb, cls) {
		local a, obj;

		if((a = _getAgendaMatching(cls)) == nil)
			return(nil);

		obj = new TargetEngineTarget(v, cb);
		obj.targetEngine = self;
		a.setTarget(obj);

		return(true);
	}

	moveTo(v, cb?) { return(_setTarget(v, cb, moveAgendaClass)); }
	observe(v, cb?) { return(_setTarget(v, cb, observeAgendaClass)); }
	obtain(v, cb?) { return(_setTarget(v, cb, obtainAgendaClass)); }
;
