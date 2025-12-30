module mips_datapath (
    input clk,
    input rst_n,
    output [31:0] pc_out,
    output [31:0] instr_out,
    output [31:0] mem_data_out,
);


assign imAddr = pc >> 2;
rom instr_rom(imAddr, instr);

register r_pc(clk ,rst_n, pc_new, pc);

register_file rf
(
.clk ( clk ),
.a1 ( instr[25:21] ),
.a2 ( instr[20:16] ),
.a3 ( a3 ),
.rd1 ( rd1 ),
.rd2 ( rd2 ),
.wd3 ( wd3 ),
.we3 ( regWrite )
);
wire [4:0] a3 = (regDst == 2'b01) ? instr[15:11] :(regDst == 2'b10) ? 5'b11111 :  instr[20:16];

ram data_ram
(
.clk ( clk ),
.a ( dmAddr ),
.we ( bWrite0 ),
.wd ( dmWData ),
.rd ( dmRData )
);

assign wd3 = (memToReg == 1) ? dmRData:(memToReg == 2) ? pcNext : aluResult;

alu alu
(
.srcA ( rd1 ),
.srcB ( srcB ),
.oper ( aluControl ),
.shift ( instr[10:6 ] ),
.zero ( aluZero ),
.result ( aluResult )
);

wire [31:0] srcB = aluSrc ? signImm : rd2;


wire [31:0] signImm = { {16 { instr[15] }}, instr[15:0] }; 


wire [31:0] pcNext = pc + 4;
assign pcBranch = pcNext + signImm;

assign BranchCond = Branch & (aluZero == condZero);


wire [31:0] pc_Branch = BranchCond ? pcBranch : pcNext;

wire [31:0] pc_new = (pcSrc == 1) ? Instr[25:0]:(pcSrc == 2) ? aluResult : pc_Branch ;


control_unit control_unit
(
.opcode(instruction[31:26]),
.funct(instruction[5:0]),
.ALU_Code(aluOP),
.regDst(regDst),
.regWrite(regWrite),
.branch(Branch),
.condZero(condZero),
.aluSrc(aluSrc),
.memWrite(memWrite),
.memToReg(memToReg),
.pcSrc(pcSrc)
);

assign pc_out=pc;
assign instr_out=instr;
assign mem_data_out=aluResult;


endmodule