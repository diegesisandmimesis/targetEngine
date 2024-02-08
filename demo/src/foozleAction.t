#charset "us-ascii"
//
// foozleAction.t
//
//	Stub version of the demo action.
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

DefineSystemAction(Foozle) execSystemAction() {};
VerbRule(Foozle) 'foozle': FoozleAction verbPhrase = 'foozle/foozling';

