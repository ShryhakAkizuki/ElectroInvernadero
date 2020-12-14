module BCD2SSeg(BCD, Sseg);

input[3:0] BCD;

output reg [6:0] Sseg;
initial Sseg=7'b1000000;

always @(*) begin

case(BCD)
	4'b0000: Sseg = 7'b1000000;//0
	4'b0001: Sseg = 7'b1111001;//1
	4'b0010: Sseg = 7'b0100100;//2
	4'b0011: Sseg = 7'b0110000;//3
	4'b0100: Sseg = 7'b0011001;//4
	4'b0101: Sseg = 7'b0010010;//5
	4'b0110: Sseg = 7'b0000010;//6
	4'b0111: Sseg = 7'b1011000;//7
	4'b1000: Sseg = 7'b0000000;//8
	4'b1001: Sseg = 7'b0010000;//9
	4'b1010: Sseg = 7'b0001000;//A
	4'b1011: Sseg = 7'b0000011;//B
   4'b1100: Sseg = 7'b1000110;//C
   4'b1101: Sseg = 7'b0100001;//D
   4'b1110: Sseg = 7'b0000110;//E
   4'b1111: Sseg = 7'b0001110;//F
	default:  Sseg = 7'b1111111;//None 
endcase 

end
endmodule
