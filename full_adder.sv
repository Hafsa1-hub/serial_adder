
//parameter WIDTH = 8;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  full_adder.sv                                                                               //
//                                                                                                                 //
//    Description   :  Full adder will perform adder operation for given input A+B+C and assign it to output       //
//                                                                                                                 //
//    Inputs        :  a_out_i,b_out_i, c_i, sum_out,cout                                                              //
//                                                                                                                 //
//    Outputs       :   sum_out, c_out                                                                             //
//                                                                                                                 //
//                                                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////



module full_adder (
    input  a_out_i,
    input  b_out_i,
    input  c_i,
    output sum_o,
    output c_o
);
  assign sum_o = a_out_i ^ b_out_i ^ c_i;
  assign c_o   = ((a_out_i & b_out_i) | (b_out_i & c_i) | (c_i & a_out_i));

endmodule

/*
* ///test bench

module full_adder_tb;
  reg  a_out_i;
  reg  b_out_i;
  reg  c_i;
  reg  cout;
  wire sum;
  full_adder FA (
      .a_out_i(a_out_i),
      .b_out_i(b_out_i),
      .c_i(c_i),
      .cout(cout),
      .sum(sum)
  );
  initial begin
    a_out_i = 0;
    b_out_i = 0;
    c_i = 0;
    // carry_in =D;
    #10;
    a_out_i = 0;
    b_out_i = 1;
    #10 a_out_i = 1;
    b_out_i = 0;
    c_i = 1;
    #10 a_out_i = 1;
    b_out_i = 1;
    c_i = 0;
    #10 a_out_i = 1;
    b_out_i = 1;
    c_i = 1;

    #500 $stop;

  end
endmodule*/
