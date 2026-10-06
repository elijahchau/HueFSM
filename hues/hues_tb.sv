`timescale 10ns/10ns
`include "top.sv"

module hues_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk(clk),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );

    initial begin
        $dumpfile("hues.vcd");
        $dumpvars(0, hues_tb);
        #100000000
        
        $display("Test bench complete!");
        $finish;
    end

    always begin
        #4.1667; // 12 MHz = 83.33 ns period, half period = 41.667 ns
        clk = ~clk;
    end

endmodule

