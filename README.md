# targetEngine

A TADS3/adv3 module providing agendas for low-level NPC target-seeking
behaviors.

## Description

## Table of Contents

[Getting Started](#getting-started)
* [Dependencies](#dependencies)
* [Installing](#install)
* [Compiling and Running Demos](#running)

[Agendas](#agendas)
* [Explore](#explore)
* [MoveTo](#move)
* [Observe](#observe)
* [Obtain](#obtain)
* [Open](#open)
* [ObtainCustom](#obtain-custom)
* [RandomWalk](#random-walk)
* [Search](#search)
* [Unlock](#unlock)

[Examples](#examples)

<a name="getting-started"/></a>
## Getting Started

<a name="dependencies"/></a>
### Dependencies

* TADS 3.1.3
* adv3 3.1.3

  These are the most recent versions of the TADS3 VM and adv3 library.

  Any TADS3 toolkit with these versions should work, although all of the
  [diegesisandmimesis](https://github.com/diegesisandmimesis) modules are
  primarily tested with [frobTADS](https://github.com/realnc/frobtads).

* git

  This module is distributed via github, so you'll need some way of
  cloning a git repo to obtain it.

  The process should be similar on any platform using any tools, but the
  command line examples given below were tested on an Ubuntu linux
  machine.  Other OSes and git tools will have a slightly different usage.

<a name="install"/></a>
### Installing

All of the [diegesisandmimesis](https://github.com/diegesisandmimesis) modules
are designed to be installed and used from a common base install directory.

In this example we'll use ``/home/username/tads`` as the base directory.

* Create the module base directory if it doesn't already exists:

  `mkdir -p /home/username/tads`

* Make it the current directory:

  ``cd /home/username/tads``

* Clone this repo:

  ``git clone https://github.com/diegesisandmimesis/fastPath.git``

After the ``git`` command, the module source will be in
``/home/username/tads/fastPath``.

<a name="running"/></a>
### Compiling and Running Demos

Once the repo has been cloned you should be able to ``cd`` into the
``./demo/`` subdirectory and compile the demonstration/test code that
comes with the module.

All the demos are structured in the expectation that they will be compiled
and run from the ``./demo/`` directory.  Again assuming that the module
is installed in ``/home/username/tads/fastPath/``, enter the directory with:
```
# cd /home/username/tads/fastPath/demo
```
Then make one of the demos, for example:
```
# make -a -f makefile.t3m
```
This should produce a bunch of output from the compiler but no errors.  When
it is done you can run the demo from the same directory with:
```
# frob games/game.t3
```
In general the name of the makefile and the name of the compiled story file
will be the same except for the extensions (``.t3m`` for makefiles and
``.t3`` for story files).

<a name="agendas"/></a>
## Agendas

<a name="explore"/></a>
### Explore

When the ``Explore`` agenda is active the NPC will attempt to visit locations
it hasn't previously seen.

#### Properties

* ``agendaOrder = 180``

#### Usage

```
     // Start alice's Explore agenda.
     alice.explore();
```

#### Depth-First Search

By default exploration will use a depth-first search algorithm.  The basic
logic is:

* At the start of each turn the agenda is active the NPC will evaluate all
exits in its current locaiton.  Any exits leading to locations the NPC has
not seen will be added to a the exploration stack.
* If the NPC's current location has one or more exits to unvisited locations
one will be selected.  The unvisited exits will be sorted by the order given
in ``Direction.allDirections`` and the first one will be selected.
* If there are no unvisted exits in the current location, the unvisited exit
at the top of the exploration stack will be selected.  The ``Explore``
agenda will then add the location the selected exit is in (that is, the
room that contains the exit, not the room the exit leads to) as a target
for the ``MoveTo`` agenda.  This will cause the NPC to path to that location,
after which processing will automatically resume at the second step above.

This process will be iterate through until there is nothing left in the
exploration stack.

#### Breadth-First Search

Alternately a breadth-first search algorithm can be used by setting
``Expore.depthFirst = nil``.  The basic logic for this approach is:

* At the start of each turn the agenda is active the NPC will evaluate all
exits in its current locaiton.  Any exits leading to locations the NPC has
not seen will be added to a the exploration stack.
* The first (oldest) element of the exploration stack is checked.  If
the location of the exit it describes is the current locaiton, that exit
is used.
* If the current location is different, the ``MoveTo`` agenda is used to
path the NPC to the location of the oldest entry in the stack.

#### Initialization

By default the ``Explore`` agenda is self-seeding.  When started, the NPC
looks around their current location and its unexplored exits form the start
of the search pattern.

If there are no unexplored locations adjacent to the starting location, for
example if the NPC has moved previously or if they were initialized "knowing"
adjacent locations, then the default search behavior will fail.

To handle this, if the agenda has a ``nil`` exploration stack after
looking around, the stack will be initialize by:

* Iterating over every ``Room`` instance, ignoring any that the NPC hasn't seen
* For each ``Room`` the NPC has seen, each exit to an unvisited location will
be added to the exploration stack
* A flag will then be set indicating this has been done.  The process will not
be repeated unless the flag is cleared.

<a name="move"/></a>
### MoveTo

The ``MoveTo`` agenda paths the NPC to a given location.

#### Properties

* ``agendaOrder = 170``

#### Usage

Move to a single location.

```
     // Move alice to room someRoom
     alice.move(someRoom);
```

Move to a series of locations.
```
     // Alice will move to room1.  Upon reaching room1, they will immediately
     // start moving toward room2.  Once there, they will move to room3.
     // NOTE:  targets will be removed from the list upon entering even if
     //     it is not the current active target.  So for example if alice is
     //     moving to room1 but pathfinding happens to take her through
     //     room3, this will cause room3 to be removed from the list.
     alice.move(room1);
     alice.move(room2);
     alice.move(room3);
```


<a name="observe"/></a>
### Observe

The ``Observe`` agenda tells the NPC to examine something when they
encounter it.

#### Properties

* ``agendaOrder = 110``

#### Usage

```
     // Tell alice to examine bob if and when she sees him
     alice.observe(bob);
```
<a name="obtain"/></a>
### Obtain

The ``Obtain`` agenda tells the NPC to attempt to >TAKE something if and
when they encounter it.

NOTE:  This does not cause the NPC to actively seek out the object in question.
    This by itself will not cause the NPC to move or take any other actions
    other than attempting to take the object when seen.

#### Properties

* ``agendaOrder = 130``

#### Usage

Take a single object.
```
     // Tell alice to take the object pebble when seen
     alice.obtain(pebble);
```
Take several objects.
```
     // Tell alice to take the fixings for a BLT, if and when she happens
     // to see them.  The order is not significant, although if multiple
     // targets are seen simultaneously the one added first will be the
     // first one taken.
     alice.obtain(bacon);
     alice.obtain(lettuce);
     alice.obtain(tomato);
```

<a name="obtain-custom"/></a>
### ObtainCustom

The ``ObtainCustom`` agenda is like the ``Custom`` agenda, but the target
is a test function.  The agenda iterates over all objects in scope, calling
the test function with each object as its argument.  Objects for which
the function returns ``true`` will be considered valid targets.

#### Properties

* ``agendaOrder = 135``

#### Usage

With an inline function:
```
    // Tell alice to obtain all instances of the Pebble class:
    alice.obtainCustom({ x: x.ofKind(Pebble) });
```

<a name="open"/></a>
### Open

The ``Open`` agenda tells the NPC to attempt to open a given container.

This is used under the hood by the ``Search`` agenda, so you don't have
to manually invoke the ``Open`` agenda if the NPC is already searching.

#### Properties

* ``agendaOrder = 150``

#### Usage

Basic usage:
```
    // Tell alice to open the box
    alice.open(box);
```

<a name="random-walk"/></a>
### RandomWalk

The ``RandomWalk`` agenda tells the NPC to wander randomly for a set number
of turns.

#### Properties

* ``agendaOrder = 199``

#### Usage

```
     // Tell alice to wander aimlessly for 99 turns
     alice.randomWalk(99);
```

<a name="search"/></a>
### Search

The ``Search`` agenda tells the NPC to investigate searchable containers.

The takes care of automagically unlocking and opening containers, if possible,
via the ``Unlock`` and ``Open`` agendas.

#### Properties

* ``agendaOrder = 160``

#### Usage

Basic usage:
```
    // Tells alice to start searching.  The argument 'foo' is just an ID
    // for this search invokation.
    alice.search('foo');
```

Multiple concurrent searche
```
    // Start one search
    alice.search('foo');

    // Start a different search
    alice.search('bar');

    // Stop the first search.
    alice.clearSearch('foo');

    // Stop the second search
    alice.clearSearch('bar');
```
Having multiple concurrent searches active at once doesn't accomplish anything
in and of itself.  This usage is just to make it easy to have separate
tasks request the search behavior without having to keep track of whether or
not anything else is doing the same thing.

<a name="unlock"/></a>
### Unlock

The ``Unlock`` agenda tells the NPC to attempt to unlock any locked containers
it encounters.

The is handled automagically by the ``Search`` agenda, so if you want to
have an NPC take care of locks by themselves you probably want to use
``.search()`` instead.

The agenda keeps track of which keys have been attempted on which locks,
and will only attempt to unlock something if:

* the lock is in the target list
* the NPC has a key which is plausible for the lock (evaluated using
``keyIsPlausible()`` on the locked object)
* the plausible key has not been tried on that lock

#### Properties

* ``agendaOrder = 140``

#### Usage

Basic usage:
```
    // Tells alice to try to unlock the box
    alice.unlock(box)
```
