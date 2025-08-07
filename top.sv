

parameter int WIDTH = 8;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  top.sv                                                                                    //
//    Description   :  Top module integrating FSM, PISO, FA, DFF, and SIPO.                                      //
//    Inputs        :  clock_top_i, resetn_top_i, a_top_i, b_top_i, start_top_i                                  //
//    Outputs       :  final_sum_o                                                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`include "fsm.sv"
`include "full_adder.sv"
`include "parallel_to_serial_sr.sv"
`include "serial_parallel.sv"
`include "d_ff.sv"

module top (
    input  logic [WIDTH-1:0] a_top_i,
    input  logic [WIDTH-1:0] b_top_i,
    input  logic             clock_top_i,
    input  logic             resetn_top_i,
    input  logic             start_top_i,
    output logic [WIDTH:0]   final_sum_o
);

  // Internal signals
  logic                    a_out_top, b_out_top;
  logic                    reset_top, load_top, enable_top;
  logic                    cin_top, cout_top;
  logic                    sum_out_top;
  logic [WIDTH-1:0]        sum_top;

  // Parallel-In Serial-Out (PISO)
  parallel_to_serial_sr ps (
    .clk_i      (clock_top_i),
    .reset_n_i  (resetn_top_i),
    .load_i     (load_top),
    .enable_i   (enable_top),
    .a_i        (a_top_i),
    .b_i        (b_top_i),
    .a_o        (a_out_top),
    .b_o        (b_out_top)
  );

  // 1-bit Full Adder
  full_adder fa (
    .a_out_i    (a_out_top),
    .b_out_i    (b_out_top),
    .c_i        (cin_top),
    .c_o        (cout_top),
    .sum_o      (sum_out_top)
  );

  // D Flip-Flop to store carry
  d_ff dflip_flop (
    .clk_i      (clock_top_i),
    .reset_i    (reset_top),
    .q_o        (cin_top),
    .data_i     (cout_top)
  );

  // FSM Controller
  fsm fsm_states (
    .resetn_i (resetn_top_i),
    .start_i    (start_top_i),
    .clk_i      (clock_top_i),
    .reset_o    (reset_top),
    .load_o     (load_top),
    .enable_o   (enable_top)
  );

  // Serial-In Parallel-Out (SIPO)
  serial_parallel sp_sr (
    .clk_i         (clock_top_i),
    .reset_n_i     (reset_top),
    .sum_o         (sum_top),
    .sum_o_out_i   (sum_out_top),
    .enable_i      (enable_top)
  );

  // Output sum when done
  always_ff @(posedge clock_top_i) begin
    if (sp_sr.count == WIDTH+1) begin
      final_sum_o <= {cin_top, sum_top};
      sp_sr.count <='d0;
    end
  end

endmodule





