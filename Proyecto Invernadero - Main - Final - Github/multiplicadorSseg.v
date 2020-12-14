module multiplicadorSseg (Clock, Switch, Sseg, an, Start, End);

input [7:0] Switch;
input Clock;
input Start;	

output [6:0] Sseg;
output reg [7:0] an;
output End;

wire Signal;
wire Cout;
wire [7:0] Result;
reg [3:0] BCD;


initial begin
BCD=0;
an=0;
end

DivF Freq (Clock, Signal);
Multiplicador Mult( Switch[3:0], Switch[7:4], !Start, Clock, Result, End);
BCD2SSeg Hex (BCD, Sseg);

reg [1:0] selector; 

always @ (posedge Signal) begin

selector = selector + 1;

case(selector)
	2'b00: begin
		BCD = Result[3:0];
		an = 8'b11111110;
	end
	2'b01: begin
		BCD = Result[7:4];
		an = 8'b11111101;
	end
	2'b10: begin
		BCD = Switch[7:4];
		an = 8'b11011111;
	end
	2'b11: begin
		BCD = Switch[3:0];
		an = 8'b01111111;
	end
	
	default: begin
		BCD = 4'h0;
		an = 8'b00000000;	
	end

endcase
end
endmodule
