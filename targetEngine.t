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

// Generic object class for module.
// Mostly to make debugging easier.
class TargetEngineObject: Syslog syslogID = 'TargetEngine';

// Target engine class.
// This serves as a pseudo-namespace for us to hang our methods and
// properties off of, mostly to avoid cluttering up the base Actor
// class and to avoid potential name collisions.
class TargetEngine: TargetEngineObject
	// The actor we belong to.
	actor = nil

	// Base classes for our basic agendas.
	moveAgendaClass = Move
	observeAgendaClass = Observe
	obtainAgendaClass = Obtain

	// List of "built-in" agendas.  These provide the basic
	// functions we use:  moving to a target room, looking at a
	// target object, and so on.
	_agendaList = static [ moveAgendaClass, observeAgendaClass,
		obtainAgendaClass ]

	// Called at preinit.
	initializeTargetEngine() {
		_initializeTargetEngineLocation();
	}

	// Notify our actor about us.  This happens automagically
	// at preinit for TargetEngine instances declared in the source.
	_initializeTargetEngineLocation() {
		if((location == nil) || !location.ofKind(Actor))
			return;

		location.setTargetEngine(self);
	}

	// Initialize the agenda list.
	// This is called by Actor.initializeTargetEngineActor() instead
	// of initializeTargetEngine() above because initializeTargetEngine()
	// only handles TargetEngines declared in source and some actors
	// will have their engines created at preinit instead.
	// Here we go through the agenda list and check to see if the
	// engine already has an agenda matching each element, creating
	// new ones for any that are missing.
	initializeTargetEngineAgendas() {
		local a;

		// We need an actor.
		if(actor == nil)
			return;

		// Go through the list of stock agendas.
		_agendaList.forEach(function(o) {
			// If we already have a matching agenda, nothing
			// to do.
			if(_getAgendaMatching(o) != nil)
				return;

			// Create the new agenda and add it to the actor.
			a = o.createInstance();
			a.location = actor;
			actor.addToAgenda(a);
		});
	}

	// Getter method for the actor's agenda list.
	_getAgendaList() { return(actor ? actor.agendaList : nil); }

	// Returns the first agenda that matches the given class.
	// An agenda matches if it's a subclass of the given class or
	// if it is identically the given class.  (The second should never
	// actually happen but eh, better safe than sorry).
	_getAgendaMatching(cls) {
		local l;

		if((l = _getAgendaList()) == nil)
			return(nil);
		return(l.valWhich(function(o) {
			return(o.ofKind(cls) || (o == cls));
		}));
	}

	// Add a target.
	// Args are, in order:  the target itself (probably a Thing of
	// some sort);  an optional callback to invoke when the target
	// is reached/obtained/whatever (as defined by the agenda
	// the target is being added to);  and the class of the agenda
	// to add the target to.
	// The second arg is theoretically optional, but we're only
	// called internally (by the methods directly below) so we
	// officially need a nil for the second argument if there's
	// no callback.
	_setTarget(v, cb, cls) {
		local a, obj;

		if((a = _getAgendaMatching(cls)) == nil)
			return(nil);

		obj = new TargetEngineTarget(v, cb);
		obj.targetEngine = self;
		a.setTarget(obj);

		return(true);
	}

	// Convenience methods for setting targets on specific types
	// of agendas.
	moveTo(v, cb?) { return(_setTarget(v, cb, moveAgendaClass)); }
	observe(v, cb?) { return(_setTarget(v, cb, observeAgendaClass)); }
	obtain(v, cb?) { return(_setTarget(v, cb, obtainAgendaClass)); }
;
