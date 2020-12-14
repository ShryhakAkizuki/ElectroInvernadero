module TwoRegToChar (Clock, RegistroEntero, RegistroDecimal, Char1, Char2, Char3);

input wire Clock;
input wire [7:0]RegistroEntero;
input wire [7:0]RegistroDecimal;
output reg [7:0] Char1;
output reg [7:0] Char2;
output reg [7:0] Char3;


reg [7:0] RegistroEntero1;
reg [7:0] RegistroEntero2;

always @(posedge Clock)begin

if((RegistroEntero<8'd100) && (RegistroEntero>=8'd90))begin
	RegistroEntero1=4'd9;
	RegistroEntero2=RegistroEntero-8'd90;
end

if((RegistroEntero<8'd90) && (RegistroEntero>=8'd80))begin
	RegistroEntero1=4'd8;
	RegistroEntero2=RegistroEntero-8'd80;
end

if((RegistroEntero<8'd80) && (RegistroEntero>=8'd70))begin
	RegistroEntero1=4'd7;
	RegistroEntero2=RegistroEntero-8'd70;
end

if((RegistroEntero<8'd70) && (RegistroEntero>=8'd60))begin
	RegistroEntero1=4'd6;
	RegistroEntero2=RegistroEntero-8'd60;
end

if((RegistroEntero<8'd60) && (RegistroEntero>=8'd50))begin
	RegistroEntero1=4'd5;
	RegistroEntero2=RegistroEntero-8'd50;
end

if((RegistroEntero<8'd50) && (RegistroEntero>=8'd40))begin
	RegistroEntero1=4'd4;
	RegistroEntero2=RegistroEntero-8'd40;
end

if((RegistroEntero<8'd40) && (RegistroEntero>=8'd30))begin
	RegistroEntero1=4'd3;
	RegistroEntero2=RegistroEntero-8'd30;
end

if((RegistroEntero<8'd30) && (RegistroEntero>=8'd20))begin
	RegistroEntero1=4'd2;
	RegistroEntero2=RegistroEntero-8'd20;
end

if((RegistroEntero<8'd20) && (RegistroEntero>=8'd10))begin
	RegistroEntero1=4'd1;
	RegistroEntero2=RegistroEntero-8'd10;
end

if((RegistroEntero<8'd10) && (RegistroEntero>=8'd0))begin
	RegistroEntero1=4'd0;
	RegistroEntero2=RegistroEntero;
end


case(RegistroEntero1)
	4'd0:Char1=8'b00110000;
	4'd1:Char1=8'b00110001;
	4'd2:Char1=8'b00110010;
	4'd3:Char1=8'b00110011;
	4'd4:Char1=8'b00110100;
	4'd5:Char1=8'b00110101;
	4'd6:Char1=8'b00110110;
	4'd7:Char1=8'b00110111;
	4'd8:Char1=8'b00111000;
	4'd9:Char1=8'b00111001;
	default:Char1=8'b00110000;
endcase

case(RegistroEntero2)
	4'd0:Char2=8'b00110000;
	4'd1:Char2=8'b00110001;
	4'd2:Char2=8'b00110010;
	4'd3:Char2=8'b00110011;
	4'd4:Char2=8'b00110100;
	4'd5:Char2=8'b00110101;
	4'd6:Char2=8'b00110110;
	4'd7:Char2=8'b00110111;
	4'd8:Char2=8'b00111000;
	4'd9:Char2=8'b00111001;
	default:Char2=8'b00110000;
endcase

case(RegistroDecimal)
	4'd0:Char3=8'b00110000;
	4'd1:Char3=8'b00110001;
	4'd2:Char3=8'b00110010;
	4'd3:Char3=8'b00110011;
	4'd4:Char3=8'b00110100;
	4'd5:Char3=8'b00110101;
	4'd6:Char3=8'b00110110;
	4'd7:Char3=8'b00110111;
	4'd8:Char3=8'b00111000;
	4'd9:Char3=8'b00111001;
	default:Char3=8'b00110000;
endcase

end




endmodule
