module Control(Clock, ArduinoTemp, ManualTemp, ArduinoIlum, ManualIlum, ArduinoRiego, ManualRiego, ArduinoPesticida, ManualPesticida, ManualServo, Temperatura, Riego, Pesticida, Iluminacion, TiempoRiego, Servo, Sseg, an);
input wire Clock;


//Control Temperatura
input wire ArduinoTemp; //Señal Control Arduino
input wire ManualTemp; //Señal Control Manual

//Control Iluminacion
input wire ArduinoIlum;//Señal Control Arduino
input wire ManualIlum;//Señal Control Manual

//Control Riego
input wire ArduinoRiego;//Señal Control Arduino
input wire ManualRiego;//Señal Control Manual

//Control Pesticida
input wire ArduinoPesticida;//Señal Control Arduino
input wire ManualPesticida;//Señal Control Manual

//Control Servomotor
input wire ManualServo;//Señal Control Manual
output reg Servo=1'b0;//Señal de Salida Para Servomotor

output reg Temperatura=1'b0; //Señal de Salida para Calefactor
output wire Riego;//Señal de Salida Rele Riego
output wire Pesticida;//Señal de Salida Rele Pesticida
output reg Iluminacion=1'b0;//Señal de Salida Iluminacion

output wire [6:0] Sseg;
output wire [7:0] an;


wire ClockSeg;
input wire [7:0] TiempoRiego;
reg [7:0] TiempoPesticida=1'b1;

reg InicioRiego=1'b0;
reg InicioPesticida=1'b0;

Riego RiegoPesticida(Clock, ClockSeg, InicioPesticida, TiempoPesticida, Pesticida);
DivF Segundos(Clock, ClockSeg);
CronoRiego RiegoPrincipal(Clock, InicioRiego, TiempoRiego, Riego, Sseg, an);


always @(posedge ClockSeg)begin


if( (ArduinoTemp==1'b1)||(ManualTemp==1'b1))Temperatura=1'b1;
else Temperatura=1'b0;

if( (ArduinoIlum==1'b1)||(ManualIlum==1'b1))Iluminacion=1'b1;
else Iluminacion=1'b0;

if( (ArduinoRiego==1'b1)||(ManualRiego==1'b1))InicioRiego=1'b1;
else InicioRiego=1'b0;

if( (ArduinoPesticida==1'b1)||(ManualPesticida==1'b1))InicioPesticida=1'b1;
else InicioPesticida=1'b0;

if(ManualServo==1'b1)Servo=1'b1;
else Servo=1'b0;

end






endmodule
