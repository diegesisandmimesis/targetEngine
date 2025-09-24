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

DefineSystemAction(Info)
	execSystemAction() {}
	info(obj) {
		if((obj == nil) || (obj.location == nil)) return;
		"<<obj.name>> @ <<toString(obj.location.roomName)>>\n ";
	}
;
VerbRule(Info) 'info': InfoAction verbPhrase = 'info/infoing';
