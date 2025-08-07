//parameter WIDTH = 8;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  Paralle to serial shift Register                                                            //
//                                                                                                                 //
//    Description   :  For each Clock Data will be loaded if start bit is high  Data will Shift when Enabe is high //
//                                                                                                                 //
//    Inputs        :  clk, reset_n, load enable, start a_i ,b_i                                                       //
//                                                                                                                 //
//    Outputs       :   a_o, b_o                                                                               //
//                                                                                                                 //
//                                                                                                                 //
//////////////////////////////////////////://///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////





module parallel_to_serial_sr (
    input wire clk_i,
    input reset_n_i,
    input wire load_i,
    input wire enable_i,
    //input wire start_i,
    input wire [WIDTH-1:0] a_i,
    input wire [WIDTH-1:0] b_i,
    output reg a_o,
    output reg b_o
);

  reg [WIDTH-1:0] temp_a;
  reg [WIDTH-1:0] temp_b;

  always @(posedge clk_i) begin
    if (!reset_n_i) begin
      a_o <= 0;
      b_o <= 0;
    end else begin
      if (load_i) begin
        temp_a <= a_i;  
        temp_b <= b_i;
      end
      if (enable_i) begin
        temp_a <= temp_a >> 1;
        temp_b <= temp_b >> 1;
        a_o <= temp_a[0];
        b_o <= temp_b[0];
      end
    end
  end
endmodule


/*
module shift_register_parallel_to_serial_tb ();
  reg clk;
  reg reset_n;
  reg start;
  reg [WIDTH -1:0] a_i;
  reg [WIDTH -1:0] b_i;
  wire a_o;
  wire b_o;
  reg load;
  reg enable;

  shift_register_parallel_to_serial PS (
      .clk(clk),
      .reset_n(reset_n),
      .start(start),
      .load(load),
      .enable(enable),
      .a_i(a_i),
      .b_i(b_i),
      .a_o(a_o),
      .b_o(b_o)
  );
  initial clk = 0;
  always #5 clk = ~(clk);
  initial begin
    reset_n = 0;
    #10;
    reset_n = 1;
    a_i = 'hff;
    b_i = 'hff;
    load = 1;
    #10;
    enable  = 1;
    reset_n = 1;
    #10 a_i = 'hff;
    #10 b_i = 'hff;
    $display("TB:::The data of a_i is %b and b_i is %b ", a_i, b_i);
    #200;
    $stop;
  end
endmodule
*/
