// ============================================================================
// MODULE: APB Master FSM
// PURPOSE: Bridges the CPU pipeline to the APB bus.
// ============================================================================
module apb_master (
  input      clk,
  input      reset,
  input      transfer_req,
  input      pready,
  output reg psel,
  output reg penable,
  output     stall
);

  parameter IDLE   = 2'b00;
  parameter SETUP  = 2'b01;
  parameter ACCESS = 2'b10;

  reg [1:0] state, next_state;

  // CRITICAL FIX: The stall must be combinational. 
  // It instantly freezes the CPU the moment a request appears, 
  // and only releases on the exact cycle the Slave asserts pready.
  assign stall = transfer_req & ~(state == ACCESS && pready);

  always @(posedge clk) begin
    if (reset)
      state <= IDLE;
    else
      state <= next_state;
  end

  always @(*) begin
    // Default safety values
    psel       = 1'b0;
    penable    = 1'b0;
    next_state = state;

    case (state)
      IDLE: begin
        if (transfer_req) begin
          next_state = SETUP;
        end
      end

      SETUP: begin
        psel       = 1'b1;
        next_state = ACCESS;
      end

      ACCESS: begin
        psel    = 1'b1;
        penable = 1'b1;
        
        if (pready) begin
          next_state = IDLE;
        end
      end
      
      default: next_state = IDLE;
    endcase
  end
endmodule
