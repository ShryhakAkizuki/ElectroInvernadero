module Multiplicador( Num1, Num2, Inicio, Clock, Result, Final);

input [5:0] Num1;
input [7:0] Num2;
input Inicio;
input Clock;
output reg [13:0] Result;
output reg Final;

reg Desplazar;
reg Reset;
reg Sumar;
reg [13:0] A;
reg [7:0] B;
reg [2:0] Status;

wire z;

parameter START = 0, CHECK = 1, ADD = 2, SHIFT = 3, END = 4;

//Indicador de Fin

assign z = (B==0) ?1:0;




always @(posedge Clock) begin


if(Reset)begin //Inicializacion de variables
	Result=0;
	A = {8'b00000000, Num1};
	B = Num2;
end 
else begin

	if(Desplazar)begin //Corrimiento de señal
		A = A << 1;
		B = B >> 1;
	end

	if(Sumar)begin //Suma acumulativa
		Result= Result + A;
	end	
	
end



//maquina de estados finitos


	case(Status) 
	START:begin
			Desplazar=0;
			Sumar=0;
			if(Inicio)begin
				Final=0;
				Reset=1;
				Desplazar=0;
				Sumar=0;
				Status = CHECK;
			end		
	end	
	CHECK:begin
			Reset =0;
			Final=0;
			Desplazar=0;
			Sumar=0;
			
			if(B[0]==1) Status = ADD;
			else Status = SHIFT;
	end
	SHIFT:begin
			Desplazar=1;
			Sumar=0;
			Reset=0;
			Final=0;
			
			if(z==1) Status = END;
			else Status = CHECK;
	end
	ADD:  begin
			Final=0;
			Reset=0;
			Desplazar=0;
			Sumar=1;
			
			Status= SHIFT;
	end
	END:  begin
			Final=1;
			Reset=0;
			Desplazar=0;
			Sumar=0;
			
			Status= START;
	end
	default:Status=START;
endcase
end

endmodule
