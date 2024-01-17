////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	rtcclock.v
// {{{
// Project:	A Wishbone Controlled Real--time Clock Core
//
// Purpose:	Implement a real time clock, including alarm, count--down
//		timer, stopwatch, variable time frequency, and more.
//
//	Designed originally with Digilent's Basys3 in mind.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
// }}}
// Copyright (C) 2015-2024, Gisselquist Technology, LLC
// {{{
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
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
// }}}
// License:	GPL, v3, as defined and found on www.gnu.org,
// {{{
//		http://www.gnu.org/licenses/gpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
// }}}
module	rtcclock #(
		// {{{
		//2af31e = 2^48 / 100e6 MHz
		parameter	DEFAULT_SPEED = 32'd2814750, // == 2^48/ClkSpd
		parameter [0:0]	OPT_TIMER     = 1'b1,
				OPT_STOPWATCH = 1'b1,
				OPT_ALARM     = 1'b1
		// }}}
	) (
		// {{{
		input	wire		i_clk, i_reset,
		// Wishbone interface
		input	wire		i_wb_cyc, i_wb_stb, i_wb_we,
		input	wire	[2:0]	i_wb_addr,
		input	wire	[31:0]	i_wb_data,
		input	wire	[3:0]	i_wb_sel,
		//	o_wb_ack, o_wb_stb, o_wb_data, // no reads here
		// // Button inputs
		// input		i_btn,
		// Output registers
		output	reg	[31:0]	o_data, // muxd based on i_wb_addr
		// Output controls
		output	reg	[31:0]	o_sseg,
		output	wire	[15:0]	o_led,
		output	wire		o_interrupt,
		// A once-per-day strobe on the last clock of the day
					o_ppd,
		// Time setting hack(s)
		input	wire		i_hack
		// }}}
	);

	// Signal declarations
	// {{{
	reg	[31:0]	ckspeed;
	reg	[1:0]	clock_display;

	wire	[31:0]	timer_data, alarm_data;
	wire	[30:0]	stopwatch_data;
	wire	[21:0]	clock_data;
	wire		sp_sel;
	reg		ck_wr, tm_wr, al_wr;

	wire		tm_int, al_int;

	reg	[25:0]	wr_data;
	reg	[2:0]	wr_valid;
	reg		wr_zero;
	reg		ck_carry;
	reg	[39:0]	ck_counter;
	wire		ck_pps, ck_ppd;
	reg		ck_prepps, ck_ppm;
	reg	[7:0]	ck_sub;
	reg [21:0]	ck_last_clock;
	wire		sw_running;
	reg		r_hack_carry;
	reg	[29:0]	hack_time;
	reg	[39:0]	hack_counter;
	wire		tm_alarm;
	reg	[15:0]	h_sseg;
	reg	[3:1]	dmask;
	wire	[31:0]	w_sseg;
	wire		al_tripped;
	reg	[17:0]	ledreg;
	// }}}

	assign	sp_sel = ((i_wb_stb)&&(i_wb_addr[2:0]==3'b100));

	// ck_wr, tm_wr, al_wr
	// {{{
	initial	{ ck_wr, tm_wr, al_wr } = 0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		ck_wr <= 1'b0;
		tm_wr <= 1'b0;
		al_wr <= 1'b0;
	end else begin
		ck_wr <= ((i_wb_stb)&&(i_wb_addr==3'b000)&&(i_wb_we));
		tm_wr <= ((i_wb_stb)&&(i_wb_addr==3'b001)&&(i_wb_we));
		al_wr <= ((i_wb_stb)&&(i_wb_addr==3'b011)&&(i_wb_we));
	end
	// }}}

	// wr_data, wr_valid, wr_zero, clock_display
	// {{{
	always @(posedge i_clk)
	begin
		wr_data     <= i_wb_data[25:0];
		wr_valid[0] <= (i_wb_sel[0])&&(i_wb_data[3:0] <= 4'h9)
				&&(i_wb_data[7:4] <= 4'h5);
		wr_valid[1] <= (i_wb_sel[1])&&(i_wb_data[11:8] <= 4'h9)
				&&(i_wb_data[15:12] <= 4'h5);
		wr_valid[2] <= (i_wb_sel[2])&&(i_wb_data[19:16] <= 4'h9)
				&&(i_wb_data[21:16] <= 6'h23);
		wr_zero <= (i_wb_data[23:0] == 0);


		if((i_wb_stb)&&(i_wb_addr==3'b000)&&(i_wb_we)&&(i_wb_sel[3]))
			clock_display <= i_wb_data[25:24];
	end
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// Core time generator--generate the once per second pulse
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	// ck_carry, ck_counter
	// {{{
	initial		ck_carry = 1'b0;
	initial		ck_counter = 40'h00;
	always @(posedge i_clk)
		{ ck_carry, ck_counter } <= ck_counter + { 8'h00, ckspeed };
	// }}}

	assign	ck_pps = (ck_carry)&&(ck_prepps);

	// ck_sub, ck_prepps
	// {{{
	always @(posedge i_clk)
	begin
		if (ck_carry)
			ck_sub <= ck_sub + 8'h1;
		ck_prepps <= (ck_sub == 8'hff);
	end
	// }}}

	// rtcbare
	// {{{
	rtcbare clock(i_clk, i_reset, ck_pps,
		ck_wr, wr_data[21:0], wr_valid, clock_data, ck_ppd);
	// }}}

	// ck_ppm
	// {{{
	always @(posedge i_clk)
		ck_ppm <= (clock_data[14:8] == 7'h59);
	// }}}

	// ck_last_clock
	// {{{
	// Clock updates take several clocks, so let's make sure we
	// are only looking at a valid clock value before testing it.
	always @(posedge i_clk)
		ck_last_clock <= clock_data[21:0];
	// }}}
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// Timer
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	generate if (OPT_TIMER)
	begin : TIMER

		rtctimer #(.LGSUBCK(8))
			timer(i_clk, i_reset, ck_carry, tm_wr, wr_data[24:0],
				wr_valid, wr_zero, timer_data, tm_int);

	end else begin : NOTIMER
		// {{{
		assign	tm_int = 0;
		assign	timer_data = 0;

		// Make verilator happy
		// verilator lint_off UNUSED
		wire	timer_unused;
		assign	timer_unused = tm_wr;
		// verilator lint_on  UNUSED
		// }}}
	end endgenerate
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// Stopwatch
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	generate if (OPT_STOPWATCH)
	begin

		reg	[2:0]	sw_ctrl;
		initial	sw_ctrl = 0;
		always @(posedge i_clk)
		if (i_reset)
			sw_ctrl <= 0;
		else if (i_wb_stb && i_wb_we && i_wb_sel[0] && i_wb_addr == 3'b010)
			sw_ctrl <= { i_wb_data[1:0], !i_wb_data[0] };
		else
			sw_ctrl <= 0;

		rtcstopwatch rtcstop(i_clk, i_reset, ckspeed,
			sw_ctrl[2], sw_ctrl[1], sw_ctrl[0],
			stopwatch_data, sw_running);

	end else begin
		// {{{
		assign	stopwatch_data = 0;
		assign	sw_running = 0;
		// }}}
	end endgenerate
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// Alarm
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	generate if (OPT_ALARM)
	begin : ALARM

		rtcalarm alarm(i_clk, i_reset, clock_data[21:0],
				al_wr, wr_data[25], wr_data[24], wr_data[21:0],
					wr_valid[2:0],
				alarm_data, al_int);


	end else begin : NO_ALARM
		// {{{
		assign	alarm_data = 0;
		assign	al_int = 0;
		// }}}
	end endgenerate
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// Clock rate control
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	//
	// The ckspeed register is equal to 2^48 divded by the number of
	// clock ticks you expect per second.  Adjust high for a slower
	// clock, lower for a faster clock.  In this fashion, a single
	// real time clock RTL file can handle tracking the clock in any
	// device.  Further, because this is only the lower 32 bits of a
	// 48 bit counter per seconds, the clock jitter is kept below
	// 1 part in 65 thousand.
	//
	initial	ckspeed = DEFAULT_SPEED;
	// In the case of verilator, comment the above and uncomment the line
	// below.  The clock constant below is "close" to simulation time,
	// meaning that my verilator simulation is running about 300x slower
	// than board time.
	// initial	ckspeed = 32'd786432000;
	always @(posedge i_clk)
	if ((sp_sel)&&(i_wb_we))
		ckspeed <= i_wb_data;
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// Time hacks
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	//
	// If you want very fine precision control over your clock, you need
	// to be able to transfer time from one location to another.  This
	// is the beginning of that means: by setting a wire, i_hack, high
	// on a particular input, you can then read (later) what the clock
	// time was on that input.
	//
	// What's missing from this high precision adjustment mechanism is a
	// means of actually adjusting this time based upon the time
	// difference you measure here between the hack time and some time
	// on another clock, but we'll get there.
	//
	initial	hack_time    = 30'h0000;
	initial	hack_counter = 40'h0000;
	always @(posedge i_clk)
	if (i_hack)
	begin
		hack_time <= { clock_data[21:0], ck_sub };
		hack_counter <= ck_counter;
		r_hack_carry <= ck_carry;
		// if ck_carry is set, the clock register is in the
		// middle of a two clock update.  In that case ....
	end else if (r_hack_carry)
	begin // update again on the next clock to get the correct hack time.
		hack_time <= { clock_data[21:0], ck_sub };
		r_hack_carry <= 1'b0;
	end

	assign	tm_alarm = timer_data[25];
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// 7-Segment display control
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	always @(posedge i_clk)
	case(clock_display)
	2'h1: begin
		// {{{
		h_sseg <= timer_data[15:0];
		if (tm_alarm) dmask <= 3'h7;
		else begin
			dmask[3] <= (12'h000 != timer_data[23:12]); // timer[15:12]
			dmask[2] <= (16'h000 != timer_data[23: 8]); // timer[11: 8]
			dmask[1] <= (20'h000 != timer_data[23: 4]); // timer[ 7: 4]
			// dmask[0] <= 1'b1; // Always on
		end end
		// }}}
	2'h2: begin
		// {{{
		h_sseg <= stopwatch_data[19:4];
		dmask[3] <= (12'h00  != stopwatch_data[27:16]);
		dmask[2] <= (16'h000 != stopwatch_data[27:12]);
		dmask[1] <= 1'b1; // Always on, stopwatch[11:8]
		// dmask[0] <= 1'b1; // Always on, stopwatch[7:4]
		end
		// }}}
	2'h3: begin
		// {{{
		h_sseg <= ck_last_clock[15:0];
		dmask[3:1] <= 3'h7;
		end
		// }}}
	default: begin // 4'h0
		// {{{
		h_sseg <= { 2'b00, ck_last_clock[21:8] };
		dmask[2:1] <= 2'b11;
		dmask[3] <= (2'b00 != ck_last_clock[21:20]);
		end
		// }}}
	endcase

	assign	w_sseg[ 0] =  (!ck_sub[7]);
	assign	w_sseg[ 8] =  (clock_display == 2'h2);
	assign	w_sseg[16] = ((clock_display == 2'h0)
				&&(!ck_sub[7]))||(clock_display == 2'h3);
	assign	w_sseg[24] = 1'b0;
	hexmap	ha(i_clk, h_sseg[ 3: 0], w_sseg[ 7: 1]);
	hexmap	hb(i_clk, h_sseg[ 7: 4], w_sseg[15: 9]);
	hexmap	hc(i_clk, h_sseg[11: 8], w_sseg[23:17]);
	hexmap	hd(i_clk, h_sseg[15:12], w_sseg[31:25]);

	assign	al_tripped = alarm_data[25];

	always @(posedge i_clk)
	if ((tm_alarm || al_tripped)&&(ck_sub[7]))
		// If timer or alarm have tripped, make the display
		// blink at 1Hz, 50% duty cycle
		o_sseg <= 32'h0000;
	else
		o_sseg <= {
			(dmask[3])?w_sseg[31:24]:8'h00,
			(dmask[2])?w_sseg[23:16]:8'h00,
			(dmask[1])?w_sseg[15: 8]:8'h00,
			w_sseg[ 7: 0] };
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// LED control
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//

	//
	// Use the LED's to count up to a minute.
	always @(posedge i_clk)
	// At the top of any minute, start the led register back at
	// zero
	if ((ck_pps)&&(ck_ppm))
		ledreg <= 18'h00;
	// Otherwise, 256 times a second, add 11 to an 18 bit counter.
	else if (ck_carry)
		ledreg <= ledreg + 18'h11;
	
	// The top 8 bits of this counter will form our LED setting.
	// Since the Basys3 board has two sets of LED's, we inverse the bottom
	// set for a pretty display.
	//
	// If either alarm or timer have tripped, blink the LED display at
	// 1Hz, 50% duty cycle
	//
	assign	o_led = (tm_alarm||al_tripped)?{ (16){ck_sub[7]}}:
			{ ledreg[17:10],
			ledreg[10], ledreg[11], ledreg[12], ledreg[13],
			ledreg[14], ledreg[15], ledreg[16], ledreg[17] };
	// }}}
	////////////////////////////////////////////////////////////////////////
	//
	// Last bits: o_interrupt, and o_data
	// {{{
	////////////////////////////////////////////////////////////////////////
	//
	//


	assign	o_interrupt = tm_int || al_int;

	// A once-per day strobe, on the last second of the day so that the
	// the next clock is the first clock of the day.  This is useful for
	// connecting this module to a year/month/date date/calendar module.
	assign	o_ppd = (ck_ppd)&&(ck_pps);

	always @(posedge i_clk)
	case(i_wb_addr[2:0])
	3'b000: o_data <= { 6'h00, clock_display, 2'b00, clock_data[21:0] };
	3'b001: o_data <= timer_data;
	3'b010: o_data <= { sw_running, stopwatch_data };
	3'b011: o_data <= alarm_data;
	3'b100: o_data <= ckspeed;
	3'b101: o_data <= { 2'b00, hack_time };
	3'b110: o_data <= hack_counter[39:8];
	3'b111: o_data <= { hack_counter[7:0], 24'h00 };
	endcase
	// }}}

	// Make verilator hapy
	// {{{
	// verilator lint_off UNUSED
	wire	unused;
	assign	unused = i_wb_cyc;
	// verilator lint_on UNUSED
	// }}}
`ifdef	FORMAL
	// This design has not been formally verified.  The section exists
	// only as a place holder for such verification when implemented.
	always @(*)
		assume(ckspeed > 0);
`endif
endmodule
