`timescale 1ns / 1ps


module transceiver(input wire clk, rx,
						 output wire tx);
	 

wire [7:0] r_data,t_data;
wire reset_fifo;	 
						 
uart_rx receiver (clk, rx, r_dv, r_data);
uart_tx transmitter (clk, t_data, r_dv, tx);
fifo	  data_fifo (clk, reset_fifo,);

endmodule
