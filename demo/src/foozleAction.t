#charset "us-ascii"
//
// foozleAction.t
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

DefineSystemAction(Foozle) execSystemAction() {};
VerbRule(Foozle) 'foozle': FoozleAction VerbPhrase = 'foozle/foozling';

