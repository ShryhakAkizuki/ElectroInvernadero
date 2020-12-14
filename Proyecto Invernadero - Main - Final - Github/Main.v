module Main(Clock, KeyEnter, KeyEscape, KeyLeft, KeyRight, KeyDown, KeyUp, SCL, SDA, Tx, ArduinoTemp, ArduinoIlum, ArduinoRiego, ArduinoPesticida, Temperatura, Riego, Pesticida, Iluminacion, SalidaServo, Sseg, an);


input wire Clock;				//Reloj Base del sistema
input wire KeyEnter;			//Tecla Enter (Switch 5)
input wire KeyEscape;		//Tecla Escape (Switch 6)
input wire KeyLeft;			//Tecla Left (Switch 1)
input wire KeyRight;			//Tecla Right (Switch 2)
input wire KeyDown;			//Tecla Down (Switch 4)
input wire KeyUp;				//Tecla Up (Switch 3)
output wire SCL;				//Pin SCL Protocolo I2C
output wire SDA;				//Pin SDA Protocolo I2C


output wire Tx;				//Pin Envio Uart TX



input wire ArduinoTemp; 	//PinControlCalefactor
input wire ArduinoIlum;		//PinControlIluminacion
input wire ArduinoRiego;	//PinControlReleRiego
input wire ArduinoPesticida;//PinControlRelePesticida

output wire Temperatura; 	//PinCalefactor
output wire Riego;			//PinRiego
output wire Pesticida;		//PinPesticida
output wire Iluminacion;	//PinIluminacion
output wire SalidaServo;	//PinServo
output wire [6:0] Sseg;		//Numero 7segmentos
output wire [7:0] an;		//Display7segmentos - Ciclone IV


reg [10:0] Status=1'b0;		//Maquina de Estados
reg [4:0] InstruccionesI2C=1'b0;//ControlI2CLCD1602


reg I2CStart=1'b0;			//Señal de ControlI2C
reg [6:0] I2CAddress;		//Direccion I2C
reg [7:0] I2CCHAR1;			//Variables Caracteres Lista 1602
reg [7:0] I2CCHAR2;
reg [7:0] I2CCHAR3;
reg [7:0] I2CCHAR4;
reg [7:0] I2CCHAR5;
reg [7:0] I2CCHAR6;
reg [7:0] I2CCHAR7;
reg [7:0] I2CCHAR8;
reg [7:0] I2CCHAR9;
reg [7:0] I2CCHAR10;
reg [7:0] I2CCHAR11;
reg [7:0] I2CCHAR12;
reg [7:0] I2CCHAR13;
reg [7:0] I2CCHAR14;
reg [7:0] I2CCHAR15;
reg [7:0] I2CCHAR16;
reg [7:0] I2CCHAR17;
reg [7:0] I2CCHAR18;
reg [7:0] I2CCHAR19;
reg [7:0] I2CCHAR20;
reg [7:0] I2CCHAR21;
reg [7:0] I2CCHAR22;
reg [7:0] I2CCHAR23;
reg [7:0] I2CCHAR24;
reg [7:0] I2CCHAR25;
reg [7:0] I2CCHAR26;
reg [7:0] I2CCHAR27;
reg [7:0] I2CCHAR28;
reg [7:0] I2CCHAR29;
reg [7:0] I2CCHAR30;
reg [7:0] I2CCHAR31;
reg [7:0] I2CCHAR32;
wire I2CEnd;					//Señal de Control Modulo I2C
reg [21:0] Refresh=1'b0;	//Contador Actualizacion LCD1602

reg [15:0] DelayKeyEnter=15'd25_000;//RetrasoKeyEnter
reg [15:0] DelayKeyLeft=15'd25_000;//RetrasoTeclaLeft
reg [15:0] DelayKeyRight=15'd25_000;//RetrasoTeclaRight
reg [15:0] DelayKeyUp=15'd25_000;//RetrasoTeclaUp
reg [15:0] DelayKeyDown=15'd25_000;//RetrasoTeclaDown
reg [15:0] DelayKeyEscape=15'd25_000;//RetrasoTeclaEscape

wire [7:0] Char10unit;		//Caracter 1602 Numero decena
wire [7:0] Char1unit;		//Caracter 1602 Numero Entero
wire [7:0] Chardeciunit;	//Caracter 1602 Numero Decimal

reg [1:0] PosSumm=1'b0;		//Control Suma o Resta de Variables de Ajuste


reg [7:0] Save_HumedadSueloEnt=8'd33;	//RegistroHumedadSuelo
reg [7:0] Save_HumedadSueloDec=8'd3; 
reg [7:0] Save_HumedadAireEnt=8'd66;	//RegistroHumedadAire
reg [7:0] Save_HumedadAireDec=8'd7; 
reg [7:0] Save_TemperaturaEnt=8'd20;	//RegistroTemperatura
reg [7:0] Save_TemperaturaDec=8'd2; 
reg [7:0] Save_IntensidadUVEnt=8'd10;	//RegistroIntensidadLuminica
reg [7:0] Save_IntensidadUVDec=8'd5; 



//Registros Implementacion Uart RX - Informacion - En proceso
reg [7:0] ACT_HumedadSueloEnt=8'd78;	
reg [7:0] ACT_HumedadSueloDec=8'd2; 
reg [7:0] ACT_CalidadAireEnt=8'd25;
reg [7:0] ACT_CalidadAireDec=8'd5; 
reg [7:0] ACT_HumedadAireEnt=8'd30;
reg [7:0] ACT_HumedadAireDec=8'd4; 
reg [7:0] ACT_TemperaturaEnt=8'd64;
reg [7:0] ACT_TemperaturaDec=8'd7; 
reg [7:0] ACT_IntensidadUVEnt=8'd99;
reg [7:0] ACT_IntensidadUVDec=8'd9; 


reg [7:0] TXData1=8'd0;		//Dato #1 Uart TX
reg [7:0] TXData2=8'd30;	//Dato #2 Uart TX
reg [7:0] TXData3=8'd50;	//Dato #3 Uart TX

wire [7:0] RxData1;			//Dato #1 Uart RX
wire [7:0] RxData2;			//Dato #2 Uart RX
wire FinishArd;				//Finalizacion Uart TX

reg ArduinoStart=1'b1;		//Señal de Control Inicio Uart TX


//Señales de Bloqueo Switches
reg BlockEnter=1'b0;			
reg BlockUp=1'b0;
reg BlockDown=1'b0;
reg BlockEscape=1'b0;
reg BlockLeft=1'b0;
reg BlockRight=1'b0;

//Modulos para Conversion de Decimal a 1602
reg[7:0] RegistroEntero=1'b0;
reg[7:0] RegistroDecimal=1'b0;

wire S;


//Señales de Control Manual Salidas
reg ManualTemp=1'b0;
reg ManualIlum=1'b0;
reg ManualRiego=1'b0;
reg ManualPesticida=1'b0;
reg ManualServo=1'b0;


//Variables On/Off textuales 1602
reg [7:0] Charon1=8'b00010000;
reg [7:0] Charon2=8'b00010000;
reg [7:0] Charon3=8'b00010000;

//Tiempo de Riego Rele/Riego
reg [7:0] TiempoRiego=1'b1;

//Modulo Uart TX
Usend(Clock,Tx, ArduinoStart, FinishArd, TXData1, TXData2, TXData3); 
//Modulo Divisor de frecuencia 25KHz
DivFKHz Reloj(Clock, S);
//Modulo Display LCD1602 - I2C
LCD16X2 Displa(Clock, SDA, SCL, I2CStart, I2CAddress, I2CCHAR1, I2CCHAR2, I2CCHAR3, I2CCHAR4, I2CCHAR5, I2CCHAR6, I2CCHAR7, I2CCHAR8, I2CCHAR9, I2CCHAR10, I2CCHAR11, I2CCHAR12, I2CCHAR13, I2CCHAR14, I2CCHAR15, I2CCHAR16, I2CCHAR17, I2CCHAR18, I2CCHAR19, I2CCHAR20, I2CCHAR21, I2CCHAR22, I2CCHAR23, I2CCHAR24, I2CCHAR25, I2CCHAR26, I2CCHAR27, I2CCHAR28, I2CCHAR29, I2CCHAR30, I2CCHAR31, I2CCHAR32, I2CEnd );
//Conversor Decimal - 1602
TwoRegToChar I2C (S, RegistroEntero, RegistroDecimal, Char10unit, Char1unit, Chardeciunit);
//Modulo Control de Salidas
Control Salidas(Clock, ArduinoTemp, ManualTemp, ArduinoIlum, ManualIlum, ArduinoRiego, ManualRiego, ArduinoPesticida, ManualPesticida, ManualServo, Temperatura, Riego, Pesticida, Iluminacion, TiempoRiego, SalidaServo, Sseg, an);

//Parametros Maquina de Estados
parameter INFORMACION=0, IHUMEDADS=1, IHUMEDADA=2, ITEMPERATURA=3, ICALIDADA=4, IINTENSIDADUV=5, AJUSTES=6, AJUSTEHUMEDADCANTIDAD=7, AHUMEDADS=8, ACANTIDADA=9, AJUSTESHUMEDADA=10, AHUMEDADA=11, AJUSTESTEMPERATURA=12, ATEMPERATURA=13, AJUSTESINTENSIDADUV=14,AINTENSIDADUV=15, ControlManual=16, ControlIluminacion=17, ControlCalefaccion=18, ControlServo=19, ControlRiego=20, ControlPesticida=21;

always @(posedge S) begin
	//
	//
	//Condiciones Repetidas
	
	//Finalizacion Automatica Uart TX
	if(FinishArd==1'b1)ArduinoStart=1'b0;

	
	//Condicionales Sumas - Ajustes
	if(Save_HumedadSueloDec>=4'd10)begin
		Save_HumedadSueloDec=1'b0;
		Save_HumedadSueloEnt=Save_HumedadSueloEnt+1'b1;
	end
	
	if(TiempoRiego>=8'd100)begin
		TiempoRiego=1'b0;
	end
	
	if(Save_HumedadAireDec>=4'd10)begin
		Save_HumedadAireDec=1'b0;
		Save_HumedadAireEnt=Save_HumedadAireEnt+1'b1;
	end
	
	if(Save_TemperaturaDec>=4'd10)begin
		Save_TemperaturaDec=1'b0;
		Save_TemperaturaEnt=Save_TemperaturaEnt+1'b1;
	end
	
	if(Save_IntensidadUVDec>=4'd10)begin
		Save_IntensidadUVDec=1'b0;
		Save_IntensidadUVEnt=Save_IntensidadUVEnt+1'b1;
	end
	
	
	
	if(Save_IntensidadUVEnt>=8'd99)Save_IntensidadUVEnt=8'd99;
	if(Save_IntensidadUVEnt<=4'd0)Save_IntensidadUVEnt=4'd0;
	
	
	if(Save_TemperaturaEnt>=8'd99)Save_TemperaturaEnt=8'd99;
	if(Save_TemperaturaEnt<=4'd0)Save_TemperaturaEnt=4'd0;
	
	
	if(Save_HumedadAireEnt>=8'd99)Save_HumedadAireEnt=8'd99;
	if(Save_HumedadAireEnt<=4'd0)Save_HumedadAireEnt=4'd0;
		
	if(Save_HumedadSueloEnt>=8'd99)Save_HumedadSueloEnt=8'd99;
	if(Save_HumedadSueloEnt<=4'd0)Save_HumedadSueloEnt=4'd0;
	
	
	
	//
	//Bloqueador 1 comando I2C
	if(I2CEnd)begin
		I2CStart=1'b0;
		InstruccionesI2C=InstruccionesI2C+1'b1;
	end
	
	
	//
	//Refrescamiento de pantalla 1 minuto
	Refresh=Refresh+1'b1;
	if(Refresh==21'd1_500_000)begin
		Refresh=1'b0;
		InstruccionesI2C=1'b0;
	end
	



	
	//
	//Delay Tecla Right
	if(DelayKeyRight!=0)begin
		BlockRight=1'b1;
		DelayKeyRight=DelayKeyRight-1'b1;
		if(!KeyRight)DelayKeyRight=1'b0;
	end else BlockRight=1'b0;
	
	
	//
	//Delay Tecla Left
	if(DelayKeyLeft!=0)begin
		BlockLeft=1'b1;
		DelayKeyLeft=DelayKeyLeft-1'b1;
		if(!KeyLeft)DelayKeyLeft=1'b0;
	end else BlockLeft=1'b0;
	
	
	//
	//Delay Tecla Up
	if(DelayKeyUp!=0)begin
		BlockUp=1'b1;
		DelayKeyUp=DelayKeyUp-1'b1;
		if(!KeyUp)DelayKeyUp=1'b0;
	end else BlockUp=1'b0;
	
	
	//
	//Delay Tecla Down
	if(DelayKeyDown!=0)begin
		BlockDown=1'b1;
		DelayKeyDown=DelayKeyDown-1'b1;
		if(!KeyDown)DelayKeyDown=1'b0;
	end else BlockDown=1'b0;
	
	
	//
	//Delay Tecla Enter
	if(DelayKeyEnter!=0)begin
		BlockEnter=1'b1;
		DelayKeyEnter=DelayKeyEnter-1'b1;
		if(!KeyEnter)DelayKeyEnter=1'b0;
	end else BlockEnter=1'b0;
	
	
	//
	//Delay Tecla escape
	if(DelayKeyEscape!=0)begin
		BlockEscape=1'b1;
		DelayKeyEscape=DelayKeyEscape-1'b1;
		if(!KeyEscape)DelayKeyEscape=1'b0;
	end else BlockEscape=1'b0;







	
	//
	//
	//Maquina de Estados Menu:
	case(Status)
		
		
		//panel de Informacion
		INFORMACION:begin
		
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b01001001;
				I2CCHAR4=8'b01001110;
				I2CCHAR5=8'b01000110;
				I2CCHAR6=8'b01001111;
				I2CCHAR7=8'b01010010;
				I2CCHAR8=8'b01001101;
				I2CCHAR9=8'b01000001;
				I2CCHAR10=8'b01000011;
				I2CCHAR11=8'b01001001;
				I2CCHAR12=8'b01001111;
				I2CCHAR13=8'b01001110;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b00010000;
				I2CCHAR21=8'b00010000;
				I2CCHAR22=8'b00010000;
				I2CCHAR23=8'b00010000;
				I2CCHAR24=8'b00010000;
				I2CCHAR25=8'b00010000;
				I2CCHAR26=8'b00010000;
				I2CCHAR27=8'b00010000;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			
		
			
			
			
			//
			//
			//Enter
			if(!BlockEnter)begin
				if(KeyEnter)begin
					Status=IHUMEDADS;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=AJUSTES;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=ControlManual;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			
			
			
			
		end
		
		
		
		//Informacion Humedad del Suelo
		IHUMEDADS:begin

			RegistroEntero=ACT_HumedadSueloEnt;
			RegistroDecimal=ACT_HumedadSueloDec;
			
			//Llamadas Arduino
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b01001000;
				I2CCHAR3=8'b01010101;
				I2CCHAR4=8'b01001101;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01000100;
				I2CCHAR7=8'b01000001;
				I2CCHAR8=8'b01000100;
				I2CCHAR9=8'b00010000;
				I2CCHAR10=8'b01010011;
				I2CCHAR11=8'b01010101;
				I2CCHAR12=8'b01000101;
				I2CCHAR13=8'b01001100;
				I2CCHAR14=8'b01001111;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b01000001;
				I2CCHAR19=8'b01000011;
				I2CCHAR20=8'b01010100;
				I2CCHAR21=8'b01010101;
				I2CCHAR22=8'b01000001;
				I2CCHAR23=8'b01001100;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=8'b00101110;
				I2CCHAR28=Chardeciunit;
				I2CCHAR29=8'b01010010;
				I2CCHAR30=8'b01001000;
				I2CCHAR31=8'b00100101;
				I2CCHAR32=8'b00010000;
			end
			
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=IHUMEDADA;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=IINTENSIDADUV;
				end
			end
				
			
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=INFORMACION;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;				
					
				end
			end
		
		
		end
		
		
		
		//Informacion Humedad del Aire
		IHUMEDADA:begin

			RegistroEntero=ACT_HumedadAireEnt;
			RegistroDecimal=ACT_HumedadAireDec;
			
			//Llamadas Arduino
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b01001000;
				I2CCHAR4=8'b01010101;
				I2CCHAR5=8'b01001101;
				I2CCHAR6=8'b01000101;
				I2CCHAR7=8'b01000100;
				I2CCHAR8=8'b01000001;
				I2CCHAR9=8'b01000100;
				I2CCHAR10=8'b00010000;
				I2CCHAR11=8'b01000001;
				I2CCHAR12=8'b01001001;
				I2CCHAR13=8'b01010010;
				I2CCHAR14=8'b01000101;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b01000001;
				I2CCHAR19=8'b01000011;
				I2CCHAR20=8'b01010100;
				I2CCHAR21=8'b01010101;
				I2CCHAR22=8'b01000001;
				I2CCHAR23=8'b01001100;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=8'b00101110;
				I2CCHAR28=Chardeciunit;
				I2CCHAR29=8'b01010010;
				I2CCHAR30=8'b01001000;
				I2CCHAR31=8'b00100101;
				I2CCHAR32=8'b00010000;
			end
			
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=ITEMPERATURA;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=IHUMEDADS;
				end
			end
				
			
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=INFORMACION;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;				
					
				end
			end
		
		
		end
		
		
		
		
		//Informacion Temperatura
		ITEMPERATURA:begin

			RegistroEntero=ACT_TemperaturaEnt;
			RegistroDecimal=ACT_TemperaturaDec;
			
			//Llamadas Arduino
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b01010100;
				I2CCHAR4=8'b01000101;
				I2CCHAR5=8'b01001101;
				I2CCHAR6=8'b01010000;
				I2CCHAR7=8'b01000101;
				I2CCHAR8=8'b01010010;
				I2CCHAR9=8'b01000001;
				I2CCHAR10=8'b01010100;
				I2CCHAR11=8'b01010101;
				I2CCHAR12=8'b01010010;
				I2CCHAR13=8'b01000001;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b01000001;
				I2CCHAR19=8'b01000011;
				I2CCHAR20=8'b01010100;
				I2CCHAR21=8'b01010101;
				I2CCHAR22=8'b01000001;
				I2CCHAR23=8'b01001100;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=8'b00101110;
				I2CCHAR28=Chardeciunit;
				I2CCHAR29=8'b11011111;
				I2CCHAR30=8'b01000011;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=ICALIDADA;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=IHUMEDADA;
				end
			end
				
			
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=INFORMACION;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;				
					
				end
			end
		
		
		end
		
		
		
		//Informacion Calidad del Aire
		ICALIDADA:begin

			RegistroEntero=ACT_CalidadAireEnt;
			RegistroDecimal=ACT_CalidadAireDec;
			
			//Llamadas Arduino
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b01000100;
				I2CCHAR2=8'b01001001;
				I2CCHAR3=8'b01001111;
				I2CCHAR4=8'b01011000;
				I2CCHAR5=8'b01001001;
				I2CCHAR6=8'b01000100;
				I2CCHAR7=8'b01001111;
				I2CCHAR8=8'b00010000;
				I2CCHAR9=8'b01000011;
				I2CCHAR10=8'b01000001;
				I2CCHAR11=8'b01010010;
				I2CCHAR12=8'b01000010;
				I2CCHAR13=8'b01001111;
				I2CCHAR14=8'b01001110;
				I2CCHAR15=8'b01001111;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b01000001;
				I2CCHAR19=8'b01000011;
				I2CCHAR20=8'b01010100;
				I2CCHAR21=8'b01010101;
				I2CCHAR22=8'b01000001;
				I2CCHAR23=8'b01001100;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=Chardeciunit;
				I2CCHAR28=8'b01010000;
				I2CCHAR29=8'b01010000;
				I2CCHAR30=8'b01001101;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=IINTENSIDADUV;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=ITEMPERATURA;
				end
			end
				
			
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=INFORMACION;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;				
					
				end
			end
		
		
		end
		
		
		
		//Informacion Intensidad UV
		IINTENSIDADUV:begin

			RegistroEntero=ACT_IntensidadUVEnt;
			RegistroDecimal=ACT_IntensidadUVDec;
			
			//Llamadas Arduino
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b01001001;
				I2CCHAR3=8'b01001110;
				I2CCHAR4=8'b01010100;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01001110;
				I2CCHAR7=8'b01010011;
				I2CCHAR8=8'b01001001;
				I2CCHAR9=8'b01000100;
				I2CCHAR10=8'b01000001;
				I2CCHAR11=8'b01000100;
				I2CCHAR12=8'b00010000;
				I2CCHAR13=8'b01010101;
				I2CCHAR14=8'b01010110;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b01000001;
				I2CCHAR19=8'b01000011;
				I2CCHAR20=8'b01010100;
				I2CCHAR21=8'b01010101;
				I2CCHAR22=8'b01000001;
				I2CCHAR23=8'b01001100;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=Chardeciunit;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=IHUMEDADS;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					InstruccionesI2C=1'b0;
					Status=ICALIDADA;
				end
			end
				
			
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=INFORMACION;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;				
					
				end
			end
		
		
		end
		
		
		
		
		
		//Panel de Ajustes
		AJUSTES:begin
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b00010000;
				I2CCHAR4=8'b00010000;
				I2CCHAR5=8'b01000001;
				I2CCHAR6=8'b01001010;
				I2CCHAR7=8'b01010101;
				I2CCHAR8=8'b01010011;
				I2CCHAR9=8'b01010100;
				I2CCHAR10=8'b01000101;
				I2CCHAR11=8'b01010011;
				I2CCHAR12=8'b00010000;
				I2CCHAR13=8'b00010000;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b00010000;
				I2CCHAR21=8'b00010000;
				I2CCHAR22=8'b00010000;
				I2CCHAR23=8'b00010000;
				I2CCHAR24=8'b00010000;
				I2CCHAR25=8'b00010000;
				I2CCHAR26=8'b00010000;
				I2CCHAR27=8'b00010000;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			//
			//
			//Enter
			if(!BlockEnter)begin
				if(KeyEnter)begin
					Status=AJUSTEHUMEDADCANTIDAD;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Right
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=INFORMACION;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		end
		
		
		
		//Panel de Ajuste Humedad del Suelo y Tiempo de Riego
		AJUSTEHUMEDADCANTIDAD:begin
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b01001000;
				I2CCHAR3=8'b01010101;
				I2CCHAR4=8'b01001101;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01000100;
				I2CCHAR7=8'b01000001;
				I2CCHAR8=8'b01000100;
				I2CCHAR9=8'b00010000;
				I2CCHAR10=8'b01010011;
				I2CCHAR11=8'b01010101;
				I2CCHAR12=8'b01000101;
				I2CCHAR13=8'b01001100;
				I2CCHAR14=8'b01001111;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00101111;
				I2CCHAR17=8'b01010100;
				I2CCHAR18=8'b01001001;
				I2CCHAR19=8'b01000101;
				I2CCHAR20=8'b01001101;
				I2CCHAR21=8'b01010000;
				I2CCHAR22=8'b01001111;
				I2CCHAR23=8'b00010000;
				I2CCHAR24=8'b01000100;
				I2CCHAR25=8'b01000101;
				I2CCHAR26=8'b00010000;
				I2CCHAR27=8'b01010010;
				I2CCHAR28=8'b01001001;
				I2CCHAR29=8'b01000101;
				I2CCHAR30=8'b01000111;
				I2CCHAR31=8'b01001111;
				I2CCHAR32=8'b00010000;
			end
			
			//
			//
			//Enter
			if(!BlockEnter)begin
				if(KeyEnter)begin
					Status=AHUMEDADS;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=AJUSTESHUMEDADA;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=AJUSTESINTENSIDADUV;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTES;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		end
		
		
		
		
		//Ajuste Humedad del Suelo
		AHUMEDADS:begin
			RegistroEntero=Save_HumedadSueloEnt;
			RegistroDecimal=Save_HumedadSueloDec;
			
			TXData1=8'd1; //Comando 1
			TXData2=Save_HumedadSueloEnt;
			TXData3=Save_HumedadSueloDec;
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b01001000;
				I2CCHAR3=8'b01010101;
				I2CCHAR4=8'b01001101;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01000100;
				I2CCHAR7=8'b01000001;
				I2CCHAR8=8'b01000100;
				I2CCHAR9=8'b00010000;
				I2CCHAR10=8'b01010011;
				I2CCHAR11=8'b01010101;
				I2CCHAR12=8'b01000101;
				I2CCHAR13=8'b01001100;
				I2CCHAR14=8'b01001111;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b01010110;
				I2CCHAR19=8'b01000001;
				I2CCHAR20=8'b01001100;
				I2CCHAR21=8'b01001111;
				I2CCHAR22=8'b01010010;
				I2CCHAR23=8'b00111010;
				I2CCHAR24=8'b00010000;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=8'b00101110;
				I2CCHAR28=Chardeciunit;
				I2CCHAR29=8'b01010010;
				I2CCHAR30=8'b01001000;
				I2CCHAR31=8'b00100101;
				I2CCHAR32=8'b00010000;
			end
			//
			//
			//Condicionales Movimiento de seleccion de dato
			if(PosSumm<=2'd0)PosSumm=2'd0;
			if(PosSumm>=2'd2)PosSumm=2'd2;
			//
			//
			//Enter
			if(!BlockEnter)begin 
				if(KeyEnter)begin
					Status=ACANTIDADA;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm-1'b1;

				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm+1'b1;
				end
			end
				
			//
			//
			//Up
			if(!BlockUp)begin
				if(KeyUp)begin
					DelayKeyUp=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_HumedadSueloDec=Save_HumedadSueloDec+1'b1;
					if(PosSumm==1'b1)Save_HumedadSueloEnt=Save_HumedadSueloEnt+1'b1;
					if(PosSumm==2'd2)Save_HumedadSueloEnt=Save_HumedadSueloEnt+4'd10;

				end
			end
			//
			//
			//Down
			if(!BlockDown)begin
				if(KeyDown)begin
					DelayKeyDown=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_HumedadSueloDec=Save_HumedadSueloDec-1'b1;
					if(PosSumm==1'b1)Save_HumedadSueloEnt=Save_HumedadSueloEnt-1'b1;
					if(PosSumm==2'd2)Save_HumedadSueloEnt=Save_HumedadSueloEnt-4'd10;
				end
			end		
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTEHUMEDADCANTIDAD;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;

				end
			end
		end
		
		
		//Ajuste Cantidad de Agua
		ACANTIDADA:begin
		
		
			RegistroEntero=TiempoRiego;
			RegistroDecimal=1'b0;

			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b01010100;
				I2CCHAR2=8'b01001001;
				I2CCHAR3=8'b01000101;
				I2CCHAR4=8'b01001101;
				I2CCHAR5=8'b01010000;
				I2CCHAR6=8'b01001111;
				I2CCHAR7=8'b00010000;
				I2CCHAR8=8'b01000100;
				I2CCHAR9=8'b01000101;
				I2CCHAR10=8'b00010000;
				I2CCHAR11=8'b01010010;
				I2CCHAR12=8'b01001001;
				I2CCHAR13=8'b01000101;
				I2CCHAR14=8'b01000111;
				I2CCHAR15=8'b01001111;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b01010110;
				I2CCHAR20=8'b01000001;
				I2CCHAR21=8'b01001100;
				I2CCHAR22=8'b01001111;
				I2CCHAR23=8'b01010010;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=8'b00010000;
				I2CCHAR28=8'b01001101;
				I2CCHAR29=8'b01001001;
				I2CCHAR30=8'b01001110;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			//
			//
			//Condicionales Movimiento de seleccion de dato
			if(PosSumm<=1'b0)PosSumm=1'b0;
			if(PosSumm>=1'b1)PosSumm=1'b1;

			//
			//
			//Enter
			if(!BlockEnter)begin //PENDIENTE
				if(KeyEnter)begin
					Status=AJUSTEHUMEDADCANTIDAD;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm-1'b1;

				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm+1'b1;
				end
			end
				
			//
			//
			//Up
			if(!BlockUp)begin
				if(KeyUp)begin
					DelayKeyUp=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)TiempoRiego=TiempoRiego+1'b1;
					if(PosSumm==1'b1)TiempoRiego=TiempoRiego+4'd10;
				end
			end
			
			//
			//
			//Down
			if(!BlockDown)begin
				if(KeyDown)begin
					DelayKeyDown=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)TiempoRiego=TiempoRiego-1'b1;
					if(PosSumm==1'b1)TiempoRiego=TiempoRiego-4'd10;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTEHUMEDADCANTIDAD;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
				
				end
			end
		end
		

		//Panel de Ajuste Humedad del Aire
		AJUSTESHUMEDADA:begin
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b01001000;
				I2CCHAR4=8'b01010101;
				I2CCHAR5=8'b01001101;
				I2CCHAR6=8'b01000101;
				I2CCHAR7=8'b01000100;
				I2CCHAR8=8'b01000001;
				I2CCHAR9=8'b01000100;
				I2CCHAR10=8'b00010000;
				I2CCHAR11=8'b01000001;
				I2CCHAR12=8'b01001001;
				I2CCHAR13=8'b01010010;
				I2CCHAR14=8'b01000101;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b00010000;
				I2CCHAR21=8'b00010000;
				I2CCHAR22=8'b00010000;
				I2CCHAR23=8'b00010000;
				I2CCHAR24=8'b00010000;
				I2CCHAR25=8'b00010000;
				I2CCHAR26=8'b00010000;
				I2CCHAR27=8'b00010000;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			//
			//
			//Enter
			if(!BlockEnter)begin
				if(KeyEnter)begin
					Status=AHUMEDADA;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=AJUSTESTEMPERATURA;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=AJUSTEHUMEDADCANTIDAD;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTES;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		
		
		end
		//Ajuste Humedad del Aire
		AHUMEDADA:begin
		
			TXData1=8'd2; //Comando 2
			TXData2=Save_HumedadAireEnt;
			TXData3=Save_HumedadAireDec;
			RegistroEntero=Save_HumedadAireEnt;
			RegistroDecimal=Save_HumedadAireDec;
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b01001000;
				I2CCHAR4=8'b01010101;
				I2CCHAR5=8'b01001101;
				I2CCHAR6=8'b01000101;
				I2CCHAR7=8'b01000100;
				I2CCHAR8=8'b01000001;
				I2CCHAR9=8'b01000100;
				I2CCHAR10=8'b00010000;
				I2CCHAR11=8'b01000001;
				I2CCHAR12=8'b01001001;
				I2CCHAR13=8'b01010010;
				I2CCHAR14=8'b01000101;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b01010110;
				I2CCHAR20=8'b01000001;
				I2CCHAR21=8'b01001100;
				I2CCHAR22=8'b01001111;
				I2CCHAR23=8'b01010010;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=8'b00101110;
				I2CCHAR28=Chardeciunit;
				I2CCHAR29=8'b01010010;
				I2CCHAR30=8'b01001000;
				I2CCHAR31=8'b00100101;
				I2CCHAR32=8'b00010000;
			end
			//
			//
			//Condicionales Movimiento de seleccion de dato
			if(PosSumm<=1'b0)PosSumm=1'b0;
			if(PosSumm>=2'd2)PosSumm=2'd2;

			//
			//
			//Enter
			if(!BlockEnter)begin //PENDIENTE
				if(KeyEnter)begin
					Status=AJUSTESHUMEDADA;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm-1'b1;

				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm+1'b1;
				end
			end
				
			//
			//
			//Up
			if(!BlockUp)begin
				if(KeyUp)begin
					DelayKeyUp=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_HumedadAireDec=Save_HumedadAireDec+1'b1;
					if(PosSumm==1'b1)Save_HumedadAireEnt=Save_HumedadAireEnt+1'b1;
					if(PosSumm==2'd2)Save_HumedadAireEnt=Save_HumedadAireEnt+4'd10;

				end
			end
			
			//
			//
			//Down
			if(!BlockDown)begin
				if(KeyDown)begin
					DelayKeyDown=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_HumedadAireDec=Save_HumedadAireDec-1'b1;
					if(PosSumm==1'b1)Save_HumedadAireEnt=Save_HumedadAireEnt-1'b1;
					if(PosSumm==2'd2)Save_HumedadAireEnt=Save_HumedadAireEnt-4'd10;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTESHUMEDADA;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;
				end
			end
		
		
		end
		//Panel de Ajuste Temperatura
		AJUSTESTEMPERATURA:begin
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b01010100;
				I2CCHAR4=8'b01000101;
				I2CCHAR5=8'b01001101;
				I2CCHAR6=8'b01010000;
				I2CCHAR7=8'b01000101;
				I2CCHAR8=8'b01010010;
				I2CCHAR9=8'b01000001;
				I2CCHAR10=8'b01010100;
				I2CCHAR11=8'b01010101;
				I2CCHAR12=8'b01010010;
				I2CCHAR13=8'b01000001;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b00010000;
				I2CCHAR21=8'b00010000;
				I2CCHAR22=8'b00010000;
				I2CCHAR23=8'b00010000;
				I2CCHAR24=8'b00010000;
				I2CCHAR25=8'b00010000;
				I2CCHAR26=8'b00010000;
				I2CCHAR27=8'b00010000;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			//
			//
			//Enter
			if(!BlockEnter)begin
				if(KeyEnter)begin
					Status=ATEMPERATURA;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=AJUSTESINTENSIDADUV;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=AJUSTESHUMEDADA;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			   
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTES;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		
		
		
		
		end
		
		//Ajuste Temperatura
		ATEMPERATURA:begin
		
			TXData1=8'd3; //Comando 3
			TXData2=Save_TemperaturaEnt;
			TXData3=Save_TemperaturaDec;
		
			RegistroEntero=Save_TemperaturaEnt;
			RegistroDecimal=Save_TemperaturaDec;
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b01010100;
				I2CCHAR4=8'b01000101;
				I2CCHAR5=8'b01001101;
				I2CCHAR6=8'b01010000;
				I2CCHAR7=8'b01000101;
				I2CCHAR8=8'b01010010;
				I2CCHAR9=8'b01000001;
				I2CCHAR10=8'b01010100;
				I2CCHAR11=8'b01010101;
				I2CCHAR12=8'b01010010;
				I2CCHAR13=8'b01000001;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b01010110;
				I2CCHAR20=8'b01000001;
				I2CCHAR21=8'b01001100;
				I2CCHAR22=8'b01001111;
				I2CCHAR23=8'b01010010;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=8'b00101110;
				I2CCHAR28=Chardeciunit;
				I2CCHAR29=8'b11011111;
				I2CCHAR30=8'b01000011;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			//
			//
			//Condicionales Movimiento de seleccion de dato
			if(PosSumm<=1'b0)PosSumm=1'b0;
			if(PosSumm>=2'd2)PosSumm=2'd2;

			//
			//
			//Enter
			if(!BlockEnter)begin //PENDIENTE
				if(KeyEnter)begin
					Status=AJUSTESTEMPERATURA;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm-1'b1;

				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm+1'b1;
				end
			end
				
			//
			//
			//Up
			if(!BlockUp)begin
				if(KeyUp)begin
					DelayKeyUp=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_TemperaturaDec=Save_TemperaturaDec+1'b1;
					if(PosSumm==1'b1)Save_TemperaturaEnt=Save_TemperaturaEnt+1'b1;
					if(PosSumm==2'd2)Save_TemperaturaEnt=Save_TemperaturaEnt+4'd10;

				end
			end
			
			//
			//
			//Down
			if(!BlockDown)begin
				if(KeyDown)begin
					DelayKeyDown=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_TemperaturaDec=Save_TemperaturaDec-1'b1;
					if(PosSumm==1'b1)Save_TemperaturaEnt=Save_TemperaturaEnt-1'b1;
					if(PosSumm==2'd2)Save_TemperaturaEnt=Save_TemperaturaEnt-4'd10;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTESTEMPERATURA;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;
				end
			end
		
		
		
		
		end
	
		//Panel Ajuste Intensidad UV
		AJUSTESINTENSIDADUV:begin
		
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b01001001;
				I2CCHAR3=8'b01001110;
				I2CCHAR4=8'b01010100;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01001110;
				I2CCHAR7=8'b01010011;
				I2CCHAR8=8'b01001001;
				I2CCHAR9=8'b01000100;
				I2CCHAR10=8'b01000001;
				I2CCHAR11=8'b01000100;
				I2CCHAR12=8'b00010000;
				I2CCHAR13=8'b01010101;
				I2CCHAR14=8'b01010110;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b00010000;
				I2CCHAR21=8'b00010000;
				I2CCHAR22=8'b00010000;
				I2CCHAR23=8'b00010000;
				I2CCHAR24=8'b00010000;
				I2CCHAR25=8'b00010000;
				I2CCHAR26=8'b00010000;
				I2CCHAR27=8'b00010000;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			//
			//
			//Enter
			if(!BlockEnter)begin
				if(KeyEnter)begin
					Status=AINTENSIDADUV;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=AJUSTEHUMEDADCANTIDAD;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=AJUSTESTEMPERATURA;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			   
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTES;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		
		
		
		
		
		end
		//Ajuste Intensidad UV
		AINTENSIDADUV:begin
		
			TXData1=8'd4; //Comando 4
			TXData2=Save_IntensidadUVEnt;
			TXData3=Save_IntensidadUVDec;
		
		
			RegistroEntero=Save_IntensidadUVEnt;
			RegistroDecimal=Save_IntensidadUVDec;
			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b01001001;
				I2CCHAR3=8'b01001110;
				I2CCHAR4=8'b01010100;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01001110;
				I2CCHAR7=8'b01010011;
				I2CCHAR8=8'b01001001;
				I2CCHAR9=8'b01000100;
				I2CCHAR10=8'b01000001;
				I2CCHAR11=8'b01000100;
				I2CCHAR12=8'b00010000;
				I2CCHAR13=8'b01010101;
				I2CCHAR14=8'b01010110;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b01010110;
				I2CCHAR20=8'b01000001;
				I2CCHAR21=8'b01001100;
				I2CCHAR22=8'b01001111;
				I2CCHAR23=8'b01010010;
				I2CCHAR24=8'b00111010;
				I2CCHAR25=Char10unit;
				I2CCHAR26=Char1unit;
				I2CCHAR27=Chardeciunit;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			//
			//
			//Condicionales Movimiento de seleccion de dato
			if(PosSumm<=1'b0)PosSumm=1'b0;
			if(PosSumm>=2'd2)PosSumm=2'd2;

			//
			//
			//Enter
			if(!BlockEnter)begin //PENDIENTE
				if(KeyEnter)begin
					Status=AJUSTESINTENSIDADUV;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					DelayKeyRight=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm-1'b1;

				end
			end
			
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					DelayKeyLeft=15'd25_000;
					Refresh=1'b0;
					PosSumm=PosSumm+1'b1;
				end
			end
				
			//
			//
			//Up
			if(!BlockUp)begin
				if(KeyUp)begin
					DelayKeyUp=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_IntensidadUVDec=Save_IntensidadUVDec+1'b1;
					if(PosSumm==1'b1)Save_IntensidadUVEnt=Save_IntensidadUVEnt+1'b1;
					if(PosSumm==2'd2)Save_IntensidadUVEnt=Save_IntensidadUVEnt+4'd10;

				end
			end
			
			//
			//
			//Down
			if(!BlockDown)begin
				if(KeyDown)begin
					DelayKeyDown=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					
					if(PosSumm==1'b0)Save_IntensidadUVDec=Save_IntensidadUVDec-1'b1;
					if(PosSumm==1'b1)Save_IntensidadUVEnt=Save_IntensidadUVEnt-1'b1;
					if(PosSumm==2'd2)Save_IntensidadUVEnt=Save_IntensidadUVEnt-4'd10;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=AJUSTESINTENSIDADUV;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
					PosSumm=1'b0;
					ArduinoStart=1'b1;
				end
			end
		
		
		
		
		end
		
		
		//Control Manual
		ControlManual:begin

			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b00010000;
				I2CCHAR4=8'b00010000;
				I2CCHAR5=8'b00010000;
				I2CCHAR6=8'b01000011;
				I2CCHAR7=8'b01001111;
				I2CCHAR8=8'b01001110;
				I2CCHAR9=8'b01010100;
				I2CCHAR10=8'b01010010;
				I2CCHAR11=8'b01001111;
				I2CCHAR12=8'b01001100;
				I2CCHAR13=8'b00010000;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b00010000;
				I2CCHAR21=8'b00010000;
				I2CCHAR22=8'b01001101;
				I2CCHAR23=8'b01000001;
				I2CCHAR24=8'b01001110;
				I2CCHAR25=8'b01010101;
				I2CCHAR26=8'b01000001;
				I2CCHAR27=8'b01001100;
				I2CCHAR28=8'b00010000;
				I2CCHAR29=8'b00010000;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			//
			//
			//Enter
			if(!BlockEnter)begin //PENDIENTE
				if(KeyEnter)begin
					Status=ControlIluminacion;
					DelayKeyEnter=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=INFORMACION;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		end
			
			
		//Control Manual - Iluminacion
		ControlIluminacion:begin
		
			if(ManualIlum==1'b1)begin
				Charon1=8'b01001111;
				Charon2=8'b01001110;
				Charon3=8'b00010000;
			end else begin
				Charon1=8'b01001111;
				Charon2=8'b01000110;
				Charon3=8'b01000110;
			end

			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b00010000;
				I2CCHAR4=8'b01001001;
				I2CCHAR5=8'b01001100;
				I2CCHAR6=8'b01010101;
				I2CCHAR7=8'b01001101;
				I2CCHAR8=8'b01001001;
				I2CCHAR9=8'b01001110;
				I2CCHAR10=8'b01000001;
				I2CCHAR11=8'b01000011;
				I2CCHAR12=8'b01001001;
				I2CCHAR13=8'b01001111;
				I2CCHAR14=8'b01001110;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b01001101;
				I2CCHAR21=8'b01000001;
				I2CCHAR22=8'b01001110;
				I2CCHAR23=8'b01010101;
				I2CCHAR24=8'b01000001;
				I2CCHAR25=8'b01001100;
				I2CCHAR26=8'b00111010;
				I2CCHAR27=Charon1;
				I2CCHAR28=Charon2;
				I2CCHAR29=Charon3;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			
			//
			//
			//Enter
			if(!BlockEnter)begin 
				if(KeyEnter)begin
					Status=ControlIluminacion;
					DelayKeyEnter=15'd25_000;
					ManualIlum=!ManualIlum;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=ControlCalefaccion;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=ControlPesticida;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=ControlManual;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			
			
		end
			
			
			
		//Control Manual - Calefaccion
		ControlCalefaccion:begin
		
			if(ManualTemp==1'b1)begin
				Charon1=8'b01001111;
				Charon2=8'b01001110;
				Charon3=8'b00010000;
			end else begin
				Charon1=8'b01001111;
				Charon2=8'b01000110;
				Charon3=8'b01000110;
			end

			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b00010000;
				I2CCHAR4=8'b01000011;
				I2CCHAR5=8'b01000001;
				I2CCHAR6=8'b01001100;
				I2CCHAR7=8'b01000101;
				I2CCHAR8=8'b01000110;
				I2CCHAR9=8'b01000001;
				I2CCHAR10=8'b01000011;
				I2CCHAR11=8'b01000011;
				I2CCHAR12=8'b01001001;
				I2CCHAR13=8'b01001111;
				I2CCHAR14=8'b01001110;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b01001101;
				I2CCHAR21=8'b01000001;
				I2CCHAR22=8'b01001110;
				I2CCHAR23=8'b01010101;
				I2CCHAR24=8'b01000001;
				I2CCHAR25=8'b01001100;
				I2CCHAR26=8'b00111010;
				I2CCHAR27=Charon1;
				I2CCHAR28=Charon2;
				I2CCHAR29=Charon3;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			
			//
			//
			//Enter
			if(!BlockEnter)begin 
				if(KeyEnter)begin
					Status=ControlCalefaccion;
					DelayKeyEnter=15'd25_000;
					ManualTemp=!ManualTemp;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=ControlServo;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=ControlIluminacion;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=ControlManual;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		end
		
		
		//Control Manual - Servomotor
		ControlServo:begin
		
			if(ManualServo==1'b1)begin
				Charon1=8'b01001111;
				Charon2=8'b01001110;
				Charon3=8'b00010000;
			end else begin
				Charon1=8'b01001111;
				Charon2=8'b01000110;
				Charon3=8'b01000110;
			end

			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b00010000;
				I2CCHAR4=8'b01010011;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01010010;
				I2CCHAR7=8'b01010110;
				I2CCHAR8=8'b01001111;
				I2CCHAR9=8'b01001101;
				I2CCHAR10=8'b01001111;
				I2CCHAR11=8'b01010100;
				I2CCHAR12=8'b01001111;
				I2CCHAR13=8'b01010010;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b01001101;
				I2CCHAR21=8'b01000001;
				I2CCHAR22=8'b01001110;
				I2CCHAR23=8'b01010101;
				I2CCHAR24=8'b01000001;
				I2CCHAR25=8'b01001100;
				I2CCHAR26=8'b00111010;
				I2CCHAR27=Charon1;
				I2CCHAR28=Charon2;
				I2CCHAR29=Charon3;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			
			//
			//
			//Enter
			if(!BlockEnter)begin 
				if(KeyEnter)begin
					Status=ControlServo;
					DelayKeyEnter=15'd25_000;
					ManualServo=!ManualServo;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=ControlRiego;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=ControlCalefaccion;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=ControlManual;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		end
		
		
		//Control Manual - Riego
		ControlRiego:begin
		
			if(ManualRiego==1'b1)begin
				Charon1=8'b01001111;
				Charon2=8'b01001110;
				Charon3=8'b00010000;
			end else begin
				Charon1=8'b01001111;
				Charon2=8'b01000110;
				Charon3=8'b01000110;
			end

			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b00010000;
				I2CCHAR4=8'b00010000;
				I2CCHAR5=8'b00010000;
				I2CCHAR6=8'b01010010;
				I2CCHAR7=8'b01001001;
				I2CCHAR8=8'b01000101;
				I2CCHAR9=8'b01000111;
				I2CCHAR10=8'b01001111;
				I2CCHAR11=8'b00010000;
				I2CCHAR12=8'b00010000;
				I2CCHAR13=8'b00010000;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b01001101;
				I2CCHAR21=8'b01000001;
				I2CCHAR22=8'b01001110;
				I2CCHAR23=8'b01010101;
				I2CCHAR24=8'b01000001;
				I2CCHAR25=8'b01001100;
				I2CCHAR26=8'b00111010;
				I2CCHAR27=Charon1;
				I2CCHAR28=Charon2;
				I2CCHAR29=Charon3;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			
			//
			//
			//Enter
			if(!BlockEnter)begin //PENDIENTE
				if(KeyEnter)begin
					Status=ControlRiego;
					DelayKeyEnter=15'd25_000;
					ManualRiego=!ManualRiego;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=ControlPesticida;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=ControlServo;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=ControlManual;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		end
		
		
		
		//Control Manual - Pesticida
		ControlPesticida:begin
		
			if(ManualPesticida==1'b1)begin
				Charon1=8'b01001111;
				Charon2=8'b01001110;
				Charon3=8'b00010000;
			end else begin
				Charon1=8'b01001111;
				Charon2=8'b01000110;
				Charon3=8'b01000110;
			end

			
			if(InstruccionesI2C==1'b0)begin
				I2CStart=1'b1;
				I2CAddress=7'h27;
				I2CCHAR1=8'b00010000;
				I2CCHAR2=8'b00010000;
				I2CCHAR3=8'b00010000;
				I2CCHAR4=8'b01010000;
				I2CCHAR5=8'b01000101;
				I2CCHAR6=8'b01010011;
				I2CCHAR7=8'b01010100;
				I2CCHAR8=8'b01001001;
				I2CCHAR9=8'b01000011;
				I2CCHAR10=8'b01001001;
				I2CCHAR11=8'b01000100;
				I2CCHAR12=8'b01000001;
				I2CCHAR13=8'b00010000;
				I2CCHAR14=8'b00010000;
				I2CCHAR15=8'b00010000;
				I2CCHAR16=8'b00010000;
				I2CCHAR17=8'b00010000;
				I2CCHAR18=8'b00010000;
				I2CCHAR19=8'b00010000;
				I2CCHAR20=8'b01001101;
				I2CCHAR21=8'b01000001;
				I2CCHAR22=8'b01001110;
				I2CCHAR23=8'b01010101;
				I2CCHAR24=8'b01000001;
				I2CCHAR25=8'b01001100;
				I2CCHAR26=8'b00111010;
				I2CCHAR27=Charon1;
				I2CCHAR28=Charon2;
				I2CCHAR29=Charon3;
				I2CCHAR30=8'b00010000;
				I2CCHAR31=8'b00010000;
				I2CCHAR32=8'b00010000;
			end
			
			
			
			//
			//
			//Enter
			if(!BlockEnter)begin //PENDIENTE
				if(KeyEnter)begin
					Status=ControlPesticida;
					DelayKeyEnter=15'd25_000;
					ManualPesticida=!ManualPesticida;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Right
			if(!BlockRight)begin
				if(KeyRight)begin
					Status=ControlIluminacion;
					DelayKeyRight=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Left
			if(!BlockLeft)begin
				if(KeyLeft)begin
					Status=ControlRiego;
					DelayKeyLeft=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
			//
			//
			//Escape
			if(!BlockEscape)begin
				if(KeyEscape)begin
					Status=ControlManual;
					DelayKeyEscape=15'd25_000;
					InstruccionesI2C=1'b0;
					Refresh=1'b0;
				end
			end
		end
		
	default:Status=INFORMACION;
	endcase
	
	

	
	
	
end





endmodule

