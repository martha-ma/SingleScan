module rst_module (clk,pwr_rst,sys_rst,rst_n,gxb_pwrdn);

input clk;
input pwr_rst;
input sys_rst;
output wire  rst_n;
output wire  gxb_pwrdn;

reg [19:0]cnt;
reg rst_n_r;
always @(posedge clk or negedge pwr_rst)
begin
    if(!pwr_rst)
    begin
        cnt <= 20'd0;
        rst_n_r <= 1'b0;
    end
    else if ( sys_rst )
    begin
        cnt <= 20'd0;
        rst_n_r <= 1'b0;
    end
    else	if(cnt < 20'd1300)
    begin
        cnt <= cnt + 1'b1;
        rst_n_r <= 1'b0;
    end
    else
    begin
        rst_n_r <= 1'b1;
    end
end
assign rst_n = rst_n_r;


reg [15:0] gxb_cnt=16'd0;
reg gxb_pwrdn_r;
always @ (posedge clk or negedge rst_n)
begin
    if( !rst_n )	
    begin
        gxb_pwrdn_r <= 1'b0;
        gxb_cnt <= 16'd0;
    end
    else// if(start)
    begin
        if(gxb_cnt <= 16'd300)
        begin
            gxb_cnt <= gxb_cnt + 1'b1;
            gxb_pwrdn_r <= 1'b0;
        end
        else if(gxb_cnt < 16'd500)
        begin
            gxb_cnt <= gxb_cnt + 1'b1;
            gxb_pwrdn_r <= 1'b1;
        end
        else if (gxb_cnt < 16'd1500)
        begin
            gxb_cnt <= gxb_cnt + 1'b1;
            gxb_pwrdn_r <= 1'b0;
        end

    end
end

assign gxb_pwrdn = gxb_pwrdn_r ;
endmodule
