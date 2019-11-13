interface feedback_bfm ();
    logic                       sig;
endinterface


class feedback_drive;
    /*
     * 静态属性
     */
    virtual feedback_bfm bfm;
    function new(virtual feedback_bfm b);
        bfm = b;
    endfunction
    /*
     * speed : 单位r/s
     */
    extern virtual task const_speed(int speed);  // 匀速运动，反馈也是匀速的

    /*
     * flag = 0; 转一圈后速度增加/减少
     * flag = 1; 转5个间隔后速度增加/减少, 暂时不支持
     */
    extern virtual task inc_speed(int speed, int flag);  // speed 为起始转速
    extern virtual task dec_speed(int speed, int flag);  // speed 为起始转速
endclass


task feedback_drive::const_speed(int speed);
    integer num = 44;
    integer total = (2+3)*43 + (8+3);
    forever
    begin
        $display("motor speed is %dr/s", speed);
        bfm.sig = 0;
        repeat(2)
        begin
            bfm.sig = 1; #( ( (1s/speed)/(total))*2);
            bfm.sig = 0; #( ( (1s/speed)/(total))*3);
        end

        begin
            bfm.sig = 1; #(((1s/speed)/(total))*8);
            bfm.sig = 0; #(((1s/speed)/(total))*3);
        end
        repeat(41)
        begin
            bfm.sig = 1; #(((1s/speed)/(total))*2);   // 假定障碍物和空隙宽度比为1:2
            bfm.sig = 0; #(((1s/speed)/(total))*3);
        end
    end
endtask


task feedback_drive::inc_speed(int speed, int flag);
    integer num = 44;
    integer total = (2+3)*43 + (8+3);
    if (flag == 0)
    begin
        for(int i = 0; i < 10; i = i + 1 )      // 产生10反馈波形
        begin
            $display("motor speed is %dr/s", speed+i);
            bfm.sig = 0;
            repeat(2)
            begin
                bfm.sig = 1; #( ( (1s/(speed-i))/total )*2);
                bfm.sig = 0; #( ( (1s/(speed-i))/total )*3);
            end

            begin
                bfm.sig = 1; #(((1s/(speed-i))/total)*8);
                bfm.sig = 0; #(((1s/(speed-i))/total)*3);
            end
            repeat(41)
            begin
                bfm.sig = 1; #(((1s/(speed-i))/total)*2);   // 假定障碍物和空隙宽度比为1:2
                bfm.sig = 0; #(((1s/(speed-i))/total)*3);
            end
        end
    end
    else
    begin
    end
endtask

task feedback_drive::dec_speed(int speed, int flag);
    integer num = 44;
    integer total = (2+3)*43 + (8+3);
    if (flag == 0)
    begin
        for(int i = 0; i < 10; i = i + 1 )      // 产生10反馈波形
        begin
            $display("motor speed is %dr/s", speed-i);
            bfm.sig = 0;
            repeat(2)
            begin
                bfm.sig = 1; #( ( (1s/(speed+i))/total )*2);
                bfm.sig = 0; #( ( (1s/(speed+i))/total )*3);
            end

            begin
                bfm.sig = 1; #(((1s/(speed+i))/total)*8);
                bfm.sig = 0; #(((1s/(speed+i))/total)*3);
            end
            repeat(41)
            begin
                bfm.sig = 1; #(((1s/(speed+i))/total)*2);   // 假定障碍物和空隙宽度比为1:2
                bfm.sig = 0; #(((1s/(speed+i))/total)*3);
            end
        end
    end
    else
    begin
    end
endtask
