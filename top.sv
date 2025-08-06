
parameter int WIDTH = 8;


//parameter WIDTH=8;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  top.sv                                                                                    //
//                                                                                                                //
//    Description   :  All the sub block modules are included                                                     //
//                                                                                                                //
//    Inputs        :  clock_top_i,reset_n_top,a_top_i b_top_i,start_top_i                                                //
//                                                                                                                //
//    Outputs       :  sum_top                                                                                    //
//                                                                                                                //
//
//                                                                                                                //
//                                                                                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////





`include "fsm.sv"
`include "full_adder.sv"
`include "parallel_to_serial_sr.sv"
`include "serial_parallel.sv"
`include "d_ff.sv"

module top (

    input [WIDTH-1:0] a_top_i,
    input [WIDTH-1:0] b_top_i,
    input clock_top_i,
    input resetn_top_i,
    input start_top_i,
    output reg [WIDTH:0] final_sum_o
);
  reg a_out_top;
  reg [WIDTH-1:0] sum_top;
  reg b_out_top;
  reg reset_top;
  reg load_top;
  reg enable_top;
  reg cin_top;
  reg cout_top;
  reg sum_out_top;

  //PISO REGISTER
  parallel_to_serial_sr ps (
      .clk_i(clock_top_i),
      .reset_n_i(resetn_top_i),
      //.start(start_top_i),
      .load_i(load_top),
      .enable_i(enable_top),
      .a_i(a_top_i),
      .b_i(b_top_i),
      .a_o(a_out_top),
      .b_o(b_out_top)
  );

  // FULL ADDER
  full_adder fa (
      .a_out_i(a_out_top),
      .b_out_i(b_out_top),
      .c_i(cin_top),
      .c_o(cout_top),
      .sum_o(sum_out_top)  //output

  );

  // D_FLIP_FLOP

  d_ff dflip_flop (
      .clk_i(clock_top_i),
      .reset_i(reset_top),
      .q_o(cin_top),
      .data_i(cout_top)
  );


  //FSM

  fsm fsm_states (
      .reset_on_i(resetn_top_i),
      .start_i   (start_top_i),
      .clk_i     (clock_top_i),
      .reset_o   (reset_top),
      .load_o    (load_top),
      .enable_o  (enable_top)
  );



  // SIPO REGISTER
  serial_parallel sp_sr (
      .clk_i(clock_top_i),
      .reset_n_i(reset_top),
      .sum_o(sum_top),
      .sum_o_out_i(sum_out_top),
      .enable_i(enable_top)
      // .load(load)
  );


  //assign final_sum_o = (});
  always @(sp_sr.count) begin
    if (sp_sr.count == WIDTH + 'd1) begin
      final_sum_o = ({cin_top, sum_top});
    end else begin
      final_sum_o = final_sum_o;
    end
  end
endmodule


