#charset "us-ascii"
//
// targetEngineFind.t
//
//	Agenda for finding an object in an unknown location.
//
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

class Find: TargetEngineAgendaItem
	syslogID = 'Find'

	agendaOrder = 175
;
