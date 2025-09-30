#charset "us-ascii"
//
// targetEngineMethods.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

// Convenience methods on the TargetEngine and Actor classes.
// The first arg to the macro is the method name, the second is the
// agenda class it invokes.  Example:
//
// 	targetEngineMethods(foozle, Foozle)
//
// adds a .foozle() and .clearFoozle() method to TargetEngine and Actor,
// for interacting with a TargetEngineAgenda subclass named Foozle
//
targetEngineMethods(explore, Explore)
//targetEngineMethods(find, Find)
targetEngineMethods(interrogate, Interrogate)
targetEngineMethods(moveTo, MoveTo)
targetEngineMethods(observe, Observe)
targetEngineMethods(obtain, Obtain)
targetEngineMethods(obtainCustom, ObtainCustom)
targetEngineMethods(randomWalk, RandomWalk)
targetEngineMethods(search, Search)
targetEngineMethods(open, Open)
targetEngineMethods(unlock, Unlock)


/*
modify TargetEngine
	obtainAgendaClass = Obtain
	_agendaList = (nilToList(inherited()) + [ Obtain ])
	obtain(v?, cb?) { return(_setTarget(v, cb, obtainAgendaClass)); }
	clearObtain(v) { return(_clearTargetObj(v, obtainAgendaClass)); }
;

modify Actor
	obtain(v?, cb?) { return(targetEngine ? targetEngine.obtain(v, cb) : nil); }
	clearObtain(v) { return(targetEngine ? targetEngine.clearObtain(v) : nil); }
;
*/
