module SSeg (Clock,Sseg1,Sseg2,Sseg3,Sseg4,Sseg5,Sseg6,Sseg7,Sseg8,Sseg,an);

input Clock;
input [3:0] Sseg1;
input [3:0] Sseg2;
input [3:0] Sseg3;
input [3:0] Sseg4;
input [3:0] Sseg5;
input [3:0] Sseg6;
input [3:0] Sseg7;
input [3:0] Sseg8;
output wire [6:0] Sseg;
output reg [7:0] an;

reg [3:0] BCD;
reg [2:0] selector;
wire SignalKHZ;


initial begin
    BCD=0;
    an=0;
    selector=0;
end

DivFKHzK DivFKHz(Clock, SignalKHZ);
BCD2SSeg Display(BCD, Sseg); //Conversor Numerico - 7segmentos

always @ (posedge SignalKHZ) begin

selector = selector + 1'b1;

case(selector)
	3'b000: begin
		BCD = Sseg1;
		an = 8'b11111110;
	end
	3'b001: begin
		BCD = Sseg2;
		an = 8'b11111101;
	end
	3'b010: begin
		BCD = Sseg3;
		an = 8'b11111011;
	end
	3'b011: begin
		BCD = Sseg4;
		an = 8'b11110111;
	end
	3'b100: begin
		BCD = Sseg5;
		an = 8'b11101111;
    end
	3'b101: begin
		BCD = Sseg6;
		an = 8'b11011111;
    end
	3'b110: begin
		BCD = Sseg7;
		an = 8'b10111111;
    end
	3'b111: begin
		BCD = Sseg8;
		an = 8'b01111111;
    end
	default: begin
		BCD = 4'h0;
		an = 8'b00000000;	
	end
endcase
end


endmodule
