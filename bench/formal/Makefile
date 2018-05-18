################################################################################
##
## Filename:	Makefile
##
## Project:	A Wishbone Controlled Real--time Clock Core
##
## Purpose:	To direct the formal verification of the real time
##		clock core.
##
## Targets:	The default target, all, tests all of the components within
##		this module.
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
TESTS := rtcdate # rtcclock rtclight rtcgps
.PHONY: $(TESTS)
all: $(TESTS)
RTL := ../../rtl

SMTBMC  := yosys-smtbmc
# SOLVER  := -s z3
SOLVER  := -s yices
# SOLVER  := -s boolector
BMCARGS := --presat $(SOLVER) --unroll
# BMCARGS := $(SOLVER) --unroll
# BMCARGS := $(SOLVER)
INDARGS := $(SOLVER) -i

DATE=rtcdate
DATEBMC=$(DATE)_bmc
DATEIND=$(DATE)_ind

RTCCK    := rtcclock
RTCLT    := rtclight
RTCGPS   := rtcgps

$(DATE).smt2: $(RTL)/$(DATE).v
	yosys -ql $(DATE).yslog -s $(DATE).ys

$(RTCCK).smt2: $(RTL)/$(RTCCK).v
	yosys -ql $(RTCCK).yslog -s $(RTCCK).ys

$(RTCLT).smt2: $(RTL)/$(RTCLT).v
	yosys -ql $(RTCLT).yslog -s $(RTCLT).ys

$(RTCGPS).smt2: $(RTL)/$(RTCGPS).v
	yosys -ql $(RTCGPS).yslog -s $(RTCGPS).ys

#$(PFONE).smt2: $(RTL)/$(PFONE).v
#	yosys -ql $(PFONE).yslog -s $(PFONE).ys

$(DATE) : $(DATE).check
$(DATE).check: $(DATE).smt2
	@rm -f $(DATE).check
	$(SMTBMC)    $(BMCARGS) -t 60 --dump-vcd $(DATE).vcd $(DATE).smt2
	$(SMTBMC)    $(INDARGS) -t 58 --dump-vcd $(DATE).vcd $(DATE).smt2
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
	$(SMTBMC) $(BMCARGS) -t 80 --dump-vcd $(RTCLT).vcd $(RTCLT).smt2
	$(SMTBMC) $(INDARGS) -t 76 --dump-vcd $(RTCLT).vcd $(RTCLT).smt2
	touch $@


$(RTCGPS) : $(RTCGPS).check
$(RTCGPS).check: $(RTCGPS).smt2
	@rm -f $(RTCGPS).check
	$(SMTBMC)    $(BMCARGS) -t 48 --dump-vcd $(RTCGPS).vcd $(RTCGPS).smt2
	$(SMTBMC)    $(INDARGS) -t 48 --dump-vcd $(RTCGPS).vcd $(RTCGPS).smt2
	touch $@

.PHONY: clean
clean:
	rm -f $(DATE).smt2   $(DATE)*.vcd   $(DATE).yslog
	rm -f $(RTCCK).smt2   $(RTCCK)*.vcd   $(RTCCK).yslog
	rm -f $(RTCLT).smt2 $(RTCLT)*.vcd $(RTCLT).yslog
	rm -f $(RTCGPS).smt2   $(RTCGPS)*.vcd   $(RTCGPS).yslog
	rm -f *.check
