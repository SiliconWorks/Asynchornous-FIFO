`timescale 1ns / 1ps


module debounce (
    input  wire clk,
    input  wire rst,
    input  wire noisy_in,
    output reg  clean_out
);
    reg [19:0] cnt;
    reg sync_ff;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt       <= 0;
            sync_ff   <= 0;
            clean_out <= 0;
        end else begin
            if (noisy_in == sync_ff) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
                if (cnt == 20'hFFFFF) begin
                    sync_ff   <= noisy_in;
                    clean_out <= noisy_in;
                    cnt       <= 0;
                end
            end
        end
    end
endmodule

