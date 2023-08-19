// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Authors:
// - Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
// - Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// - Andreas Kurth <akurth@iis.ee.ethz.ch>
// - Florian Zaruba <zarubaf@iis.ee.ethz.ch>

`include "assign.svh"

module tb_axi2apb_64_32_TP3;

  parameter AW = 32;
  parameter DW = 64;
  parameter IW = 16;
  parameter UW = 10;
  parameter AAW = 12;

  localparam tCK = 1ns;
  localparam TA = tCK * 1/4;
  localparam TT = tCK * 3/4;

  localparam     MAX_READ_TXNS  = 32'd100;
  localparam     MAX_WRITE_TXNS = 32'd100;
  localparam bit AXI_ATOPS      = 1'b0;

  logic clk = 0;
  logic rst = 1;
  logic done = 0;
  logic end_of_sim;
/*  AXI_LITE_DV #(
    .AXI_ADDR_WIDTH(AW),
    .AXI_DATA_WIDTH(DW)
  ) axi_lite_dv(clk);//Replace */

  APB_BUS #(
    .APB_ADDR_WIDTH(AAW)
  ) apb();//Replace

//  `AXI_LITE_ASSIGN(axi_lite_dv, axi_lite)//Replace

  AXI_BUS_DV #(
    .AXI_ADDR_WIDTH(AW),
    .AXI_DATA_WIDTH(DW),
    .AXI_ID_WIDTH(IW),
    .AXI_USER_WIDTH(UW)
  ) axi_dv(clk);

  AXI_BUS #(
    .AXI_ADDR_WIDTH(AW),
    .AXI_DATA_WIDTH(DW),
    .AXI_ID_WIDTH(IW),
    .AXI_USER_WIDTH(UW)
  ) axi();

  `AXI_ASSIGN(axi, axi_dv)
//Probable issues: Interfacing of resp, req; DV; Address map
  axi2apb_64_32_TP3_intf #(
    .AXI_ADDR_WIDTH     ( AW      ),
    .AXI_DATA_WIDTH     ( DW      ),
    .AXI_ID_WIDTH       ( IW      ),
    .AXI_USER_WIDTH     ( UW      ),
    .AXI_MAX_WRITE_TXNS ( 32'd100  ),
    .AXI_MAX_READ_TXNS  ( 32'd100  ),
    .FALL_THROUGH       ( 1'b1    )
  ) i_dut (
    .clk_i      ( clk      ),
    .rst_ni     ( rst      ),
    .testmode_i ( 1'b0     ),
    .slv        ( axi      ),
    .mst        ( apb )//Replace
  );

  typedef axi_test::axi_rand_master #(
    // AXI interface parameters
    .AW ( AW ),
    .DW ( DW ),
    .IW ( IW ),
    .UW ( UW ),
    // Stimuli application and test time
    .TA ( TA ),
    .TT ( TT ),
    // Maximum number of read and write transactions in flight
    .MAX_READ_TXNS  ( MAX_READ_TXNS  ),
    .MAX_WRITE_TXNS ( MAX_WRITE_TXNS ),
    .AXI_ATOPS      ( AXI_ATOPS      )
  ) axi_rand_master_t;
  //typedef axi_test::axi_lite_rand_slave #(.AW(AW), .DW(DW), .TA(TA), .TT(TT)) axi_lite_rand_slv_t;//Replace

  //axi_lite_rand_slv_t axi_lite_drv = new(axi_lite_dv, "axi_lite_rand_slave");//Replace
  axi_rand_master_t   axi_drv      = new(axi_dv);

  initial begin
    #tCK;
    rst <= 0;
    #tCK;
    rst <= 1;
    #tCK;
    while (!done) begin
      clk <= 1;
      #(tCK/2);
      clk <= 0;
      #(tCK/2);
    end
  end

  initial begin
    axi_drv.add_memory_region(32'h0000_0000,
                                      32'h1000_0000,
                                      axi_pkg::NORMAL_NONCACHEABLE_NONBUFFERABLE);
    axi_drv.add_memory_region(32'h1000_0000,
                                      32'h2000_0000,
                                      axi_pkg::NORMAL_NONCACHEABLE_BUFFERABLE);
    axi_drv.add_memory_region(32'h3000_0000,
                                      32'h4000_0000,
                                      axi_pkg::WBACK_RWALLOCATE);
    //end_of_sim <= 1'b0;
    axi_drv.reset();
    @(posedge rst);
    axi_drv.run(1,1);//task run(input int n_reads, input int n_writes)
    //end_of_sim <= 1'b1;

    repeat (4) @(posedge clk);
    done = 1'b1;
    $info("All AXI4+ATOP Bursts converted to APB");//Replace
    repeat (4) @(posedge clk);
    $stop();
    
  end
  
  initial begin
      apb.pready  <= '0;
      apb.prdata  <= '0;
      apb.pslverr <= '0;
      forever begin
        @(posedge clk);
        apb.pready  <= #TA $urandom();
        apb.prdata  <= #TA $urandom();
        apb.pslverr <= #TA $urandom();
      end
  end


  //initial begin : proc_sim_stop
    //@(posedge rst);
    //wait (end_of_sim);
    //$stop();
  //end
  /*initial begin
    axi_lite_drv.reset();//Replace
    @(posedge clk);

    axi_lite_drv.run();//Replace
  end */

/*  initial begin : proc_count_lite_beats//Replace
    automatic longint aw_cnt = 0;
    automatic longint w_cnt  = 0;
    automatic longint b_cnt  = 0;
    automatic longint ar_cnt = 0;
    automatic longint r_cnt  = 0;
    @(posedge rst);
    while (!done) begin
      @(posedge clk);
      #TT;
      if (axi_lite.aw_valid && axi_lite.aw_ready) begin//Replace
        aw_cnt++;
      end
      if (axi_lite.w_valid && axi_lite.w_ready) begin//Replace
        w_cnt++;
      end
      if (axi_lite.b_valid && axi_lite.b_ready) begin//Replace
        b_cnt++;
      end
      if (axi_lite.ar_valid && axi_lite.ar_ready) begin//Replace
        ar_cnt++;
      end
      if (axi_lite.r_valid && axi_lite.r_ready) begin//Replace
        r_cnt++;
      end
    end
    assert (aw_cnt == w_cnt && w_cnt == b_cnt);
    assert (ar_cnt == r_cnt);
    $display("AXI4-Lite AW count: %0d", aw_cnt );//Replace
    $display("AXI4-Lite  W count: %0d", w_cnt  );//Replace
    $display("AXI4-Lite  B count: %0d", b_cnt  );//Replace
    $display("AXI4-Lite AR count: %0d", ar_cnt );//Replace
    $display("AXI4-Lite  R count: %0d", r_cnt  );//Replace
  end */

endmodule
