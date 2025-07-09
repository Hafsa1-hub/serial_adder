
//parameter WIDTH=8;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  serial_parallel.sv                                                                          //
//                                                                                                                 //
//    Description   :  Serial data will be shifted when enable_i is high                                             //
//                                                                                                                 //
//    Inputs        :  clk_i,reset_n_i.enable_i,sum_o_out_i                                                                  //
//                                                                                                                 //
//    Outputs       :  sum_o                                                                                         //
//                                                                                                                 //
//
//                                                                                                                 //
//                                                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module serial_parallel (
    input clk_i,
    input reset_n_i,
    input enable_i,
    input sum_o_out_i,
    output reg [WIDTH-1:0] sum_o
);

  reg [WIDTH-1:0] reg_data;
  reg [3:0] count;
  always @(posedge clk_i) begin
    if (reset_n_i) begin
      reg_data <= '0;
      count <= 0;
    end else if (enable_i) begin

      reg_data <= {sum_o_out_i, reg_data[WIDTH-1:1]};  // Shift right

      sum_o <= reg_data;
      count <= count + 1;
    end
    /*if (count == WIDTH) begin
      sum_o <= reg_data;
      count <= 0;
    end*/
  end
  //assign sum_o = reg_data;
endmodule






// test bench*/

module shift_register_serial_parallel_tb;
  reg clk_i;
  reg reset_n_i;
  reg sum_o_out_i;
  reg enable_i;
  wire [WIDTH:0] sum_o;

  shift_register_serial_parallel SP (
      .clk_i(clk_i),
      .reset_n_i(reset_n_i),
      .sum_o_out_i(sum_o_out_i),
      .enable_i(enable_i),
      .sum_o(sum_o)
  );
  initial begin
    clk_i = 0;
    reset_n_i = 0;
    enable_i = 'd0;
  end
  always #5 clk_i = ~clk_i;
  initial begin
    #10 reset_n_i = 1;
    #20 reset_n_i = 0;
    sum_o_out_i = 1;
    //$display("The value of sum_o_out_i is %d ",sum_o_out_i);
    enable_i = 'd1;
    sum_o_out_i = 1;
    //$display("The value of sum_o_out_i is %d ",sum_o_out_i);
    sum_o_out_i = 1;
    //     $display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #10 sum_o_out_i = 1;
    //   $display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #10 sum_o_out_i = 0;
    //  $display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #10 sum_o_out_i = 0;
    //$display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #10 sum_o_out_i = 0;
    //     $display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #10 sum_o_out_i = 1;
    //   $display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #10 sum_o_out_i = 0;
    //  $display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #10 sum_o_out_i = 1;
    //$display("The value of sum_o_out_i is %d ",sum_o_out_i);
    #100;
    $stop;
  end
endmodule

