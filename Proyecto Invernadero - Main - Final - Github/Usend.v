module Usend(Clock,Tx, Start, Finish, TxData1, TxData2, TxData3); 

input wire Clock;
output wire Tx;
output reg Finish;
input wire Start;


input wire [7:0] TxData1;
input wire [7:0] TxData2;
input wire [7:0] TxData3;

reg [7:0] TxData=1'b0;
wire TxDone;
reg TxEn=1'b1;
reg Reset=1'b1;
reg [7:0] DelayTX=1'b0;

reg[1:0] CounterTX=1'b0;

TOPSendder UartTX(Clock, Reset, Tx, TxData, TxDone,TxEn);

always @(posedge Clock)begin


if(Start==1'b1)begin
			
			
		
		if(CounterTX==2'd3)begin
			Finish=1'b1;
			TxEn=1'b0;
		end
		else begin
		Finish=1'b0;
		
		if(CounterTX==1'b0)TxData=TxData1;
		if(CounterTX==1'b1)TxData=TxData2;
		if(CounterTX==2'd2)TxData=TxData3;
		
		//Write
		if(TxDone) begin
			DelayTX=8'd200;
		end 
		
		if(DelayTX==8'd193)TxEn=1'b0;
		if(DelayTX==8'd100)CounterTX=CounterTX+1'b1;
		
		if(DelayTX!=0)begin			
			DelayTX=DelayTX-1'b1;
		end else TxEn=1'b1;
		
		end
	
		
		

		
end else begin
TxEn=1'b0;
CounterTX=1'b0;
end

end


endmodule
