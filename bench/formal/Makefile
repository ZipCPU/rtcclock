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

$(DATE).smt2: $(RTL)/$(DATE).v
	yosys -ql $(DATE).yslog -s $(DATE).ys

$(RTCCK).smt2: $(RTL)/$(RTCCK).v
	yosys -ql $(RTCCK).yslog -s $(RTCCK).ys

$(RTCLT).smt2: $(RTL)/$(RTCLT).v
	yosys -ql $(RTCLT).yslog -s $(RTCLT).ys

$(RTCGPS).smt2: $(RTL)/$(RTCGPS).v $(RTL)/$(TIMER).v $(RTL)/$(BARE).v
$(RTCGPS).smt2: $(RTL)/$(ALARM).v $(RTL)/$(SWATCH).v
	yosys -ql $(RTCGPS).yslog -s $(RTCGPS).ys

$(TIMER).smt2: $(RTL)/$(TIMER).v
	yosys -ql $(TIMER).yslog -s $(TIMER).ys

$(SWATCH).smt2: $(RTL)/$(SWATCH).v
	yosys -ql $(SWATCH).yslog -s $(SWATCH).ys

$(ALARM).smt2: $(RTL)/$(ALARM).v
	yosys -ql $(ALARM).yslog -s $(ALARM).ys

$(BARE).smt2: $(RTL)/$(BARE).v
	yosys -ql $(BARE).yslog -s $(BARE).ys

$(DATE) : $(DATE).check
$(DATE).check: $(DATE).smt2
	@rm -f $(DATE).check
	$(SMTBMC)    $(BMCARGS) -t 15 --dump-vcd $(DATE).vcd $(DATE).smt2
	$(SMTBMC)    $(INDARGS) -t 15 --dump-vcd $(DATE).vcd $(DATE).smt2
	touch $@


$(RTCCK) : $(RTCCK).check
$(RTCCK).check: $(RTCCK).smt2
	@rm -f $(RTCCK).check
	$(SMTBMC) $(BMCARGS) -t 40 --dump-vcd $(RTCCK).vcd $(RTCCK).smt2
	$(SMTBMC) $(INDARGS) -t 38 --dump-vcd $(RTCCK).vcd $(RTCCK).smt2
	touch $@

$(RTCLT) : $(RTCLT).check
$(RTCLT).check: $(RTCLT).smt2
	@rm -f $(RTCLT).check
	$(SMTBMC) $(BMCARGS) -t 12 --dump-vcd $(RTCLT).vcd $(RTCLT).smt2
	$(SMTBMC) $(INDARGS) -t 12 --dump-vcd $(RTCLT).vcd $(RTCLT).smt2
	touch $@


$(RTCGPS) : $(RTCGPS).check
$(RTCGPS).check: $(RTCGPS).smt2
	@rm -f $(RTCGPS).check
	$(SMTBMC)    $(BMCARGS) -t 10 --dump-vcd $(RTCGPS).vcd $(RTCGPS).smt2
	$(SMTBMC)    $(INDARGS) -t 10 --dump-vcd $(RTCGPS).vcd $(RTCGPS).smt2
	touch $@

$(TIMER) : $(TIMER).check
$(TIMER).check: $(TIMER).smt2
	@rm -f $(TIMER).check
	$(SMTBMC)  $(BMCARGS) -t 48 --dump-vcd $(TIMER).vcd $(TIMER).smt2
	$(SMTBMC)  $(INDARGS) -t 48 --dump-vcd $(TIMER).vcd $(TIMER).smt2
	$(SMTBMC) -c $(SOLVER) -t 48 --dump-vcd $(TIMER)%.vcd $(TIMER).smt2
	touch $@

$(SWATCH) : $(SWATCH).check
$(SWATCH).check: $(SWATCH).smt2
	@rm -f $(SWATCH).check
	$(SMTBMC)  $(BMCARGS) -t 48 --dump-vcd $(SWATCH).vcd $(SWATCH).smt2
	$(SMTBMC)  $(INDARGS) -t 48 --dump-vcd $(SWATCH).vcd $(SWATCH).smt2
	$(SMTBMC) -c $(SOLVER) -t 48 --dump-vcd $(SWATCH).vcd $(SWATCH).smt2
	touch $@

$(ALARM) : $(ALARM).check
$(ALARM).check: $(ALARM).smt2
	@rm -f $(ALARM).check
	$(SMTBMC)   $(BMCARGS) -t 48 --dump-vcd $(ALARM).vcd $(ALARM).smt2
	$(SMTBMC)   $(INDARGS) -t 48 --dump-vcd $(ALARM).vcd $(ALARM).smt2
	$(SMTBMC) -c $(SOLVER) -t 48 --dump-vcd $(ALARM).vcd $(ALARM).smt2
	touch $@

$(BARE) : $(BARE).check
$(BARE).check: $(BARE).smt2
	@rm -f $(BARE).check
	$(SMTBMC)   $(BMCARGS) -t 48 --dump-vcd $(BARE).vcd $(BARE).smt2
	$(SMTBMC)   $(INDARGS) -t 48 --dump-vcd $(BARE).vcd $(BARE).smt2
	touch $@

.PHONY: clean
clean:
	rm -f $(DATE).smt2    $(DATE)*.vcd    $(DATE).yslog
	rm -f $(RTCCK).smt2   $(RTCCK)*.vcd   $(RTCCK).yslog
	rm -f $(RTCLT).smt2   $(RTCLT)*.vcd   $(RTCLT).yslog
	rm -f $(RTCGPS).smt2  $(RTCGPS)*.vcd  $(RTCGPS).yslog
	rm -f $(TIMER).smt2   $(TIMER)*.vcd   $(TIMER).yslog
	rm -f $(SWATCH).smt2  $(SWATCH)*.vcd  $(SWATCH).yslog
	rm -f $(ALARM).smt2   $(ALARM)*.vcd   $(ALARM).yslog
	rm -f $(BARE).smt2    $(BARE)*.vcd    $(BARE).yslog
	rm -f *.check
