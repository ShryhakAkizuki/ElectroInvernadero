module DivF(Clock, S);
input Clock;
output reg S;

reg [25:0] counter;

initial S=0;

always @(posedge Clock)begin
	
    //Divisor de frecuencia
    if(counter < 25'd25_000_000)begin
      counter = counter + 1'b1;
    end
    else begin
      counter = 0;
      S=!S;
    end
	
end

endmodule 