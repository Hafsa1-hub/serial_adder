
`include "top.sv"

module top_sb_check_fsm;

  parameter WIDTH = 8;

  bit [WIDTH-1:0] A_sb;
  bit [WIDTH-1:0] B_sb;
  reg clk;
  reg reset_n;
  reg start;
  wire [WIDTH:0] sum_out_sb;

  // DUT instance
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

  // ----------------- Reset Control -----------------
  function void set_reset(input logic reset);
    reset_n = reset;
    $display(">>> set_reset(%0b) at time %0t", reset, $time);
  endfunction

  function void realize_reset(input logic reset);
    reset_n = reset;
    $display(">>> realize_reset(%0b) at time %0t", reset, $time);
  endfunction

  task reset_driver();
    set_reset(0);
    @(posedge clk);
    realize_reset(1);
  endtask

  // ----------------- Start Signal Control -----------------
  task assert_start();
    start = 1;
    $display(">>> assert_start() at time %0t", $time);
  endtask

  task deassert_start();
    start = 0;
    $display(">>> deassert_start() at time %0t", $time);
  endtask

  task pulse_start();
    assert_start();
    @(posedge clk);
    deassert_start();
  endtask

  // ----------------- Self Check Task -----------------
  task self_check(input [WIDTH-1:0] A, input [WIDTH-1:0] B, input [WIDTH:0] ref_sum);
    reg [WIDTH:0] expected;
    begin
      expected = A + B;
      wait (top_sa.sp_sr.count == WIDTH);
      if (expected == ref_sum)
        $display("PASS: %0d + %0d = %0d", A, B, ref_sum);
      else
        $display("FAIL: %0d + %0d != %0d (expected %0d)", A, B, ref_sum, expected);
    end
  endtask

  // ----------------- Stimulus Application -----------------
  task apply_vectors(input [WIDTH-1:0] A, input [WIDTH-1:0] B);
    begin
      @(posedge clk);
      A_sb = A;
      B_sb = B;
      pulse_start();
      self_check(A_sb, B_sb, sum_out_sb);
      repeat (WIDTH+5) @(posedge clk);
      reset_driver();
    end
  endtask

  // ----------------- Main Test Sequence -----------------
  initial begin
    reset_n = 0;
    start = 0;

    #20 realize_reset(1);

    // Basic test cases
    apply_vectors(8'b11101011, 8'b11111011);
    apply_vectors(8'b11000000, 8'b10000000);
    apply_vectors(8'd126, 8'd240);
    apply_vectors(8'b01010101, 8'b01010101);

    // Random test cases
    repeat (10) apply_vectors($urandom_range(0, 255), $urandom_range(0, 255));

    // Edge case: both 0
    apply_vectors('h00, 'h00);

    // Max value test
    apply_vectors('hFF, 'hFF);

    // Mid-sequence reset pulse
    @(posedge clk); set_reset(0);
    @(posedge clk); realize_reset(1);
    apply_vectors($urandom_range(0, 255), $urandom_range(0, 255));

    // Corner case: start = 0, reset = 0
    start = 0;
    set_reset(0);
    @(posedge clk);
    realize_reset(1);

    // Functional coverage sweep
    repeat (10) begin
      apply_vectors($urandom_range(0, 255), $urandom_range(0, 255));
      start = ~start;
      reset_n = ~reset_n;
      @(posedge clk);
    end

    // Final tests
    apply_vectors('h20, 'h30);
    set_reset(0);
    @(posedge clk); realize_reset(1);

    repeat (5) apply_vectors($random, $random);

    #200 $finish;
  end

  // ----------------- Trigger Check Monitor -----------------
 // always @(posedge clk) begin
  //  if (check_trigger)
    //  self_check(A_sb, B_sb, sum_out_sb);
  //end

endmodule


