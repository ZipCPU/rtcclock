################################################################################
##
## Filename:	Makefile
##
## Project:	A Wishbone Controlled Real--time Clock Core
##
## Purpose:	To direct the formal verification of the real time
##		clock core, its brethren and its children.
##
## Targets:	The default target, all, tests all of the components tested
##		within this module.  Each tested top-level component will
##	result in a <module>.check placed in this directory.  Builds that fail
##	will leave no such file(s) behind.
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
##
## Copyright (C) 2017-2018, Gisselquist Technology, LLC
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
################################################################################
##
##
TESTS:=rtcdate rtctimer rtcstopwatch rtcalarm rtcbare rtcgps rtclight # rtcclock
.PHONY: $(TESTS)
all: $(TESTS)
RTL := ../../rtl

SMTBMC  := yosys-smtbmc
# SOLVER  := -s z3
SOLVER  := -s yices
# SOLVER  := -s boolector
BMCARGS := --presat $(SOLVER)
INDARGS := $(SOLVER) -i

DATE     := rtcdate
RTCCK    := rtcclock
RTCLT    := rtclight
RTCGPS   := rtcgps
TIMER    := rtctimer
SWATCH   := rtcstopwatch
ALARM    := rtcalarm
BARE     := rtcbare

$(DATE) : $(DATE)_prf/PASS
$(DATE)_prf/PASS: $(DATE).sby $(RTL)/$(DATE).v
	sby -f $(DATE).sby prf

$(RTCCK) : $(RTCCK).check
$(RTCCK).check: $(RTCCK).smt2
	@rm -f $(RTCCK).check
	$(SMTBMC) $(BMCARGS) -t 40 --dump-vcd $(RTCCK).vcd $(RTCCK).smt2
	$(SMTBMC) $(INDARGS) -t 38 --dump-vcd $(RTCCK).vcd $(RTCCK).smt2
	touch $@

$(RTCLT) : $(RTCLT)_prf/PASS
$(RTCLT)_prf/PASS: $(RTCLT).sby $(RTL)/$(RTCLT).v
	sby -f $(RTCLT).sby prf

$(RTCGPS) : $(RTCGPS)_prf/PASS
$(RTCGPS)_prf/PASS: $(RTCGPS).sby $(RTL)/$(RTCGPS).v
	sby -f $(RTCGPS).sby prf

$(TIMER) : $(TIMER)_checkinp $(TIMER)_validated
$(TIMER)_checkinp: $(TIMER).sby $(RTL)/$(TIMER).v
	sby -f $(TIMER).sby checkinp
$(TIMER)_validated: $(TIMER).sby $(RTL)/$(TIMER).v
	sby -f $(TIMER).sby validated

$(SWATCH) : $(SWATCH)_prf/PASS
$(SWATCH)_prf/PASS: $(SWATCH).sby $(RTL)/$(SWATCH).v
	sby -f $(SWATCH).sby prf

$(ALARM) : $(ALARM)_checkinp/PASS $(ALARM)_validated/PASS
$(ALARM)_checkinp/PASS: $(RTL)/$(ALARM).v $(ALARM).sby
	sby -f $(ALARM).sby checkinp
$(ALARM)_validated/PASS: $(RTL)/$(ALARM).v $(ALARM).sby
	sby -f $(ALARM).sby validated

$(BARE) : $(BARE)_checkinp/PASS $(BARE)_validated/PASS
$(BARE)_checkinp/PASS: $(RTL)/$(BARE).v $(BARE).sby
	sby -f $(BARE).sby checkinp
$(BARE)_validated/PASS: $(RTL)/$(BARE).v $(BARE).sby
	sby -f $(BARE).sby validated

.PHONY: clean
clean:
	rm -rf $(DATE)_*/
	rm -f  $(RTCCK).smt2   $(RTCCK)*.vcd   $(RTCCK).yslog
	rm -rf $(RTCLT)_*/
	rm -rf $(RTCGPS)_*/
	rm -rf $(TIMER)_*/
	rm -rf $(SWATCH)_*/
	rm -rf $(ALARM)_*/
	rm -rf $(BARE)_*/
	rm -f *.check
