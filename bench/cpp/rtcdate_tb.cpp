////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	rtcdate_tb.cpp
//
// Project:	A Wishbone Controlled Real--time Clock Core
//
// Purpose:	To exercise the functionality of the real-time date core.
//		If this program works, (and works properly) it will exit
//		with an exit code of zero if the core works, and a negative
//		number if not.  Further, on the last line it will state either
//		SUCCESS or FAIL.  This program should take no arguments.
//
//		This program makes heavy use of the mktime() and gmtime_r
//		libc calls.  As a result, it really checks that the rtcdate
//		module produces the same dates as the libc library.  Any
//		differences will be cause for immediate test termination and
//		failure.
//
//		As of 17 July, 2015, rtcdate.v passes this test.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Tecnology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory, run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
#include <stdio.h>
#include <assert.h>
#include <time.h>

#include "verilated.h"
#include "Vrtcdate.h"

#include "testb.h"
#include "twoc.h"

typedef	unsigned int	BUSV;	// Wishbone value
class	RTCDATE_TB : public TESTB<Vrtcdate> {
public:
	BUSV	read(void) {
		BUSV	result;

		m_core->i_wb_cyc = 1;
		m_core->i_wb_stb = 1;
		m_core->i_wb_we  = 0;
		m_core->i_ppd    = 0;
		tick();

		m_core->i_wb_cyc = 1;
		m_core->i_wb_stb = 0;
		m_core->i_wb_we  = 0;
		m_core->i_ppd    = 0;
		result = m_core->o_wb_data;

		assert(m_core->o_wb_stall == 0);
		assert(m_core->o_wb_ack   == 1);

		m_core->i_wb_cyc = 0;
		m_core->i_wb_stb = 0;
		m_core->i_wb_we  = 0;
		m_core->i_ppd    = 0;
		tick();

		assert(m_core->o_wb_stall == 0);
		assert(m_core->o_wb_ack   == 0);

		return result;
	}

	void	write(BUSV val) {
		m_core->i_wb_cyc = 1;
		m_core->i_wb_stb = 1;
		m_core->i_wb_we  = 1;
		m_core->i_wb_data = val;
		m_core->i_ppd    = 0;
		tick();

		m_core->i_wb_cyc = 1;
		m_core->i_wb_stb = 0;
		m_core->i_wb_we  = 0;
		m_core->i_ppd    = 0;

		assert(m_core->o_wb_stall == 0);
		assert(m_core->o_wb_ack   == 1);

		m_core->i_wb_cyc = 0;
		m_core->i_wb_stb = 0;
		m_core->i_wb_we  = 0;
		m_core->i_ppd    = 0;
		tick();

		assert(m_core->o_wb_stall == 0);
		assert(m_core->o_wb_ack   == 0);
		assert(m_core->o_wb_data  == val);
	}


	BUSV	encode(time_t when) {
		BUSV	bv;
		struct	tm	tv;
		gmtime_r(&when, &tv);

		int yr = tv.tm_year + 1900;
		bv = yr/1000;		bv <<= 4;
		bv |= (yr/100)%10;	bv <<= 4;
		bv |= (yr/10)%10;	bv <<= 4;
		bv |=  yr%10;		bv <<= 4;

		int mo = tv.tm_mon+1;
		bv |= (mo/10);		bv <<= 4;
		bv |= (mo%10);		bv <<= 4;

		int dy = tv.tm_mday;
		bv |= (dy/10);		bv <<= 4;
		bv |= (dy%10);

		return bv;
	}

	BUSV	set(time_t when) {
		write(encode(when));
	}

	bool	check(time_t when) {
		BUSV	bv = encode(when), rv;
		rv = read();
		if (bv != rv) {
			printf("FAIL: %08x(exp) != %08x (read)\n", bv, rv);
			exit(-2);
		}
		return (bv == rv);
	}

	void	next(void) {
		m_core->i_ppd    = 1;
		m_core->i_wb_cyc = 0;
		m_core->i_wb_stb = 0;

		tick();

		m_core->i_ppd    = 0;
		m_core->i_wb_cyc = 0;
		m_core->i_wb_stb = 0;

	}
};

int main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	RTCDATE_TB *tb = new RTCDATE_TB;
	time_t	start, when, stop;

	struct	tm	tv;
	bzero(&tv, sizeof(struct tm));

	// Set to January 1st, 1970, around noon
	tv.tm_sec  =  0;
	tv.tm_min  =  0;
	tv.tm_hour = 12;
	tv.tm_mday =  1;
	tv.tm_mon  =  0;
	tv.tm_year = 70;
	start = mktime(&tv);
	
	// Set to January 1st, 2400, around noon
	tv.tm_sec  =    0;
	tv.tm_min  =    0;
	tv.tm_hour =   12;
	tv.tm_mday =    1;
	tv.tm_mon  =    0;
	tv.tm_year = 4000-1900;
	stop = mktime(&tv) - 60*60*24;

	tb->set(start);
	printf("Initial date: %08x\n", tb->read());

	for(when=start; when < stop; when+= 60*60*24) {
		assert(tb->check(when));
		tb->next();
	}

	printf("Final date  : %08x\n", tb->read());
	printf("SUCCESS!\n");
	return 0;
}



