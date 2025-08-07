
// FSM CODING FOR SHIFTING THE DATA !! 
//typedef enum {reset_o=2'b00,load_o=2'b01,SHIFT=2'b10} state;
//parameter WIDTH = 8;


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

// FSM CODING FOR SHIFTING THE DATA !! 
//typedef enum {reset_o=2'b00,load_o=2'b01,SHIFT=2'b10} state;
//parameter WIDTH = 8;
//parameter WIDTH=8;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

module fsm #(
  parameter int WIDTH = 8
) (
  input  logic        resetn_i,
  input  logic        start_i,
  input  logic        clk_i,
  output logic        reset_o,
  output logic        load_o,
  output logic        enable_o
);

  state_t current_state, next_state;
  logic [$clog2(WIDTH+1)-1:0] count;

  // Sequential state and counter update
  always_ff @(posedge clk_i or negedge resetn_i) begin
    if (!resetn_i) begin
      current_state <= RESET;
      count <= 0;
    end else begin
      current_state <= next_state;

      // Count increments only in SHIFT state
      if (current_state == SHIFT && count < WIDTH)
        count <= count + 1;
      else if (current_state != SHIFT)
        count <= 0;
    end
  end

  // Combinational next state logic
  always_comb begin
    next_state = current_state;

    case (current_state)
      RESET: begin
        if (start_i)
          next_state = LOAD;
        else if(!resetn_i)
          next_state = RESET;
      end

      LOAD: begin
        if (!start_i)
          next_state = SHIFT;
        else if (!resetn_i)
          next_state = RESET;
        else
          next_state = LOAD;
      end

      SHIFT: begin
        if (count == WIDTH+1|| (!resetn_i) ) begin
          next_state = RESET;
        end else if (start_i) begin
          next_state = LOAD;
        end else begin
          next_state = SHIFT;
          
        end
      end

      default: next_state = RESET;
    endcase
  end

  // Output logic (Moore-style: based on state only)
  always_comb begin
    reset_o  = (current_state == RESET);
    load_o   = (current_state == LOAD);
    enable_o = (current_state == SHIFT && count < WIDTH+1);
  end

endmodule

