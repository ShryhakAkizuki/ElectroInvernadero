module CronoRiego (Clock, Pulsador, Switches, Valvula, Sseg, an);

input [7:0] Switches;
input Clock;
input Pulsador;
output wire [6:0] Sseg;
output wire Valvula;
output wire [7:0] an;

wire ClockSeg;


DivF Seconds (Clock, ClockSeg);
Cronometro Crono (Clock,ClockSeg, !Valvula, Sseg, an); //Cronometro - 7Segmentos
Riego R (Clock, ClockSeg, Pulsador, Switches, Valvula);//Modulo de Riego


endmodule
