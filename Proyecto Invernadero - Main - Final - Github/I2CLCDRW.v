module I2CLCDRW (Reset, Inicio, Clock, Address, DataI, DataO, RW, SDAO, SDAI, SCL, Package, End, Request);


input wire Clock;	//Clock I2C 25KHz
input wire Inicio; //Señal de Inicio I2C
input wire Reset;//Señal Reinicio I2C
input wire SDAI;//Señal Datos Entrada I2C
input wire [6:0] Address;//Direccion
input wire [7:0] DataI;//Datos Envio I2C
input wire [9:0] Package;//Cantidad de datos a enviar o recibir
input wire RW;	//Lectura o Escritura


output reg [7:0] DataO; //Señal Datos Salida I2C
output reg SDAO;//I2C Enviar Datos
output wire SCL;//I2C SCL
output wire End;//Señal Finalizado Envio de Datos
output reg Request;//Señal Cambio de Dato de entrada o salida

localparam STATE_IDLE=0, STATE_START=1, STATE_ADDR=2, STATE_RW=3, STATE_WACK=4, STATE_DATA=5, STATE_WACK2=6, STATE_STOP=7;

reg [2:0] State;	//Estados I2C
reg [2:0] Data_Count;//contadorEnvioDatos
reg [6:0] Save_Addr;//Direccion
reg [7:0] Save_Data;//Datos
reg Save_RW;//Lectura Escritura
reg [9:0] Save_Package;//Numero de Datos
reg [9:0] Counter_Package;//Contador de Datos
reg SCL_Enable;


initial begin
	State<=1'b0;
	SCL_Enable<=1'b0;
end


assign SCL = (SCL_Enable == 1'b0) ? 1'b1 : ~Clock;
assign End = (State==STATE_STOP) ? 1'b1: 1'b0;

always @(negedge Clock) begin

if(Reset==1'b1)begin
	SCL_Enable<=1'b0;
end
else begin
	if((State==STATE_IDLE)||(State==STATE_START) || (State==STATE_STOP))begin
	SCL_Enable<=1'b0;
	end
	else begin
	SCL_Enable<=1'b1;
	end	
end

end

always @(posedge Clock) begin

if(Reset)begin
	Save_Package<=1'b0;
	Save_RW<=1'b0;	
	State<=STATE_IDLE;
	SDAO <=1'b1;
	Data_Count<=1'd0;
	DataO<=1'b0;	
	Counter_Package<=1'b0;
end
else begin


	case(State)

		STATE_IDLE: begin
			SDAO<=1'b1;
			Data_Count<=1'd0;
			if(Inicio) begin
				Save_Package<=Package;
				Counter_Package<=1'b0;
				Data_Count<=1'd0;
				DataO<=1'b0;
				State<=STATE_START;
				Save_Addr<=Address;
				Save_Data<=DataI;
				Save_RW<=RW;
			end
			else State<=STATE_IDLE;
		end
		
		STATE_START: begin 
			SDAO<=1'b0;
			State<=STATE_ADDR;
			Data_Count<=3'd6;
		end
		
		STATE_ADDR:begin
			SDAO<=Save_Addr[Data_Count];
			if(Data_Count==1'b0)State<=STATE_RW;
			else Data_Count<=Data_Count-1'b1;
		end
		STATE_RW:begin
			SDAO<=Save_RW;
			State<=STATE_WACK;
		end
		
		STATE_WACK:begin
			SDAO<=Save_RW;
			Data_Count <=3'd7;
			State<=STATE_DATA;
		end
		
		STATE_DATA:begin
			if(Save_RW==1'b1)begin
				SDAO<=1'b0;
				DataO[Data_Count]<=SDAI;
			end
			else SDAO<=Save_Data[Data_Count];

			
			if(Data_Count==1'b0) begin
				State<=STATE_WACK2;
				Request=1'b1;
				
			end
			else Data_Count <= Data_Count-1'b1;
		end
			
		STATE_WACK2:begin
			SDAO<=Save_RW;
			
			Request<=1'b0;
			Counter_Package<=Counter_Package+1'b1;
			if(Counter_Package==Save_Package)State<=STATE_STOP;
			else begin
				State<=STATE_DATA;
				Save_Data<=DataI;
				Data_Count<=3'd7;
				
			end
		end
		STATE_STOP:begin
		SDAO<=1'b1;
		State<= STATE_IDLE;
		
		end
	endcase
end

end

endmodule

