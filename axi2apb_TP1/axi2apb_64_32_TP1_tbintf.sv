`include "assign.svh"
`include "typedef.svh"
module axi2apb_64_32_T3P1_intf #(

  /// AXI bus parameters
  parameter int unsigned AXI_ADDR_WIDTH     = 32'd0,
  parameter int unsigned AXI_DATA_WIDTH     = 32'd0,
  parameter int unsigned AXI_ID_WIDTH       = 32'd0,
  parameter int unsigned AXI_USER_WIDTH     = 32'd0,
  /// Maximum number of outstanding writes
  parameter int unsigned AXI_MAX_WRITE_TXNS = 32'd1,
  /// Maximum number of outstanding reads
  parameter int unsigned AXI_MAX_READ_TXNS  = 32'd1,
  parameter bit          FALL_THROUGH       = 1'b1,
  /// APB bus parameters
  parameter int unsigned APB_ADDR_WIDTH     = 12

)(

  input logic     clk_i,
  input logic     rst_ni,
  input logic     testmode_i,
  AXI_BUS.Slave   slv,
  APB_BUS.Master mst
);

//Done:
//=====
//check the *** below for mismatch in width. Should be fine...
//check if the default widths of APB signals are ok. If they need to be changed as per the values of AW, IW, UW, DW in the testbench. The values of AW, DW, IW, UW are all as in the source code of axi2apb. So, the widths of APB signals should be fine
//check if the values of AW, IW, UW, DW in the testbench are appropriate. Update AW=32, DW=64, IW=16, UW=10
//Check the files of axi if these values of AW, DW, IW, UW are permissible. Do they need to be power of 2?
//edit the testbench: replace the dut,
//To Do:
//======
//check if the APB interface has to be mentioned in any other file in order to be able to use it
//edit the testbench: remove the AXI_lite part and see what needs to be done for the APB part. We don't need to verify the implementation, but no harm verifying...

axi2apb_64_32_T3P1 #(

.AXI4_ADDRESS_WIDTH(AXI_ADDR_WIDTH), 
.AXI4_RDATA_WIDTH(AXI_DATA_WIDTH),
.AXI4_WDATA_WIDTH(AXI_DATA_WIDTH),
.AXI4_ID_WIDTH(AXI_ID_WIDTH),
.AXI4_USER_WIDTH(AXI_USER_WIDTH),
.APB_ADDR_WIDTH(APB_ADDR_WIDTH)

) axi2apb (

.ACLK 		(clk_i),
.ARESETn 	(rst_ni),
.test_en_i 	(testmode_i),

.AWID_i 	(slv.aw_id),//logic [AXI4_ID_WIDTH-1:0] //logic [AXI_ID_WIDTH-1:0]
.AWADDR_i 	(slv.aw_addr),//logic [31:0] //logic [31:0]
.AWLEN_i 	(slv.aw_len),//logic [ 7:0] //logic [7:0]
.AWSIZE_i 	(slv.aw_size),//logic [ 2:0] //logic [2:0]
.AWBURST_i 	(slv.aw_burst),//logic [ 1:0] //logic [1:0]
.AWLOCK_i 	(slv.aw_lock),//logic //logic
.AWCACHE_i 	(slv.aw_cache),//logic [ 3:0] //logic [3:0]
.AWPROT_i 	(slv.aw_prot),//logic [ 2:0] //logic [2:0]
.AWREGION_i 	(slv.aw_region),//logic [ 3:0]  //logic [3:0]
.AWUSER_i 	(slv.aw_user),//logic [ AXI4_USER_WIDTH-1:0] //logic [AXI_USER_WIDTH-1:0]
.AWQOS_i 	(slv.aw_qos),//logic [ 3:0] //logic [3:0]
.AWVALID_i 	(slv.aw_valid),//logic //logic
.AWREADY_o 	(slv.aw_ready),//logic //logic


.WDATA_i  	(slv.w_data),//logic [7:0][7:0] //logic [AXI_DATA_WIDTH-1:0]****
.WSTRB_i  	(slv.w_strb),//logic [AXI_NUMBYTES-1:0]  //logic [AXI_STRB_WIDTH-1:0]
.WLAST_i  	(slv.w_last),//logic //logic
.WUSER_i  	(slv.w_user),//logic [AXI4_USER_WIDTH-1:0] //logic [AXI_USER_WIDTH-1:0]
.WVALID_i 	(slv.w_valid),//logic //logic
.WREADY_o 	(slv.w_ready),//logic //logic


.BID_o    	(slv.b_id),//logic   [AXI4_ID_WIDTH-1:0] //logic [AXI_ID_WIDTH-1:0]
.BRESP_o  	(slv.b_resp),//logic   [ 1:0] //logic [1:0]
.BVALID_o 	(slv.b_valid),//logic //logic
.BUSER_o  	(slv.b_user),//logic   [AXI4_USER_WIDTH-1:0] //logic [AXI_USER_WIDTH-1:0]
.BREADY_i 	(slv.b_ready),//logic //logic


.ARID_i 	(slv.ar_id),//logic [AXI4_ID_WIDTH-1:0] //logic [AXI_ID_WIDTH-1:0]
.ARADDR_i 	(slv.ar_addr),//logic [31:0] //logic [31:0]
.ARLEN_i 	(slv.ar_len),//logic [ 7:0] //logic [7:0]
.ARSIZE_i 	(slv.ar_size),//logic [ 2:0] //logic [2:0]
.ARBURST_i 	(slv.ar_burst),//logic [ 1:0] //logic [1:0]
.ARLOCK_i 	(slv.ar_lock),//logic //logic
.ARCACHE_i 	(slv.ar_cache),//logic [ 3:0] //logic [3:0]
.ARPROT_i 	(slv.ar_prot),//logic [ 2:0] //logic [2:0]
.ARREGION_i 	(slv.ar_region),//logic [ 3:0] //logic [3:0]
.ARUSER_i 	(slv.ar_user),//logic [ AXI4_USER_WIDTH-1:0] //logic [AXI_USER_WIDTH-1:0]
.ARQOS_i 	(slv.ar_qos),//logic [ 3:0] //logic [3:0]
.ARVALID_i 	(slv.ar_valid),//logic //logic
.ARREADY_o 	(slv.ar_ready),//logic //logic

.RID_o     	(slv.r_id),//logic [AXI4_ID_WIDTH-1:0] //logic [AXI_ID_WIDTH-1:0]
.RDATA_o   	(slv.r_data),//logic [AXI4_RDATA_WIDTH-1:0] //logic [AXI_DATA_WIDTH-1:0]
.RRESP_o   	(slv.r_resp),//logic [ 1:0] //logic [1:0]
.RLAST_o   	(slv.r_last),//logic //logic
.RUSER_o   	(slv.r_user),//logic [AXI4_USER_WIDTH-1:0] //logic [AXI_USER_WIDTH-1:0]
.RVALID_o  	(slv.r_valid),//logic //logic
.RREADY_i  	(slv.r_ready),//logic //logic

.PENABLE    	(mst.penable),//logic //
.PWRITE     	(mst.pwrite),//logic //
.PADDR      	(mst.paddr),//logic [11:0] // 
.PSEL       	(mst.psel),//logic //
.PWDATA     	(mst.pwdata),//logic [31:0] //
.PRDATA     	(mst.prdata),//logic [31:0] //
.PREADY     	(mst.pready),//logic //
.PSLVERR    	(mst.pslverr) //logic //

);


endmodule
