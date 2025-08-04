
// FSM CODING FOR SHIFTING THE DATA !! 
//typedef enum {reset_o=2'b00,load_o=2'b01,SHIFT=2'b10} state;
parameter WIDTH = 8;


//parameter WIDTH=8;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    FILE Name     :  fsm.sv                                                                                     //
//                                                                                                                //
//    Description   :  FSM contains 3 State reset_o load_o SHIFT based on start_i and resetn_i                    //
//                                                                                                                //
//    Inputs        :  clk_i,resetn_i,start_i                                                                     //
//                                                                                                                //
//    Outputs       :  load_o enable_o reset_o                                                                    //
//                                                                                                                //
//                                                                                                                //
//                                                                                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////





typedef enum logic [1:0] {
  RESET = 2'b00,
  LOAD  = 2'b01,
  SHIFT = 2'b10
} state_t;



module fsm (
    input resetn_i,
    input start_i,
    input clk_i,
    output reg reset_o,
    output reg load_o,
    output reg enable_o
);
  //  output reg[1:0] state;
  reg [WIDTH-1:0] count;
  reg [1:0] current_state, next_state;

  //parameter reset_o=2'b00,load_o=2'b01,SHIFT=2'b10;


  always @(posedge clk_i) begin

    if (!resetn_i) begin
      current_state <= RESET;
    end else begin
      current_state <= next_state;
    end
  end
  always @(posedge clk_i) begin
    case (current_state)
      reset_o: begin
        if (!resetn_i) begin
          reset_o  <= 1;
          load_o   <= 0;
          enable_o <= 0;
          $display("IN reset STATE");
          next_state <= RESET;
          count      <= 0;
        end else if (start_i) begin
          reset_o    <= 0;
          load_o     <= 1;
          enable_o   <= 0;
          next_state <= LOAD;
        end
        //else next_state <= current_state;
      end

      load_o: begin
        $display("IN load_o STATE");
        if (!start_i && resetn_i) begin
          reset_o    <= 0;
          load_o     <= 0;
          enable_o   <= 1;
          next_state <= SHIFT;
        end else if (!resetn_i) begin
          next_state <= RESET;
          reset_o    <= 1;
          load_o     <= 0;
          enable_o   <= 0;
          $display("IN reset STATE");
          next_state <= RESET;
        end
        //else next_state <= current_state;
      end
      SHIFT: begin
        $display("IN SHIFT STATE");
        if (!start_i && resetn_i) begin
          reset_o    <= 0;
          load_o     <= 0;
          enable_o   <= 1;
          next_state <= SHIFT;
          count      <= count + 1;
          if (count == WIDTH) begin
            enable_o <= 0;
          end else begin
            enable_o <= 1;
          end
        end else if (start_i && resetn_i) begin
          next_state <= LOAD;
          reset_o    <= 0;
          load_o     <= 1;
          enable_o   <= 0;
        end
      end
      default: next_state <= RESET;
    endcase
  end
endmodule



























