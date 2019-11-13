module upload_module(
    input clk,
    input rst_n,
    input laser_enable,
    input [31:0]laser_freq,
    input upload_en,
    input laser_fifo_in_ready,
    input [31:0]acc_time,
    input [31:0]acc_threshold,
    input motor_enable,
    input motor_direction,
    input [31:0]motor_time,
    input [31:0]motor_max_speed,

    input sys_acquire,
    input err_upload,
    input [31:0]cmd_err_cnt,
    input result_rdy,
    input [31:0] final_distance,
    input [20:0] angle_value,

    output reg laser_fifo_in_valid,
    output reg [31:0]laser_fifo_in_data

);


localparam              IDLE            = 0;
localparam              HEAD            = 1;
localparam              COMMAND         = 2;
localparam              DATA_LEN        = 3;
localparam              DATA            = 4;
localparam              CHECKSUM        = 5;
localparam              RESULT          = 6;

localparam  	TX_HEAD = 16'h1234;
localparam		VERSION = 32'h01010101;

(* KEEP = "TRUE" *) reg [RESULT:0] cs='d1,ns='d1;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[HEAD]: cs_STRING = "HEAD";
        cs[COMMAND]: cs_STRING = "COMMAND";
        cs[DATA_LEN]: cs_STRING = "DATA_LEN";
        cs[DATA]: cs_STRING = "DATA";
        cs[CHECKSUM]: cs_STRING = "CHECKSUM";
        cs[RESULT]: cs_STRING = "RESULT";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on
reg     [7:0]          state_cnt;
reg     [7:0]          head_cnt;


reg     [31:0]          check_sum;
reg     [31:0]          data_check_sum;
reg     [1:0]           data_check_cnt;

wire idle_state ;
assign   idle_state = cs[IDLE];

// synthesis translate_on
always @( posedge clk or negedge rst_n )
begin
    if(!rst_n)
    begin
        cs <= 'd1;
    end
    else
    begin
        cs <= ns;
    end
end

always @ ( posedge clk or negedge rst_n )
begin
    if(!rst_n)
        state_cnt <= 0;
    else if (cs != ns)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt + 1'b1;
end	


reg [7:0] command_code;
reg [7:0] data_len;

always @ ( posedge clk or negedge rst_n )
begin
    if( !rst_n )
    begin
        command_code <= 8'h00 ;
        data_len <= 8'h00 ;
    end
    else
    begin
        if( result_rdy )
        begin
            command_code <= 8'ha3 ;
            data_len <= 8'h02 ;

        end
        else if( idle_state )
        begin
            if ( sys_acquire )
            begin
                command_code <= 8'ha4 ;
                data_len <= 8'h14 ;
            end
            else if ( err_upload )
            begin
                command_code <= 8'ha2 ;
                data_len <= 8'h03 ;
            end
            else 
            begin
                command_code <= 8'h00 ;
                data_len <= 8'h00 ;
            end
        end

    end
end






always @(*)
begin
    ns = 'd0;
    case(1'b1)
        cs[IDLE]:
        begin
            if((upload_en)&(result_rdy|sys_acquire|err_upload)&laser_fifo_in_ready)
            begin
                ns[HEAD] = 1'b1;
            end
            else
            begin
                ns[IDLE] = 1'b1;
            end
        end
        cs[HEAD]:
        begin
            if(state_cnt == 0)
                ns[COMMAND] = 1'b1;
            else
                ns[HEAD] = 1'b1;
        end
        cs[COMMAND]:
        begin
            if(state_cnt == 0)
                ns[DATA_LEN] = 1'b1;
            else
                ns[COMMAND] = 1'b1;
        end

        cs[DATA_LEN]:
        begin
            if(state_cnt == 0)
                ns[DATA] = 1'b1;
            else
                ns[DATA_LEN] = 1'b1;
        end
        cs[DATA]:
        begin
            if(state_cnt == data_len-1)
                ns[CHECKSUM] = 1'b1;
            else
                ns[DATA] = 1'b1;
        end

        cs[CHECKSUM]:
        begin
            if(state_cnt == 0)
            begin
                ns[IDLE] = 1'b1;
            end
            else
            begin
                ns[CHECKSUM] = 1'b1;
            end
        end

        default:
            ns[IDLE] = 1'b1;
    endcase
end

reg [31:0] cmd_cnt ;
always @ ( posedge clk or negedge rst_n )
begin
    if( !rst_n )
    begin
        laser_fifo_in_valid <= 1'b0;
        laser_fifo_in_data <= 32'd0;
        cmd_cnt <= 32'd0;
    end
    else
    begin
        case ( 1'b1 )
            cs[IDLE]:
            begin
                laser_fifo_in_valid <= 1'b0;
                laser_fifo_in_data <= 32'd0;
            end
            cs[HEAD]:
            begin

                laser_fifo_in_data[31:16] <= TX_HEAD;
            end
            cs[COMMAND]:
            begin
                laser_fifo_in_data[15:8] <= command_code;
            end

            cs[DATA_LEN]:
            begin
                laser_fifo_in_valid <= 1'b1;
                laser_fifo_in_data[7:0] <= data_len;
            end
            cs[DATA]:
            begin
                if(command_code == 8'ha2)
                begin
                    case (state_cnt)
                        8'h00: laser_fifo_in_data <=  32'h123;
                        8'h01: laser_fifo_in_data <=	32'h456;
                        8'h02: laser_fifo_in_data <=	32'h789;
                        default:
                        begin
                            laser_fifo_in_data <= 8'h00;
                        end
                    endcase
                end
                else if(command_code == 8'ha3)
                begin
                    case (state_cnt)
                        8'h00: laser_fifo_in_data <= angle_value ;//电机角度
                        8'h01: laser_fifo_in_data <= final_distance ; //距离值
                        default:
                        begin
                            laser_fifo_in_data <= 8'h00;
                        end
                    endcase
                end
                else if(command_code == 8'ha4)
                begin
                    case (state_cnt)
                        'd00: laser_fifo_in_data <= VERSION;
                        'd01: laser_fifo_in_data <= 0;
                        'd02: laser_fifo_in_data <= 0;
                        'd03: laser_fifo_in_data <= 0;
                        'd04: laser_fifo_in_data <= 0;
                        'd05: laser_fifo_in_data <= 0;
                        'd06: laser_fifo_in_data <= 0;
                        'd07: laser_fifo_in_data <= 0;
                        'd08: laser_fifo_in_data <= 0;
                        'd09: laser_fifo_in_data <= 0;
                        'd10: laser_fifo_in_data <= 0;
                        'd11: laser_fifo_in_data <= 0;
                        'd12: laser_fifo_in_data <= 0;
                        'd13: laser_fifo_in_data <= 0;
                        'd14: laser_fifo_in_data <= 0;
                        'd15: laser_fifo_in_data <= 0;
                        'd16: laser_fifo_in_data <= 0;
                        'd17: laser_fifo_in_data <= 0;
                        'd18: laser_fifo_in_data <= 0;
                        'd19: laser_fifo_in_data <= 0;
                        default:
                        begin
                            laser_fifo_in_data <= 8'h00;
                        end
                    endcase
                end
            end
            cs[CHECKSUM]:
            begin
                laser_fifo_in_data <= check_sum;
            end
            cs[RESULT]:
            begin
                laser_fifo_in_data <= 32'h00000002;
            end
            default:
            begin
                laser_fifo_in_data <= 0;
            end
        endcase
    end
end


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        check_sum <= 0;
    end
    else if(cs[RESULT] | cs[IDLE])
    begin
        check_sum <= 0;
    end
    else
    begin
        check_sum <= check_sum ^ laser_fifo_in_data;
    end
end

endmodule
