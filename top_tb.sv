`include "top.sv"

module top_sb_check_fsm;

  parameter WIDTH = 8;

  bit [WIDTH -1:0] A_sb;
  bit [WIDTH -1:0] B_sb;
  reg clk;
  reg reset_n;
  reg start;
  wire [WIDTH : 0] sum_out_sb;
  reg [WIDTH : 0] final_sum_o;
  bit check_trigger;

  top top_sa (
      .clock_top_i(clk),
      .resetn_top_i(reset_n),
      .start_top_i(start),
      .a_top_i(A_sb),
      .b_top_i(B_sb),
      .final_sum_o(sum_out_sb)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Self-check task
  task self_check(input [WIDTH -1:0] A, input [WIDTH -1:0] B, input [WIDTH :0] ref_sum);
    reg [WIDTH:0] expected;
    begin
      expected = A + B;
      wait (top_sa.sp_sr.count == WIDTH);
      if (expected == ref_sum)
        $display("Test PASS: %0d + %0d = %0d", A, B, ref_sum);
      else
        $display("Test FAIL: %0d + %0d != %0d (Expected)", A, B, ref_sum);
    end
  endtask

  // Trigger check on demand
  always @(posedge clk) begin
    if (check_trigger)
      self_check(A_sb, B_sb, sum_out_sb);
  end

  // Stimulus task
  task apply_vectors(input [WIDTH-1:0] A, input [WIDTH-1:0] B);
    begin
      @(posedge clk);
      A_sb = A;
      B_sb = B;
      start = 1;
      @(posedge clk);
      start = 0;
      check_trigger = 1;
      @(posedge clk);
      check_trigger = 0;
    end
  endtask

  // Initial stimulus
  initial begin
    reset_n = 0;
    start   = 0;
    check_trigger = 0;
    #20;
    reset_n = 1;

    // Basic patterns
    apply_vectors(8'b11101011, 8'b11111011);
    apply_vectors(8'b11000000, 8'b10000000);
    apply_vectors(8'd126, 8'd240);
    apply_vectors(8'b01010101, 8'b01010101);

    // Random patterns
    repeat (5) begin
      apply_vectors($random, $random);
    end

    // Special transitions
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;
    @(posedge clk);
    reset_n = 0;
    @(posedge clk);
    reset_n = 1;
    @(posedge clk);
    apply_vectors($random, $random);

    // Hit start=0 and reset_n=0
    start   = 0;
    reset_n = 0;
    @(posedge clk);
    reset_n = 1;

    // Loop cases for coverage
    repeat (10) begin
      start = 1;
      reset_n = 1;
      apply_vectors($random, $random);
      reset_n = 0;
      @(posedge clk);
    end

    repeat (10) begin
      start = 1;
      reset_n = 0;
      apply_vectors($random, $random);
      reset_n = 1;
      @(posedge clk);
    end

    repeat (5) begin
      reset_n = 0;
      start = 1;
      apply_vectors($random, $random);
      start = ~start;
      reset_n = ~reset_n;
      @(posedge clk);
    end

    repeat (5) begin
      reset_n = 1;
      start = 0;
      apply_vectors($random, $random);
      start = ~start;
      reset_n = ~reset_n;
      @(posedge clk);
    end

    apply_vectors('h00, 'h00);
    apply_vectors('h20, 'h30);
    reset_n = 0;
    @(posedge clk);
    reset_n = 1;

    // Final round of testing
    repeat (10) apply_vectors($random, $random);

    #200 $stop;
  end

endmodule


