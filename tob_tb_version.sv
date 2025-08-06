`include "top.sv"

module top_sb_check_fsm;

  // Parameters
  localparam WIDTH = 8;

  // Signals
  bit [WIDTH -1:0] A_sb;
  bit [WIDTH -1:0] B_sb;
  reg clk;
  reg reset_n;
  reg start;
  wire [WIDTH : 0] sum_out_sb;
  reg  [WIDTH : 0] expected_sum;

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

  // Task: Apply inputs and toggle start
  task automatic apply_input(input [WIDTH-1:0] a, input [WIDTH-1:0] b);
    A_sb = a;
    B_sb = b;
    start = 1;
    @(posedge clk);
    start = 0;
  endtask

  // Task: Self check after waiting for COUNT == WIDTH
  task automatic self_check(input [WIDTH-1:0] a, input [WIDTH-1:0] b);
    expected_sum = a + b;
    wait (top_sa.sp_sr.count == WIDTH);
    if (expected_sum == top_sa.final_sum_o)
      $display("PASS: A=%0d B=%0d SUM=%0d", a, b, top_sa.final_sum_o);
    else
      $display("FAIL: A=%0d B=%0d Expected=%0d Got=%0d", a, b, expected_sum, top_sa.final_sum_o);
  endtask

  // Task: Reset sequence
  task automatic reset_dut(input bit active);
    reset_n = active;
    @(posedge clk);
  endtask

  // Task: One full operation with check
  task automatic do_op_and_check(input [WIDTH-1:0] a, input [WIDTH-1:0] b);
    apply_input(a, b);
    self_check(a, b);
  endtask

  // Task: FSM transition testing
  task automatic fsm_tests();
    begin
      reset_dut(0);    // RESET
      reset_dut(1);    // Come out of reset

      apply_input($random, $random);
      @(posedge clk);
      apply_input($random, $random);
      start = 0;
      reset_dut(0);    // Trigger reset in middle of SHIFT
      @(posedge clk);

      reset_dut(1);
      apply_input($random, $random);
      start = 0;

      // SHIFT with count < WIDTH
      repeat (3) @(posedge clk);

      // Back to LOAD
      apply_input($random, $random);
      reset_dut(0);
      @(posedge clk);

      reset_dut(1);
      apply_input($random, $random);
      start = 0;
      @(posedge clk);

      // SHIFT with reset=0
      reset_dut(0);
      @(posedge clk);

      reset_dut(1);
      apply_input($random, $random);
      start = 1;
      @(posedge clk);
    end
  endtask

  // Task: Loop multiple random inputs
  task automatic apply_random(int count);
    repeat (count) begin
      bit [WIDTH-1:0] a = $urandom_range(0, 255);
      bit [WIDTH-1:0] b = $urandom_range(0, 255);
      do_op_and_check(a, b);
      #100;
    end
  endtask

  // Initial block for full test
  initial begin
    // Reset & initialization
    start = 0;
    reset_n = 0;
    #20;

    // Deterministic inputs
    do_op_and_check('b11101011, 'b11111011);
    do_op_and_check('b11000000, 'b10000000);
    do_op_and_check('d126, 'd240);
    do_op_and_check('b01010101, 'b01010101);

    // FSM transition path test
    fsm_tests();

    // More coverage conditions
    repeat (5) begin
      reset_n = 0; start = 1;
      A_sb = $random; B_sb = $random;
      #20 start = 0; #50;
      start = ~start; reset_n = ~reset_n;
    end

    repeat (5) begin
      reset_n = 1; start = 0;
      A_sb = $random; B_sb = $random;
      #20;
      start = ~start; reset_n = ~reset_n;
    end

    // Special patterns
    do_op_and_check('h00, 'h00);
    do_op_and_check('h20, 'h30);

    // Randomized sequences
    apply_random(10);

    #200;
    $stop;
  end

endmodule











//`include "top.sv"

module top_tb ();

  // Local parameters
  localparam WIDTH = 8;

  // Signals
  reg [WIDTH -1:0] A_sb;
  reg [WIDTH -1:0] B_sb;
  reg clock_sb;
  reg resetn_sb;
  reg start_sb;
  wire [WIDTH : 0] sum_out_sb;

  // DUT Instantiation
  top SF (
      .clock_top_i(clock_sb),
      .resetn_top_i(resetn_sb),
      .start_top_i(start_sb),
      .a_top_i(A_sb),
      .b_top_i(B_sb),
      .final_sum_o(sum_out_sb)
  );

  // Clock Generation
  initial clock_sb = 0;
  always #5 clock_sb = ~clock_sb;

  //-----------------------------------------
  // TASKS
  //-----------------------------------------

  // Apply Reset
  task apply_reset(input bit state);
    begin
      resetn_sb =0;
      @(posedge clock_sb);
    end
  endtask

  // Apply Start
  task apply_start(input bit state);
    begin
      start_sb = state;
      @(posedge clock_sb);
    end
  endtask

  // Apply Stimulus
  task apply_inputs(input [WIDTH-1:0] a, input [WIDTH-1:0] b);
    begin
      A_sb = a;
      B_sb = b;
    end
  endtask

  // Full Transaction Task
  task single_transaction(input [WIDTH-1:0] a, input [WIDTH-1:0] b);
    begin
      apply_inputs(a, b);
      apply_start(1);
      apply_start(0);
      repeat (10) @(posedge clock_sb); // Allow SHIFT to complete
    end
  endtask

  // Randomized Transactions
  task random_transactions(int count = 10);
    repeat (count) begin
      apply_inputs($urandom_range(0, 255), $urandom_range(0, 255));
      apply_start(1);
      apply_start(0);
      #20;
    end
  endtask

  // FSM Reset → Load → Shift Test
  task fsm_path_tests();
    begin
      apply_reset(0);
      @(posedge clock_sb);
      apply_reset(1);
      apply_start(1);
      @(posedge clock_sb); // LOAD

      apply_start(0);
      @(posedge clock_sb); // SHIFT

      repeat (3) @(posedge clock_sb); // Remain in SHIFT

      apply_start(1);
      @(posedge clock_sb); // LOAD again

      apply_reset(0);
      @(posedge clock_sb); // BACK to RESET

      apply_reset(1);
      @(posedge clock_sb);

      // Reapply full sequence
      apply_start(1); @(posedge clock_sb);
      apply_start(0); @(posedge clock_sb);
      apply_reset(0); @(posedge clock_sb);
    end
  endtask

  // Stress Test with Signal Flips
  task signal_toggle_test(int cycles = 5);
    repeat (cycles) begin
      apply_inputs($random, $random);
      start_sb   = ~start_sb;
      resetn_sb  = ~resetn_sb;
      #40;
    end
  endtask

  //-----------------------------------------
  // MAIN TEST SEQUENCE
  //-----------------------------------------
  initial begin
    $display("---- Starting Simulation ----");

    // Initial reset
    apply_reset(0);
    apply_start(0);
    #20;

    // Basic deterministic test vectors
    single_transaction('hEB, 'hFB);
    single_transaction('hC0, 'h80);
    single_transaction('d126, 'd240);
    single_transaction('b1010101, 'b1010101);

    // FSM path exploration
    fsm_path_tests();

    // Random transactions
    random_transactions(20);

    // Mixed toggling stress test
    signal_toggle_test(10);

    // Edge case: All zeroes
    single_transaction('h00, 'h00);

    // Edge case: Max values
    single_transaction('hFF, 'hFF);

    // More resets and randoms
    apply_reset(0);
    apply_inputs($random, $random);
    #20;

    apply_reset(1);
    single_transaction($random, $random);

    #100;
    $display("---- Simulation Finished ----");
    $stop;
  end

endmodule

