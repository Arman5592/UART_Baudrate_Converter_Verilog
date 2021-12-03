// https://www.analog.com/en/analog-dialogue/articles/uart-a-hardware-communication-protocol.html#


module uart_rx #(parameter bd_divider=2500)
					(input wire clk, input wire rx, output reg done, 
					 output wire [7:0] data_r);

reg data_in = 1'b1; //normally high
reg data_current = 1'b1; //normally high

reg [11:0] clock_count = 'b0; //clock count mitone kheili bishtar az 10 bashe (baudrate)
reg [7:0] data = 'b0;	//chizi ke save mikonim (midim biron baadan)
reg [2:0] data_index = 'b0; //inke chandomin bit e data ro darim migirim (0~8)
reg [2:0] machine_state = 'b0; //ya idle hastim ya start ya stop ya darim data migirim
/*
0: idle
1: start
2: data
3: stop
4: 0 kardan
*/
assign data_r = data;

always @ (posedge clk)
begin
	data_in <= rx;
	data_current <= data_in;
	
	case(machine_state)
	3'b000://idle
	begin
		done <= 'b0;
		clock_count <= 'b0;
		data_index <= 'b0;
		
		if(data_current == 1'b0)//yani az full-high dar omadim data dare miad
			machine_state <= 3'b001;
		else
			machine_state <= 3'b000;
	end
	
	3'b001://start
	begin
		if(clock_count == (bd_divider-1)/2)
		begin
			if(data_current == 1'b0)
			begin
				clock_count <= 3'b000;	//vasate pulse reset mikonimesh
				machine_state <= 3'b010;
			end
			else
				machine_state <= 3'b000;// baraye safety.. vagarna asan nemishe ke
		end
		else
		begin
			clock_count <= clock_count + 1'b1;
			machine_state <= 3'b001;
		end
	end
	
	3'b010://data
	begin
		if(clock_count < bd_divider-1)
		begin
			clock_count <= clock_count + 1'b1;
			machine_state <= 3'b010;
		end
		else
		begin
			clock_count <= 3'b000; //yani bite avale data omad
			data[data_index] <= data_current;
			
			//hala bayad data_index update beshe
			if(data_index < 7)
			begin
				data_index <= data_index + 1'b1;
				machine_state <= 3'b010;
			end
			else
			begin
				data_index <= 'b0;
				machine_state <= 3'b011;
			end
		end
	end
	
	
	3'b011://stop
	begin
		if(clock_count < bd_divider-1)
		begin
			clock_count <= clock_count + 1'b1;
			machine_state <= 3'b011;
		end
		else
		begin
			done <= 1'b1;
			clock_count <= 3'b000;
			machine_state <= 3'b100;
		end
	end
	
	3'b100://baade 1 clock e stop, reset mishe hamechi
	begin
		machine_state <= 3'b101;
		done <= 1'b0;
	end
	
	3'b101://baade 1 clock e stop, reset mishe hamechi
	begin
		machine_state <= 3'b000;
		done <= 1'b0;
	end
	
	default:
	begin
		machine_state <= 3'b000;
	end
	
	endcase
end
endmodule
