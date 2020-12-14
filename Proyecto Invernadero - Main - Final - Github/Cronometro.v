module Cronometro (Clock, ClockSeg, Signal, Sseg, an);

input wire Clock;
input wire ClockSeg;
input wire Signal;
output wire [6:0] Sseg;
output wire [7:0] an;

reg [3:0] Segundos0;
reg [3:0] Segundos1;
reg [3:0] Minutos0;
reg [3:0] Minutos1;
reg [3:0] Horas0;


initial begin
	Segundos0=0;
	Segundos1=0;
	Minutos0=0;
	Minutos1=0;
	Horas0=0;
end


//Modulo Completo 7 segmentos
SSeg Display(Clock,Segundos0,Segundos1,Minutos0,Minutos1,Horas0,4'h0,4'h0,4'h0,Sseg,an);


always @ (posedge ClockSeg) begin

    Segundos0=Segundos0+1'b1;
	 
	

	if(Segundos0 > 4'd9)begin
		Segundos0=0;
		Segundos1=Segundos1 + 1'b1;
	end

	if(Segundos1 == 4'd6)begin
		Segundos1 =0;
		Minutos0=Minutos0+1'b1;
	end

	if(Minutos0 > 4'd9)begin
		Minutos0=0;
		Minutos1=Minutos1+1'b1;
	end

	if(Minutos1 == 4'd6)begin
		Minutos1=0;
      Horas0=Horas0+1'b1;
   end
	 
	if(Signal==0)begin
		Segundos0=0;
	   Segundos1=0;
	   Minutos0=0;
	   Minutos1=0;
      Horas0=0;
   end   
	 
end

endmodule
