// Hues

module hues #(
    parameter INC_DEC_INTERVAL = 10000,     // CLK freq = 12MHz, 10k cycles = 0.833 ms. Multiply by 200 steps to get 166.7ms, 1/6 of 1 second
    parameter INC_DEC_MAX = 200,            // Brighten by 200 increments per state, state transition takes 0.2 sec
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, PWM has 1200 values, incremented. One PWM cycle takes 100 us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX // how much increment PWM value per step
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] R_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] G_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] B_value
);

    // 4 possible states of each RGB channel
    localparam COLOR_OFF = 2'b00;
    localparam COLOR_INC = 2'b01;
    localparam COLOR_DEC = 2'b10;
    localparam COLOR_ON = 2'b11;

    // State variables, diagram starts Red ON, Green INC, Blue OFF
    logic [1:0] red_state = COLOR_ON;
    logic [1:0] green_state = COLOR_INC;
    logic [1:0] blue_state = COLOR_OFF;


    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        R_value = PWM_INTERVAL;
        G_value = 0;
        B_value = 0;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition) begin

        // 60 to 120 (0 to 60 is handled by initial state)
        if (red_state == COLOR_ON && green_state == COLOR_INC && blue_state == COLOR_OFF) begin
            red_state <= COLOR_DEC;
            green_state <= COLOR_ON;
            blue_state <= COLOR_OFF;
        end

        // 120 to 180
        else if (red_state == COLOR_DEC && green_state == COLOR_ON && blue_state == COLOR_OFF) begin
            red_state <= COLOR_OFF;
            green_state <= COLOR_ON;
            blue_state <= COLOR_INC;
        end

        // 180 to 240
        else if (red_state == COLOR_OFF && green_state == COLOR_ON && blue_state == COLOR_INC) begin
            red_state <= COLOR_OFF;
            green_state <= COLOR_DEC;
            blue_state <= COLOR_ON;
        end

        // 240 to 300
        else if (red_state == COLOR_OFF && green_state == COLOR_DEC && blue_state == COLOR_ON) begin
            red_state <= COLOR_INC;
            green_state <= COLOR_OFF;
            blue_state <= COLOR_ON;
        end

        // 300 to 360
        else if (red_state == COLOR_INC && green_state == COLOR_OFF && blue_state == COLOR_ON) begin
            red_state <= COLOR_ON;
            green_state <= COLOR_OFF;
            blue_state <= COLOR_DEC;
        end

        // Magenta to Red
        else if (red_state == COLOR_ON && green_state == COLOR_OFF && blue_state == COLOR_DEC) begin
            red_state <= COLOR_ON;
            green_state <= COLOR_INC;
            blue_state <= COLOR_OFF;
        end
    end


    // Compute the next state of the FSM
    // always_comb begin
    //     next_state = 1'bx;
    //     case (current_state)
    //         PWM_INC:
    //             next_state = PWM_DEC;
    //         PWM_DEC:
    //             next_state = PWM_INC;
    //     endcase
    // end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (red_state)
            COLOR_OFF:
                R_value <= 0;
            COLOR_ON:
                R_value <= PWM_INTERVAL;
            COLOR_INC:
                R_value <= R_value + INC_DEC_VAL;
            COLOR_DEC:
                R_value <= R_value - INC_DEC_VAL;
        endcase

        case (green_state)
            COLOR_OFF:
                G_value <= 0;
            COLOR_ON:
                G_value <= PWM_INTERVAL;
            COLOR_INC:
                G_value <= G_value + INC_DEC_VAL;
            COLOR_DEC:
                G_value <= G_value - INC_DEC_VAL;
        endcase

        case (blue_state)
            COLOR_OFF:
                B_value <= 0;
            COLOR_ON:
                B_value <= PWM_INTERVAL;
            COLOR_INC:
                B_value <= B_value + INC_DEC_VAL;
            COLOR_DEC:
                B_value <= B_value - INC_DEC_VAL;
        endcase
    end


    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
