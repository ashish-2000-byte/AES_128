`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ASHISH RAJPUT { MIT MANIPAL }
// 
// Create Date: 31.01.2026 03:22:37
// Design Name: 
// Module Name: aes_128
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


module aes_128(

    input  logic         clk,
    input  logic         rst,
    input  logic         start,

    input  logic [127:0] key,
    input  logic [127:0] plaintext,

    output logic [127:0] ciphertext,
    output logic         done
);

    typedef enum logic [1:0] {IDLE, ROUND, FINAL, DONE} state_t;
    state_t state;

    logic [127:0] state_reg;
    logic [127:0] round_key;

    logic [3:0] round;

    // --------------------------
    // Key expansion
    // --------------------------
    aes_key_expand key_sched(
        .round(round),
        .key_in(key),
        .round_key(round_key)
    );

    // --------------------------
    // AES SBOX
    // --------------------------
              function automatic [7:0] sbox(input [7:0] a);
    case(a)
        8'h00: sbox=8'h63;
        8'h01: sbox=8'h7c;
        8'h02: sbox=8'h77;
        8'h03: sbox=8'h7b;
        8'h04: sbox=8'hf2;
        8'h05: sbox=8'h6b;
        8'h06: sbox=8'h6f;
        8'h07: sbox=8'hc5;
        // paste full 256-entry table
        default: sbox=8'h00;
    endcase
endfunction

    // --------------------------
    // SubBytes
    // --------------------------
    function automatic [127:0] subbytes(input [127:0] s);
        for(int i=0;i<16;i++)
            subbytes[i*8 +: 8] = sbox(s[i*8 +: 8]);
    endfunction


    // --------------------------
    // ShiftRows
    // --------------------------
    function automatic [127:0] shiftrows(input [127:0] s);
        shiftrows = {
            s[127:120], s[87:80],  s[47:40],  s[7:0],
            s[95:88],   s[55:48],  s[15:8],   s[103:96],
            s[63:56],   s[23:16],  s[111:104],s[71:64],
            s[31:24],   s[119:112],s[79:72],  s[39:32]
        };
    endfunction


    // --------------------------
    // MixColumns
    // --------------------------
    function automatic [7:0] xtime(input [7:0] b);
        xtime = {b[6:0],1'b0} ^ (8'h1b & {8{b[7]}});
    endfunction

    function automatic [31:0] mixcol(input [31:0] c);
        logic [7:0] a0,a1,a2,a3;
        a0=c[31:24]; a1=c[23:16]; a2=c[15:8]; a3=c[7:0];

        mixcol = {
            xtime(a0)^xtime(a1)^a1^a2^a3,
            a0^xtime(a1)^xtime(a2)^a2^a3,
            a0^a1^xtime(a2)^xtime(a3)^a3,
            xtime(a0)^a0^a1^a2^xtime(a3)
        };
    endfunction

    function automatic [127:0] mixcolumns(input [127:0] s);
        mixcolumns = {
            mixcol(s[127:96]),
            mixcol(s[95:64]),
            mixcol(s[63:32]),
            mixcol(s[31:0])
        };
    endfunction


    // --------------------------
    // FSM
    // --------------------------
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
            done  <= 0;
            round <= 0;
        end
        else begin
            case(state)

            IDLE:
            if(start) begin
                state_reg <= plaintext ^ key;
                round <= 1;
                state <= ROUND;
            end

            ROUND: begin
                state_reg <= mixcolumns(shiftrows(subbytes(state_reg))) ^ round_key;

                if(round == 9)
                    state <= FINAL;
                else
                    round <= round + 1;
            end

            FINAL: begin
                state_reg <= shiftrows(subbytes(state_reg)) ^ round_key;
                ciphertext <= state_reg;
                done <= 1;
                state <= DONE;
            end

            DONE:
                state <= IDLE;

            endcase


        end
    end

endmodule
