module Riego (Clock, ClockSeg, Inicio, TimeMult, Valvula);

input Inicio;
input [7:0] TimeMult;
input ClockSeg;
input Clock;
output reg Valvula=1'b1;

reg Status=1'b0;
reg [13:0] RiegoCont=1'b0;
wire [13:0] TiempoRiego;
wire Final;


//Modulo Multiplicador - Tiempo de Riego
Multiplicador Multiplicar(6'b111100, TimeMult, Inicio, Clock, TiempoRiego, Final);



initial begin
	Status=WAIT;
end

parameter WAIT=0, RIEGO=1;

always @(negedge ClockSeg)begin
		
	//Maquina de estados finita
	 case (Status)
        WAIT:begin
				RiegoCont=0;
				Valvula=1;
				if(Inicio)Status=RIEGO;
        end
        RIEGO:begin
				RiegoCont=RiegoCont+1'b1;
				Valvula=0;
				if(RiegoCont==TiempoRiego) Status=WAIT;
        end
        default:Status=WAIT;  
    endcase
	 
end

endmodule
