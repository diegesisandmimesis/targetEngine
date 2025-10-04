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
targetEngineMethods(observe, Observe, 110)
targetEngineMethods(interrogate, Interrogate, 120)
targetEngineMethods(obtain, Obtain, 130)
targetEngineMethods(obtainCustom, ObtainCustom, 135)
targetEngineMethods(unlock, Unlock, 140)
targetEngineMethods(open, Open, 150)
targetEngineMethods(search, Search, 160)
targetEngineMethods(moveTo, MoveTo, 170)
targetEngineMethods(explore, Explore, 180)
targetEngineMethods(huntNear, HuntNear, 190)
targetEngineMethods(randomWalk, RandomWalk, 199)
