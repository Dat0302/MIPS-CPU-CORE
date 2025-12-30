module datapath (
    input  clk,
    input  rst_n, 
    output  aluZero
);
	 wire [3:0] ALUOp;
	 wire regWrite, memWrite, Branch,condZero;
	 wire [1:0] pcSrc, regDst, memToReg, aluSrc;
    wire [31:0] pc, pc_new, pc_next, pc_Branch, instr;
    wire [31:0] signImm;
    wire BranchCond;
    wire [4:0] a3;
    wire [31:0] wd3, rd1, rd2, srcA, srcB, aluResult;
    wire [31:0] bRData0, dmWData;
    wire [31:0] dmAddr;
    wire [5:0] imAddr;

    // PC 
    register r_pc (
        .clk(clk),
        .rst_n(rst_n), 
        .d(pc),
        .q(pc_new)
    );
    assign imAddr = pc >> 2;

    // ROM 
    rom instr_rom (
        .imAddr(imAddr),
        .imData(instr)
    );

    // RF
    RF rf (
        .clk(clk),
        .a1(instr[25:21]),
        .a2(instr[20:16]),
        .a3(a3),
        .wd3(wd3),
        .we3(regWrite),
        .rd1(rd1),
        .rd2(rd2)
    );

    // RF
    assign a3 = (regDst == 2'b01) ? instr[15:11] :
                (regDst == 2'b10) ? 5'b11111 : instr[20:16];

    // RAM instantiation
    ram data_ram (
        .clk(clk),
        .a(dmAddr),
        .we(memWrite),
        .wd(dmWData),
        .rd(bRData0)
    );

    // Ram   mux
 	assign wd3 = (memToReg == 2'b01) ? bRData0 :
               (memToReg == 2'b10) ? pc_next : aluResult;

    // ALU
    alu alu1 (
        .srcA(rd1),
        .srcB(srcB),
        .oper(ALUOp),
        .shift(instr[10:6]),
        .zero(aluZero),
        .result(aluResult)
    );
	control_unit control_unit
	(
	.opcode(instr[31:26]),
	.funct(instr[5:0]),
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
    // ALU  Mux
    assign srcB = (aluSrc == 2'b01) ? signImm : rd2;

    // Sign Extend
    assign signImm = {{16{instr[15]}}, instr[15:0]};

    // PC+4
    assign pc_next = pc + 4;

    // PC+4+ExtImm
    assign pcBranch = pc_next + (signImm << 2);

    // Branch Condition
    assign BranchCond = Branch & (aluZero == condZero);

    // PC Mux
    assign pc_Branch = BranchCond ? pcBranch : pc_next;
    assign pc_new = (pcSrc == 2'b01) ?  instr[25:0] : 
                    (pcSrc == 2'b10) ? aluResult : pc_Branch; 

endmodule