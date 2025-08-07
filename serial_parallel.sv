
//parameter WIDTH=8;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////    FILE Name     :  serial_parallel.sv                                                                       //   
//                                                                                                                //
//      Description   :  Serial data will be shifted when enable_i is high                                        //                           
//      Inputs        :  clk_i,reset_n_i.enable_i,sum_o_out_i                                                     //           
//                                                                                                                //
//      Outputs       :  sum_o                                                                                    //     
//                                                                                                                //                                                                
//                                                                                                                //
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

     // sum_o <= reg_data;
      count <= count + 1;
      if (count== WIDTH + 1) count<=0 ;
    end
    /*if (count == WIDTH) begin
      sum_o <= reg_data;
      count <= 0;
    end*/
  end
  assign sum_o = reg_data;
endmodule
/*
module serial_parallel #(
    parameter WIDTH = 8
) (
    input clk_i,
    input reset_n_i,
    input enable_i,
    input sum_o_out_i,
    output reg [WIDTH-1:0] sum_o
);

  reg [WIDTH-1:0] reg_data;
  reg [$clog2(WIDTH):0] count;

  always @(posedge clk_i) begin
    if (reset_n_i) begin
      reg_data <= '0;
      count <= 0;
    end else if (enable_i) begin
      reg_data <= {sum_o_out_i, reg_data[WIDTH-1:1]};  // Shift right
      count <= count + 1;
    end
  end

  assign sum_o = reg_data;

endmodule

*/

