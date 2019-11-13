module gx_rst_ctrl 
(
    input		clk,
    input		rst_n,
    input		pll_locked,

    output		gxb_powerdown,
    output		tx_digitalreset, 
    output		rx_analogreset,
    output		rx_digitalreset
);

reg     [15:00]             clk_cnt;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        clk_cnt <= 0;
    else if(clk_cnt >= 2000)
        clk_cnt <= 'd2001;
    else
        clk_cnt <= clk_cnt + 1'b1;
end

assign                      gxb_powerdown = (clk_cnt > 10) && (clk_cnt <= 200) ? 1 : 0;
assign                      pll_reset = gxb_powerdown;

assign                      tx_digitalreset = (clk_cnt > 10) && (clk_cnt <= 400) ? 1 : 0;
assign                      rx_analogreset = (clk_cnt > 10) && (clk_cnt <= 600) ? 1 : 0;
assign                      rx_digitalreset = (clk_cnt > 10) && (clk_cnt <= 800) ? 1 : 0;
endmodule

//      module gx_rst_ctrl 
//      (
//          input		clk,
//          input		rst_n,
//          input		gxb_pwrdn_in,
//          input		pll_locked,
//          input		rx_freqlocked,
//          output		gxb_powerdown,
//          output		tx_digitalreset, 
//          output		rx_analogreset,
//          output		rx_digitalreset,
//          input busy,
//          output reg rx_locktorefclk,
//          output reg rx_locktodata
//      );
//      
//      reg			gxb_powerdown;
//      reg			tx_digitalreset;
//      reg			rx_analogreset;
//      reg			rx_digitalreset;
//      
//      
//      reg	[8:0]	count_rx_digitalreset;
//      reg [3:0]	state;
//      
//      
//      reg [11:0]count_rx_ltd_ltc;
//      
//      // FSM
//      always @ (posedge clk or negedge rst_n)
//      begin
//          if ( !rst_n ) 
//          begin
//              state <= 4'd0;    
//              gxb_powerdown <= 1'b0;
//              tx_digitalreset <= 1'b1;
//              rx_analogreset <= 1'b1;
//              rx_digitalreset <= 1'b1; 
//              count_rx_digitalreset <= 9'd0;  
//              count_rx_ltd_ltc <= 12'd0;	
//          end
//          else 
//          begin
//              case(state)
//                  4'd0:
//                  begin
//                      if(gxb_pwrdn_in)
//                      begin
//                          state <= state + 1'b1;
//                      end
//                  end
//                  4'd1:
//                  begin
//                      gxb_powerdown <= 1'b1;
//                      tx_digitalreset <= 1'b1;
//                      rx_analogreset <= 1'b1;
//                      rx_digitalreset <= 1'b1; 
//                      rx_locktodata <= 1'b0;
//                      rx_locktorefclk <= 1'b1;
//                      if(gxb_pwrdn_in==1'b0)
//                      begin
//                          state <= state + 1'b1;
//                      end
//                  end
//      
//                  4'd2:
//                  begin
//                      gxb_powerdown <= 1'b0;
//                      tx_digitalreset <= 1'b1;
//                      rx_analogreset <= 1'b1;
//                      rx_digitalreset <= 1'b1; 
//                      rx_locktodata <= 1'b0;
//                      rx_locktorefclk <= 1'b1;
//                      if(pll_locked)
//                      begin
//                          state <= state + 1'b1;
//                      end
//                  end
//                  4'd3:
//                  begin
//                      gxb_powerdown <= 1'b0;
//                      tx_digitalreset <= 1'b0;
//                      rx_analogreset <= 1'b1;
//                      rx_digitalreset <= 1'b1; 
//                      rx_locktodata <= 1'b0;
//                      rx_locktorefclk <= 1'b1;
//                      if(busy)
//                      begin
//                          state <= 4'd3;
//                      end
//                      else
//                      begin
//                          state <= state + 1'b1;
//                      end
//                  end
//                  4'd4:
//                  begin
//                      state <= state + 1'b1;
//                  end
//                  4'd5:
//                  begin
//                      gxb_powerdown <= 1'b0;
//                      tx_digitalreset <= 1'b0;
//                      rx_analogreset <= 1'b0;
//                      rx_digitalreset <= 1'b1; 
//                      rx_locktodata <= 1'b0;
//                      rx_locktorefclk <= 1'b1;
//                      if(count_rx_ltd_ltc < 12'd2500)
//                      begin
//                          count_rx_ltd_ltc <= count_rx_ltd_ltc + 1'b1;
//                      end
//                      else
//                      begin
//                          state <= state + 1'b1;
//                      end
//                  end
//                  4'd6:
//                  begin
//                      count_rx_ltd_ltc <= 12'd0;
//                      rx_locktodata <= 1'b0;
//                      rx_locktorefclk <= 1'b1;
//                      if(count_rx_digitalreset < 9'd200)
//                      begin
//                          count_rx_digitalreset <= count_rx_digitalreset + 1'b1;
//                      end
//                      else
//                      begin
//                          state <= state + 1'b1;
//                      end
//                  end
//                  4'd7:
//                  begin
//                      gxb_powerdown <= 1'b0;
//                      tx_digitalreset <= 1'b0;
//                      rx_analogreset <= 1'b0;
//                      rx_digitalreset <= 1'b0; 
//                      rx_locktodata <= 1'b0;
//                      rx_locktorefclk <= 1'b1;
//                      if(gxb_pwrdn_in)
//                      begin
//                          state <= 4'd0;
//                      end
//                      else if(pll_locked==1'b0)
//                      begin
//                          state <= 4'd2;
//                      end
//                      else
//                      begin
//                          state <= 4'd7;
//                      end
//                  end
//                  default :
//                  begin
//                      gxb_powerdown <= 1'b0;
//                      tx_digitalreset <= 1'b1;
//                      rx_analogreset <= 1'b1;
//                      rx_digitalreset <= 1'b1; 
//                  end
//      
//              endcase	
//          end
//      end
//      

//   endmodule
