#charset "us-ascii"
//
// alice.t
//
//	Definition of the Alice NPC used in the demos.
//
#include <adv3.h>
#include <en_us.h>

#include "targetEngine.h"

alice: Person, Alert 'Alice' 'Alice' @aliceRoom
	"She looks like the first person you'd turn to in a problem. "
	isHer = true
	isProperName = true

	// This tells the module to add a TargetEngine to alice.
	useTargetEngine = true

	// Some utility methods used by callbacks in some demos.
	_status(v) { return('status:  ' + (v ? 'success' : 'failed')); }
	_label(v) { return('target:  ' + (v ? v.name : 'unknown')); }
	_results(lbl, obj, results) {
		"\n\^<<name>> <<lbl>>:\n\t<<_status(results)>>
			\n\t<<_label(obj)>>\n ";
	}
;
// A very low-priority agenda.
// It being executed just demonstrates that none of the higher-priority
// agendas are still active.
+AgendaItem
	agendaOrder = 999
	initiallyActive = true
	isReady = true
	invokeItem() {
		"Alice idles. ";
	}
;
+InConversationState
	specialDesc = "Alice is here, talking with
		<<alice.lastInterlocutor.theName>>. "
	stateDesc = "She's watching you as you talk. "
;
++ConversationReadyState
	isInitState = true
	specialDesc = "Alice is here in the conversation ready state. "
	stateDesc = "Alice is in ConversationReadyState. "
;
+++TopicGroupFor @gPlayerChar;
++++ActorHelloTopic, StopEventList
	[ 'This is Alice\'s hello topic for the player. ' ]
;
+++HelloTopic, StopEventList
	[
		'This is the first default hello topic.',
		'This is the second default hello topic.',
		'This is the third default hello topic.'
	]
;
+++ByeTopic, StopEventList
	[ 'This is the bye topic.' ]
;
+++ImpByeTopic, StopEventList
	[ 'This is the implicit bye topic. ' ]
;
