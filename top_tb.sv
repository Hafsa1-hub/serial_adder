`include "top.sv"

module top_sb_check_fsm;

  bit [WIDTH -1:0] A_sb;
  bit [WIDTH -1:0] B_sb;
  reg clk;
  reg reset_n;
  reg start;
  wire [WIDTH : 0] sum_out_sb;
  reg [WIDTH : 0] final_sum_o;
  top top_sa (
      .clock_top_i(clk),
      .resetn_top_i(reset_n),
      .start_top_i(start),:1
      
      .a_top_i(A_sb),
      .b_top_i(B_sb),
      .final_sum_o(sum_out_sb)
  );

  always @(start & reset_n) begin
    self_check(A_sb, B_sb, final_sum_o);
  end

  task self_check(input [WIDTH -1:0] A_sb, input [WIDTH -1:0] B_sb, output [WIDTH : 0] sum_out);

    sum_out = A_sb + B_sb;

    wait (top_sa.sp_sr.count == WIDTH)
      if (sum_out == top_sa.final_sum_o) $display("Test pass");
      else $display("Test Fail");

  endtask

  //always@(*) self_check(A_sb,B_sb,final_sum_o);
  initial clk = 0;
  always #5 clk = ~(clk);

  initial begin
    start   = 0;
    reset_n = 0;
    #10;
  end
  initial begin
    reset_n = 0;
    start   = 0;
    #20;
    repeat (4) begin
      reset_n = 1;
      start = 1;
      //A_sb = 'd32;//$random;
      A_sb = 'b11101011;  //$random;
      B_sb = 'b11111011;  //$random;
      #20 start = 0;
      #200;
      start = 1;
      A_sb  = 'b11000000;  //$random;
      B_sb  = 'b10000000;  //$random;
      #20 start = 0;
      #100;
      start = 1;
      A_sb  = 'd126;  //$random;
      B_sb  = 'd240;  //$random;
      #20 start = 0;
      #100;
      start = 1;
      A_sb  = 'b1010101;  //$random;
      B_sb  = 'b1010101;  //$random;
      #20 start = 0;
      #100;

    end
    @(posedge clk);  // apply reset
    reset_n = 1;
    @(posedge clk);  // come out of reset
    A_sb  = $random;
    B_sb  = $random;

    start = 1;
    @(posedge clk);  // go to LOAD state
    A_sb = $random;
    B_sb = $random;

    start = 0;
    reset_n = 0;     // THIS triggers the missing condition
    @(posedge clk);
    A_sb = $random;
    B_sb = $random;

    start = 0;
    reset_n = 1;
    @(posedge clk);
    clk = 0;
    reset_n = 0;
    start = 0;

    // Apply Reset
    @(posedge clk);
    reset_n = 0;
    @(posedge clk);
    reset_n = 1;  // Come out of reset

    // Test: RESET → LOAD
    start   = 1;
    @(posedge clk);

    // Test: LOAD → SHIFT (start=0)
    start = 0;
    @(posedge clk);

    // Test: SHIFT with count < WIDTH
    repeat (3) @(posedge clk);  // Let SHIFT stay with enable = 1

    // Test: SHIFT → LOAD again (start=1)
    start = 1;
    @(posedge clk);

    // Test: LOAD with reset_n=0 → go back to RESET
    start   = 1;
    reset_n = 0;
    @(posedge clk);

    // Test: back to RESET state, ensure transitions again
    reset_n = 1;
    @(posedge clk);

    start = 1;
    @(posedge clk);  // LOAD
    start = 0;
    @(posedge clk);  // SHIFT

    // Final case: SHIFT state with start = 0 and reset_n = 0
    // To hit the missing (start=0, reset_n=0) condition coverage
    reset_n = 0;
    @(posedge clk);

    // Restore normal values
    reset_n = 1;
    start   = 1;
    @(posedge clk);
    reset_n = 0;
    start   = 0;
    #20;
    repeat (40) begin
      reset_n = 1;
      start = 1;
      A_sb = $random;
      B_sb = $random;
      #20 start = 0;
      #100;
    end
    repeat (10) begin
      reset_n = 1;
      start = 1;
      A_sb = $random;
      B_sb = $random;
      #20 start = 0;
      #20 start = 1;
      reset_n = 0;
      #40;
    end
    repeat (10) begin
      reset_n = 0;
      start = 1;
      A_sb = $random;
      B_sb = $random;
      // #20 start  = 0;
      //#20 start  = 1;
      #40 reset_n = 1;
      #40;
    end
    #20;
    repeat (5) begin
      reset_n = 0;
      start = 1;
      A_sb = $random;
      B_sb = $random;
      #20 start = 0;
      #50;
      start   = ~(start);
      reset_n = ~(reset_n);
    end
    repeat (5) begin
      reset_n = 1;
      start = 0;
      A_sb = $random;
      B_sb = $random;
      #20 start = 0;
      #50;
      start   = ~(start);
      reset_n = ~(reset_n);
    end
    start = 1;
    A_sb  = 'h00;
    B_sb  = 'h00;
    #20 start = 0;
    reset_n = 1;
    #10;
    start = 1;
    A_sb = 'h20;
    B_sb = 'h30;
    reset_n = 0;

    #10 start = 0;
    reset_n = 0;
    #10;

    #10 start = 0;
    reset_n = 1;
    A_sb = $random;
    B_sb = $random;
    #20 start = 0;
    #100;

    #20 start = 0;
    reset_n = 1;
    #10;
    A_sb = $random;
    B_sb = $random;
    #20 start = 0;
    #100;

    start = 1;
    reset_n = 1;
    A_sb = $random;
    B_sb = $random;
    #20 start = 0;
    #100;

    A_sb = 'h20;
    B_sb = 'h30;
    reset_n = 0;
    #10 start = 0;
    reset_n = 0;
    #10;
    #200 $stop;

  end
  //$display("Finished simulation for full coverage.");
  //$finish;
  //end
endmodule

// TEST BENCH 
module top_tb ();
  reg [WIDTH -1:0] A_sb;
  reg [WIDTH -1:0] B_sb;
  reg clock_sb;
  reg resetn_sb;
  reg start_sb;
  wire [WIDTH : 0] sum_out_sb;

  top SF (
      .clock_top_i(clock_sb),
      .resetn_top_i(resetn_sb),
      .start_top_i(start_sb),
      .a_top_i(A_sb),
      .b_top_i(B_sb),
      .final_sum_o(sum_out_sb)
  );
  initial clock_sb = 0;
  always #5 clock_sb = ~(clock_sb);

  initial begin
    resetn_sb = 0;
    start_sb  = 0;
    #20;
    repeat (4) begin
      resetn_sb = 1;
      start_sb = 1;
      //A_sb = 'd32;//$random;
      A_sb = 'b11101011;  //$random;
      B_sb = 'b11111011;  //$random;
      #20 start_sb = 0;
      #200;
      start_sb = 1;
      A_sb = 'b11000000;  //$random;
      B_sb = 'b10000000;  //$random;
      #20 start_sb = 0;
      #100;
      start_sb = 1;
      A_sb = 'd126;  //$random;
      B_sb = 'd240;  //$random;
      #20 start_sb = 0;
      #100;
      start_sb = 1;
      A_sb = 'b1010101;  //$random;
      B_sb = 'b1010101;  //$random;
      #20 start_sb = 0;
      #100;

    end  /*
 repeat (10) begin
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #20 start_sb  = 1;
     resetn_sb = 0;
     #40;
  end
 repeat (10) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
    // #20 start_sb  = 0;
     //#20 start_sb  = 1;
     #40 resetn_sb = 1;
     #40;
  end

    #20;  
  repeat (5) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end
  repeat (5) begin
     resetn_sb = 1;
     start_sb  = 0;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end
repeat (5) begin
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end
repeat (8) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end

repeat (5) begin
     resetn_sb = 0;
     start_sb  = 0;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #50;
     start_sb = ~(start_sb);
     resetn_sb = ~(resetn_sb);
  end


 repeat (2) begin
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = 'd32;//$random;
     B_sb = 'd35;//$random;
     #20 start_sb  = 0;
     #50;
  end

    resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #10;
      resetn_sb = 0;

     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     start_sb  = 0;
     #30;
     resetn_sb = 1;

     #50;
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
     start_sb  = 1;
     #30;
     resetn_sb = 1;
     #30;
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
#40 resetn_sb = 0;
     start_sb  = 1;
#40;
#30;
     resetn_sb = 0;
     start_sb  = 0;
     A_sb = $random;
     B_sb = $random;
#40;
#30;
     resetn_sb = 1;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
#40;

#30;
     resetn_sb = 0;
     start_sb  = 1;
     A_sb = $random;
     B_sb = $random;
#40;





     A_sb = $random;
     B_sb = $random;

    start_sb  = 1;
     A_sb = 'h00;
     B_sb = 'h00;
     #20 start_sb  = 0;
      resetn_sb = 1;
     #10;
     start_sb  = 1;
     A_sb = 'h20;
     B_sb = 'h30;
     resetn_sb = 0;

     #10 start_sb  = 0;
     resetn_sb  = 0;
     #10;

 #10 start_sb  = 0;
     resetn_sb  = 1;
 A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #100;

  #20 start_sb  = 0;
      resetn_sb = 1;
     #10;
  A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #100;
 
      start_sb  = 1;
      resetn_sb = 1;
   A_sb = $random;
     B_sb = $random;
     #20 start_sb  = 0;
     #100;
 
     A_sb = 'h20;
     B_sb = 'h30;
     resetn_sb = 0;
     #10 start_sb  = 0;
     resetn_sb  = 0;
     #10;
*/
    /*
repeat(20) begin
    resetn_sb = 1;
     start_sb  = 1;
     A_sb = 'd25;
     B_sb = 'd25;
#20;
     start_sb  = 0;
    // start_sb  = 0;
    resetn_sb = 0;
#20;
 start_sb  = ~(start_sb);
       resetn_sb = ~(resetn_sb);

end
//end

 //////  load



     repeat(500) begin  
       resetn_sb = 1;
       start_sb  = 1;
       A_sb = $urandom;
       B_sb = $urandom;
       #20 start_sb  = 0;
       #100;
     end
     repeat(10) begin
       resetn_sb = 0;
       start_sb  = 1;
       A_sb = $urandom_range('d0,'d255);
       B_sb = $urandom_range('d0,'d255);
       #20 start_sb  = 0;
       #100;
     end
     #50;

       resetn_sb = 1;
       start_sb  = 0;
       A_sb = $urandom_range('d0,'d255);
       B_sb = $urandom_range('d0,'d255);
     #50;
     repeat (4) begin
       start_sb  = ~(start_sb);
       resetn_sb = ~(resetn_sb);
       A_sb = $urandom_range('d50,'d100);
       B_sb = $urandom_range('d40,'d60);
       #40;
       A_sb = 'D255;
       B_sb = 'D255;
       #50;
     end   
      #50;
      start_sb =0; resetn_sb=0;
      #50;
      start_sb =1; resetn_sb=0;
      #50;
      start_sb =0; resetn_sb=1;
      #50;
      start_sb =1; resetn_sb=1;
      #50;
      start_sb =1; resetn_sb=0;
      #50;
      start_sb =0; resetn_sb=1;
      #50;
     repeat (2) begin
       start_sb = ~(start_sb);
       resetn_sb = ~(resetn_sb);
       A_sb = 'h00;
       B_sb = 'h00;
       #40;
       A_sb = 'D255;
       B_sb = 'D255;
       #50;
     end   

     #20;
     resetn_sb = 0;start_sb = 0;
       A_sb = $random;
       B_sb = $random;
       #20 start_sb  = 0;
       #100;

     #50;
       resetn_sb = 1;start_sb = 1;
       A_sb = $random;
       B_sb = $random;


     #50;
       resetn_sb = 1;start_sb = 0;
       A_sb = $random;
       B_sb = $random;

     #50;
       resetn_sb = 1;start_sb = 1;
       A_sb = $random;
       B_sb = $random;

 #50; resetn_sb = 0;start_sb = 1;


       A_sb = $random;
       B_sb = $random;
*/
    // #20 start_sb  = 0;
    #300 $stop;
  end
endmodule















