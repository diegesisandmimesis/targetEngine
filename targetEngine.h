//
// targetEngine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_TARGET_ENGINE

#include "adv3Utils.h"
#ifndef ADV3_UTILS_H
#error "This module requires the adv3Utils module."
#error "https://github.com/diegesisandmimesis/adv3Utils"
#error "It should be in the same parent directory as this module.  So if"
#error "targetEngine is in /home/user/tads/targetEngine, then"
#error "adv3Utils should be in /home/user/tads/adv3Utils ."
#endif // ADV3_UTILS_H

#include "syslog.h"
#ifndef SYSLOG_H
#error "This module requires the syslog module."
#error "https://github.com/diegesisandmimesis/syslog"
#error "It should be in the same parent directory as this module.  So if"
#error "targetEngine is in /home/user/tads/targetEngine, then"
#error "syslog should be in /home/user/tads/syslog ."
#endif // SYSLOG_H

#include "outputToggle.h"
#ifndef OUTPUT_TOGGLE_H
#error "This module requires the outputToggle module."
#error "https://github.com/diegesisandmimesis/outputToggle"
#error "It should be in the same parent directory as this module.  So if"
#error "targetEngine is in /home/user/tads/targetEngine, then"
#error "outputToggle should be in /home/user/tads/outputToggle ."
#endif // OUTPUT_TOGGLE_H

#include "thirdPersonAction.h"
#ifndef THIRD_PERSON_ACTION_H
#error "This module requires the thirdPersonAction module."
#error "https://github.com/diegesisandmimesis/thirdPersonAction"
#error "It should be in the same parent directory as this module.  So if"
#error "targetEngine is in /home/user/tads/targetEngine, then"
#error "thirdPersonAction should be in /home/user/tads/thirdPersonAction ."
#endif // THIRD_PERSON_ACTION_H

#include "execCommandAs.h"
#ifndef EXEC_COMMAND_AS_H
#error "This module requires the execCommandAs module."
#error "https://github.com/diegesisandmimesis/execCommandAs"
#error "It should be in the same parent directory as this module.  So if"
#error "targetEngine is in /home/user/tads/targetEngine, then"
#error "execCommandAs should be in /home/user/tads/execCommandAs ."
#endif // EXEC_COMMAND_AS_H

#include "dataTypes.h"
#ifndef DATA_TYPES_H
#error "This module requires the dataTypes module."
#error "https://github.com/diegesisandmimesis/dataTypes"
#error "It should be in the same parent directory as this module.  So if"
#error "targetEngine is in /home/user/tads/targetEngine, then"
#error "dataTypes should be in /home/user/tads/dataTypes ."
#endif // DATA_TYPES_H

#define isUnvisitedExit(obj) isType(obj, UnvisitedExit)
#define isTargetEngineAgenda(obj) isType(obj, TargetEngineAgenda)
#define isTargetEngineTarget(obj) isType(obj, TargetEngineTarget)

#define targetMethods(lc, uc) \
	lc##(v?, cb?) { return(_setTarget(v, cb, lc##AgendaClass)); } \
	clear##uc##(v) { return(_clearTargetObj(v, lc##AgendaClass)); }

#define actorTargetMethods(lc, uc) \
	lc##(v?, cb?) \
		{ return(targetEngine ? targetEngine.##lc##(v, cb) : nil); } \
	clear##uc##(v) \
		{ return(targetEngine ? targetEngine.clear##uc##(v) : nil); }

#define targetEngineMethods(lc, uc) \
modify TargetEngine \
	lc##AgendaClass = ##uc\
	_agendaList = (nilToList(inherited()) + [ lc##AgendaClass ]) \
	targetMethods(lc, uc) \
; \
modify Actor \
	actorTargetMethods(lc, uc) \
;


#define TARGET_ENGINE_H
