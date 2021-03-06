Controller test
===============
This NES program detects which console model you have and which
controllers are connected by reading the controller ports.

Start the program, and it'll briefly display whether you have an
NES-001, NES-101, or Family Computer while scanning for controllers.
It looks for D0 controllers (Controller, Four Score, Mouse) on both
D0 and D1 so that they'll work on the Famicom through a pin adapter
to its DA15 expansion port.

Once it completes, it displays names and pictures of connected
controllers.  From here, press a controller's primary fire button to
begin an input test.  (This is A on NES controllers, B on the Super
NES Controller, the left mouse button, the Zapper's trigger, or 4 on
a Power Pad side B.)

Detection and input testing work for these:

* NES Controller (original NES-004 and dogbone NES-039)
* Famicom hardwired controllers (1P and 2P with microphone)
* NES Power Pad (NES-028)
* NES Four Score (NES-034)
* Super NES Controller (SNS-005) through pin adapter
* Zapper (NES-005)
* Arkanoid Controller
* Super NES Mouse (SNS-016) through pin adapter

Some flash cart menus cannot be navigated with anything but an NES
or Super NES controller.  You can work around this by starting the
program, hot-swapping to the desired controllers, and then pressing
the Reset button on the Control Deck to rescan the ports.

Press Reset before the scan finishes to display low-level data about
which lines are always off, always on, serial, or not connected
at all.  See docs/methodology.md for how it works under the hood.

Limits
------
The PowerPak by retrousb.com has pull-up resistors on the data bus
that may interfere with console type detection.  The EverDrive,
Infinite NES Lives boards, and donor carts do not have this problem.

The NES dogbone controller and Famicom hardwired controller behave
exactly the same as the original NES controller.  So it guesses that
the controller used is the one that the console shipped with.  Nor
can it distinguish the original Famicom (HVC-001), with one hardwired
controller with Select and Start buttons and one hardwired controller
with a microphone, from the AV Famicom (HVC-101) with two controllers
plugged in.  If it mis-detects an AV Famicom as an original Famicom,
press A on controller 2 to start the test, then Start to switch from
the mic controller to the standard controller.

Versions of the Power Pad and Arkanoid Controller for the Famicom
use a different protocol that is not yet supported, though the NES
versions of those work through a pin adapter that passes D3 and D4
to the DA15 port.  Nor does it support U-Force, Power Glove, Miracle
Piano, or other hen's teeth.

Rescanning requires Reset primarily because hot-swapping can
occasionally cause a power sag that freezes the CPU.

Contact
-------
Let me know what you get.  My nick on the [EFnet] IRC network is
pino_p and I'm often seen in the #nesdev channel.  There is also a
topic for this test on NESdev BBS, titled [Riding the open bus].

[EFnet]: http://www.efnet.org/
[Riding the open bus]: https://forums.nesdev.com/viewtopic.php?f=2&t=12549

Legal
-----
The test program is distributed under the following terms:

    Copyright 2016 Damian Yerrick
    Copying and distribution of this file, with or without
    modification, are permitted in any medium without royalty
    provided the copyright notice and this notice are preserved.
    This file is offered as-is, without any warranty.
