module uart_tx #(parameter bd_divider=2500) 
				   (input wire clk, input wire [7:0] data_in, 
					 input wire in_ready, output reg tx);
    

 reg [2:0] state = 3'b000, next_state;
 reg [3:0] data_index = 0;
 reg [15:0] clk_count = 0;
 reg [7:0] current_data = 0;

always @(posedge clk) 
begin
  next_state <= 3'b000;
  case (state)
		3'b000:begin
			 clk_count <= 'b0;
			 data_index <= 'b0;
			 tx <= 1'b1;
			 if (in_ready == 1'b1) begin
				  current_data <= data_in;
				  next_state <= 3'b010;
			 end
			 else begin
				  next_state <= 3'b000;
			 end
		end

		3'b010: begin
			 tx <= 1'b0;
			 if(clk_count < bd_divider-1'b1) begin
				  clk_count <= clk_count + 1'b1;
				  next_state <= 3'b010;
			 end
			 else begin
				  clk_count <= 'b0;
				  next_state <= 3'b001;
			 end
		end


		3'b001:begin
			 tx <= current_data[data_index];
			 if(clk_count < bd_divider-1'b1)begin
				  clk_count <= clk_count + 1'b1;
				  next_state <= 3'b001;
			 end
			 else begin
				  clk_count <= 'b0;
				  if (data_index < 3'd7)begin
						data_index <= data_index + 1'b1;
						next_state <= 3'b001;
				  end
				  else begin
						data_index <= 'b0;
						next_state <= 3'b100;
				  end
			 end
		end

		3'b100:begin
			 tx <= 1'b1;
			 if(clk_count < bd_divider-1'b1)begin
				  clk_count <= clk_count + 1'b1;
				  next_state <= 3'b100;
			 end
			 else begin
				  clk_count <= 'b0;
				  next_state <= 3'b000;
			 end
		end

		default: begin
			 next_state <= 3'b000;
		end
  endcase
end

always @(*)
begin
	state <= next_state;
end

endmodule