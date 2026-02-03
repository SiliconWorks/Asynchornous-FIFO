`timescale 1ns / 1ps





module debounce (
    input  wire clk,
    input  wire rst,
    input  wire noisy_in,
    output reg  clean_out
);

    reg noisy_ff1, noisy_ff2;
    reg [19:0] cnt;
    reg stable_val;

    // Input synchronizer 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            noisy_ff1 <= 0;
            noisy_ff2 <= 0;
        end else begin
            noisy_ff1 <= noisy_in;
            noisy_ff2 <= noisy_ff1;
        end
    end

    // Debounce logic 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt        <= 0;
            stable_val <= 0;
            clean_out  <= 0;
        end else begin
            if (noisy_ff2 == stable_val) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
                if (cnt == 20'hFFFFF) begin
                    stable_val <= noisy_ff2;
                    clean_out  <= noisy_ff2;
                    cnt        <= 0;
                end
            end
        end
    end
endmodule
