module fsm #(
    parameter WIDTH = 8
)(
    input  logic clk_i,
    input  logic resetn_i,
    input  logic start_i,
    output logic reset_o,
    output logic load_o,
    output logic enable_o,
    output logic done_o  // NEW: High when shift operation is complete
);

  typedef enum logic [1:0] {
    RESET = 2'b00,
    LOAD  = 2'b01,
    SHIFT = 2'b10,
    DONE  = 2'b11  // NEW: Optional DONE state for clarity
  } state_t;

  state_t current_state, next_state;

  logic [WIDTH-1:0] count;

  // Edge detection for start_i
  logic start_i_d, start_pulse;
  always_ff @(posedge clk_i or negedge resetn_i) begin
    if (!resetn_i)
      start_i_d <= 0;
    else
      start_i_d <= start_i;
  end
  assign start_pulse = start_i & ~start_i_d;

  // FSM state register
  always_ff @(posedge clk_i or negedge resetn_i) begin
    if (!resetn_i)
      current_state <= RESET;
    else
      current_state <= next_state;
  end

  // Counter logic for SHIFT
  always_ff @(posedge clk_i or negedge resetn_i) begin
    if (!resetn_i)
      count <= 0;
    else if (current_state == SHIFT)
      count <= count + 1;
    else
      count <= 0;
  end

  // Next state logic
  always_comb begin
    next_state = current_state;
    unique case (current_state)
      RESET: begin
        if (start_pulse)
          next_state = LOAD;
      end
      LOAD: begin
        next_state = SHIFT;
      end
      SHIFT: begin
        if (count == WIDTH - 1)
          next_state = DONE;
      end
      DONE: begin
        if (start_pulse)
          next_state = LOAD;
        else
          next_state = RESET;
      end
      default: next_state = RESET;
    endcase
  end

  // Output logic
  assign reset_o  = (current_state == RESET);
  assign load_o   = (current_state == LOAD);
  assign enable_o = (current_state == SHIFT) && (count < WIDTH);
  assign done_o   = (current_state == DONE);

endmodule














