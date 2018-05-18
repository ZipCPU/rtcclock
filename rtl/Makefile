############################################################################/
##
## Filename: 	Makefile
##
## Project:	A Wishbone Controlled Real--time Clock Core
##
## Purpose:	This is the Makefile to build the verilator test bench code
##		from the RTL code.  The TB code in the bench/cpp directory
##		will then reference the library results from this file.
##		To build the verilator libraries, just type 'make' on a line
##		by itself.
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Tecnology, LLC
##
##########################################################################/
##
## Copyright (C) 2015,2018, Gisselquist Technology, LLC
##
## This program is free software (firmware): you can redistribute it and/or
## modify it under the terms of  the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
## target there if the PDF file isn't present.)  If not, see
## <http://www.gnu.org/licenses/> for a copy.
##
## License:	GPL, v3, as defined and found on www.gnu.org,
##		http://www.gnu.org/licenses/gpl.html
##
##
##########################################################################/
##
##
# This is really simple ...
all: rtcdate rtcclock rtclight rtcgps
OBJDR := ./obj_dir
BENCHD := ../bench/cpp
VERILATOR := verilator
VFLAGS := -Wall -trace -cc

.PHONY: rtcclock
rtcclock: $(OBJDR)/Vrtcclock__ALL.a
$(OBJDR)/Vrtcclock.cpp $(OBJDR)/Vrtcclock.h: rtcclock.v
	$(VERILATOR) $(VFLAGS) rtcclock.v
$(OBJDR)/Vrtcclock__ALL.a: $(OBJDR)/Vrtcclock.h
$(OBJDR)/Vrtcclock__ALL.a: $(OBJDR)/Vrtcclock.cpp
	cd $(OBJDR)/; make -f Vrtcclock.mk

.PHONY: rtcdate
rtcdate: $(OBJDR)/Vrtcdate__ALL.a
$(OBJDR)/Vrtcdate.cpp $(OBJDR)/Vrtcdate.h: rtcdate.v
	$(VERILATOR) $(VFLAGS) rtcdate.v
$(OBJDR)/Vrtcdate__ALL.a: $(OBJDR)/Vrtcdate.h
$(OBJDR)/Vrtcdate__ALL.a: $(OBJDR)/Vrtcdate.cpp
	cd $(OBJDR)/; make -f Vrtcdate.mk

.PHONY: rtclight
rtclight: $(OBJDR)/Vrtclight__ALL.a
$(OBJDR)/Vrtclight.cpp $(OBJDR)/Vrtclight.h: rtclight.v
	$(VERILATOR) $(VFLAGS) rtclight.v
$(OBJDR)/Vrtclight__ALL.a: $(OBJDR)/Vrtclight.h
$(OBJDR)/Vrtclight__ALL.a: $(OBJDR)/Vrtclight.cpp
	cd $(OBJDR)/; make -f Vrtclight.mk

.PHONY: rtcgps
rtcgps: $(OBJDR)/Vrtcgps__ALL.a
$(OBJDR)/Vrtcgps.cpp $(OBJDR)/Vrtcgps.h: rtcgps.v
	$(VERILATOR) $(VFLAGS) rtcgps.v
$(OBJDR)/Vrtcgps__ALL.a: $(OBJDR)/Vrtcgps.h
$(OBJDR)/Vrtcgps__ALL.a: $(OBJDR)/Vrtcgps.cpp
	cd $(OBJDR)/; make -f Vrtcgps.mk

.PHONY: clean
clean:
	rm -rf $(OBJDR)

