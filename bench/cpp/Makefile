################################################################################
##
## Filename: 	Makefile
## {{{
## Project:	A Wishbone Controlled Real--time Clock Core
##
## Purpose:	This programs the build process for the test benches
##		associated with the real--time clock (and date) core(s).
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Tecnology, LLC
##
################################################################################
## }}}
## Copyright (C) 2015-2021, Gisselquist Technology, LLC
## {{{
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
## with this program.  (It's in the $(ROOT)/doc directory, run make with no
## target there if the PDF file isn't present.)  If not, see
## <http://www.gnu.org/licenses/> for a copy.
## }}}
## License:	GPL, v3, as defined and found on www.gnu.org,
## {{{
##		http://www.gnu.org/licenses/gpl.html
##
##########################################################################/
## }}}
all: rtcdate_tb 
# all: rtcclock_tb		# rtcclock_tb is not yet written ...
# all: test
CXX	:= g++
FLAGS	:= -Wall -Og -g
OBJDIR  := obj-pc
RTLD	:= ../../rtl
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VROOT   := $(VERILATOR_ROOT)
INCS	:= -I$(RTLD)/obj_dir/ -I$(VROOT)/include
VOBJDR	:= $(RTLD)/obj_dir
SYSVDR	:= $(VROOT)/include
VSRC	:= verilated.cpp verilated_vcd_c.cpp
VLIB	:= $(addprefix $(OBJDIR)/,$(subst .cpp,.o,$(VSRC)))
VINC := -I$(VROOT)/include -I$(VOBJDR)/
CLKSRCS:= rtcclock_tb.cpp
CLKOBJ := $(subst .cpp,.o,$(CLKSRCS))
CLKOBJS:= $(addprefix $(OBJDIR)/,$(CLKOBJ)) $(VLIB)
CLKGLB:= $(VOBJDR)/Vrtcgps__ALL.a
CKGSRCS:= rtcgps_tb.cpp
CKGOBJ := $(subst .cpp,.o,$(CKGSRCS))
CKGOBJS:= $(addprefix $(OBJDIR)/,$(CKGOBJ)) $(VLIB)
CKGLB:= $(VOBJDR)/Vrtcgps__ALL.a
DATSRCS:= rtcdate_tb.cpp
DATOBJ := $(subst .cpp,.o,$(DATSRCS))
DATOBJS:= $(addprefix $(OBJDIR)/,$(DATOBJ)) $(VLIB)
DATLB:= $(VOBJDR)/Vrtcdate__ALL.a
SOURCES := $(DATSRCS)

$(OBJDIR)/%.o: %.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@

$(OBJDIR)/%.o: $(SYSVDR)/%.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@

rtcclock_tb: $(CLKOBJS) $(CLKLB)
	$(CXX) $(FLAGS) $(INCS) $^ -o $@

rtcdate_tb: $(DATOBJS) $(DATLB)
	$(CXX) $(FLAGS) $(INCS) $^ -o $@

.PHONY: test
test: rtcclock_tb rtcdate_tb
	./rtcclock_tb
	./rtcdate_tb

#
define	mk-objdir
	@bash -c "if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi"
endef

#
# The "tags" target
## {{{
tags:	$(SOURCES) $(HEADERS)
	@echo "Generating tags"
	@ctags $(SOURCES) $(HEADERS)
## }}}

.PHONY: clean
## {{{
clean:
	rm -f rtcclock_tb rtcdate_tb
	rm -rf $(OBJDIR)/
## }}}

## Depends
## {{{
# The "depends" target, to know what files things depend upon.  The depends
# file itself is kept in $(OBJDIR)/depends.txt
#
define	build-depends
	$(mk-objdir)
	@echo "Building dependency file"
	@$(CXX) $(CFLAGS) $(INCS) -MM $(SOURCES) > $(OBJDIR)/xdepends.txt
	@sed -e 's/^.*.o: /$(OBJDIR)\/&/' < $(OBJDIR)/xdepends.txt > $(OBJDIR)/depends.txt
	@rm $(OBJDIR)/xdepends.txt
endef

.PHONY: depends
## {{{
depends: tags
	$(build-depends)
## }}}

$(OBJDIR)/depends.txt: depends

-include $(OBJDIR)/depends.txt
## }}}
