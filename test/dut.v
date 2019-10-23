`timescale 1ns/100ps

module dut
    (
    input           rw_n,
    input           halt_n,
    input           irq_n,
    input           rd5,
    input           s5_n,
    input   [15:0]  ctrl,
    input			rsrvd,
    input			cctl_n,
    input	[15:0]	addr,
    input			extsel_n,
    input 	[7:0]	data,
    input			rst_n,
    input			rd4,
    input			s4_n,
    input			mpd_n,
    input			ref_n,
    input			clk,
    input			D1xx_n
    );
    
endmodule
