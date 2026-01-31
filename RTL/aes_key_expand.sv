`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ASHISH RAJPUT {MIT MANIPAL ]
// 
// Create Date: 31.01.2026 03:31:09
// Design Name: 
// Module Name: aes_key_expand
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


module aes_key_expand(
    input  logic [3:0] round,
    input  logic [127:0] key_in,
    output logic [127:0] round_key
);

    // Simple demo: use same key each round
    // Later replace with real key schedule

    assign round_key = key_in;

endmodule