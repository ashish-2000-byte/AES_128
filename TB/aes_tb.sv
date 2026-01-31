`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ASHISH RAJPUT (MIT MANIPAL )
// 
// Create Date: 31.01.2026 03:33:19
// Design Name: 
// Module Name: aes_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module aes_tb;

    logic clk=0;
    always #5 clk=~clk;

    logic rst,start,done;
    logic [127:0] key,pt,ct;

    aes_128 dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .key(key),
        .plaintext(pt),
        .ciphertext(ct),
        .done(done)
    );

    initial begin
        rst=1; #20; rst=0;

        key = 128'h000102030405060708090a0b0c0d0e0f;
        pt  = 128'h00112233445566778899aabbccddeeff;

        start=1; #10; start=0;

        wait(done);

        $display("Ciphertext = %h", ct);

        #50;
        $finish;
    end

endmodule
