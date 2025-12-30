`timescale 1ns / 1ps

module tb_datapath_debug;
    // Inputs
    reg clk;
    reg rst_n;

    // Outputs
    wire aluZero;
    wire [3:0] ALUOp;
    wire [31:0] wd3, rd1, rd2, srcA, srcB, aluResult;

    // Instantiate the Unit Under Test (UUT)
    datapath_debug uut (
        .clk(clk),
        .rst_n(rst_n),
        .aluZero(aluZero),
        .ALUOp(ALUOp),
        .wd3(wd3),
        .rd1(rd1),
        .rd2(rd2),
        .srcA(srcA),
        .srcB(srcB),
        .aluResult(aluResult)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end

    // Stimulus process
    initial begin
        // Initialize inputs
        rst_n = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // Run simulation for a fixed number of cycles
        #200;

        // End simulation
        $finish;
    end

    // Monitor key signals for debugging
    initial begin
        $monitor("Time=%0t rst_n=%b clk=%b PC=%h Instr=%h ALUOp=%h aluZero=%b rd1=%h rd2=%h srcA=%h srcB=%h aluResult=%h wd3=%h",
                 $time, rst_n, clk, uut.pc, uut.instr, ALUOp, aluZero, rd1, rd2, srcA, srcB, aluResult, wd3);
    end

    // Dump waveform for viewing
    initial begin
        $dumpfile("datapath_debug.vcd");
        $dumpvars(0, tb_datapath_debug);
    end
endmodule