# Real Time Clock Core

Every FPGA project needs to start with a very simple core.  Then, working from
simplicity, more and more complex cores can be built until an eventual
application comes from all the tiny details.

This real time clock began with one such simple core.  All of the pieces to
this clock are simple.  Nothing is inherently complex.  However, placing this
clock into a larger FPGA structure requires a Wishbone bus, and being able
to command and control an FPGA over a wishbone bus is an achievement in and
of itself.  Further, the clock produces outputs that can be used to strobe
an interrupt line.  Reading and processing that interrupt line requires
a whole 'nother bit of logic and the ability to capture, recognize, and 
respond to interrupts.  Hence, once you get a simple clock working, you have
a lot working.

Included in this repository are several basic cores which can be
used for this purpose:

- rtcclock: the original RTC Clock module.  This was originally built for a Basys-3 board, and so it also has outputs suitable for commanding LEDs and a seven segment display.  
- rtclight: Just the basic RTC, with no LEDs or seven segment display output wires.
- rtcgps: A real-time clock which can be used together with a cleaned-up GPS PPS, to keep the clock accurate at a subsecond level to the top of the second.  Further work is required to get the clock to the correct second, but this will hold it to the correct subsecond interval.
