`include "hues.sv"
`include "pwm.sv"

// hues top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] R_value;
    logic [$clog2(PWM_INTERVAL) - 1:0] G_value;
    logic [$clog2(PWM_INTERVAL) - 1:0] B_value;
    logic red_pwm;
    logic green_pwm;
    logic blue_pwm;

    hues #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk), 
        .R_value        (R_value),
        .G_value        (G_value),
        .B_value        (B_value)
    );

    pwm #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) u2 (
        .clk(clk),
        .pwm_value(R_value),
        .pwm_out(red_pwm)
    );

    pwm #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) u3 (
        .clk(clk),
        .pwm_value(G_value),
        .pwm_out(green_pwm)
    );

    pwm #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) u4 (
        .clk(clk),
        .pwm_value(B_value),
        .pwm_out(blue_pwm)
    );

    assign RGB_R   = ~red_pwm;
    assign RGB_G = ~green_pwm;
    assign RGB_B  = ~blue_pwm;

endmodule
