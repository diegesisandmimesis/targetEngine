//
// targetEngine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_TARGET_ENGINE

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

#include "bind.h"
#ifndef BIND_H
#error "This module requires the bind module."
#error "https://github.com/diegesisandmimesis/bind"
#error "It should be in the same parent directory as this module.  So if"
#error "targetEngine is in /home/user/tads/targetEngine, then"
#error "bind should be in /home/user/tads/bind ."
#endif // BIND_H

#define TARGET_ENGINE_H
