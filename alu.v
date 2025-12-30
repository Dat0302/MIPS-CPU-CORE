module alu (
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [3:0]  oper,
    input  [4:0]  shift,
    output reg        zero,
    output reg [31:0] result
);

always @(*) begin
    case (oper)
        4'b0000: result = ~srcA;                          
        4'b0001: result = srcA & srcB;                    
        4'b0010: result = srcA ^ srcB;                    
        4'b0011: result = srcA | srcB;                   
        4'b0100: result = srcA - 1;                      
        4'b0101: result = srcA + srcB;                    
        4'b0110: result = srcA - srcB;                   
        4'b0111: result = srcA + 1;                       
        4'b1000: result = (srcA < srcB) ? 32'd1 : 32'd0;   
        4'b1010: result = srcB << shift;                  
        4'b1011: result = srcB >> shift;                   
        4'b1100: result = srcB << 16;                 
        default: result = srcA + srcB;                   
    endcase
end

always @(*) begin
    zero = (result == 0); 
end

endmodule	