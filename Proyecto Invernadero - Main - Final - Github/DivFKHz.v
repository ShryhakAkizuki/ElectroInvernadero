module DivFKHz(Clock, S);
input Clock;
output reg S;

reg [15:0] counter;

initial S=0;

always @(posedge Clock)begin
	
    //Divisor de frecuencia
    if(counter < 15'd1000)begin
      counter = counter + 1'b1;
    end
    else begin
      counter = 0;
      S=!S;
    end
	
end

endmodule 