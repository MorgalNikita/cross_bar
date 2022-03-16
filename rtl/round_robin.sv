//=================================================
// Round-robin module
//=================================================
module round_robin#(
parameter TIMER_STOP = 15
)
(
    input                   clk,
    input                   resetn,
    input           [1:0]   req,
    output logic    [1:0]   grnt
);

    logic [31:0] timer;
    logic timer_start;
    logic timer_exp;
    logic ring_cnt;


 //=================================================
 // Timer reset
 //=================================================
always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        timer_start <= 0;
    end
    else begin
        if(timer_exp) begin
            timer_start <= 0;
        end
        if(req == 2'b00) begin
            timer_start <= 0;
        end
        else if (|req && !timer_start)
            timer_start <= 1;
    end
end
 //=================================================
 // Timer pulse
 //=================================================
always_ff @(posedge clk or negedge resetn) begin
    if(!resetn ) begin
        timer <= 32'h0;
    end
    else if(timer_exp) begin
        timer <= 32'h0;
    end
    else if (timer_start) begin
        timer <= timer + 1;
    end
    else if (req == 2'b11) begin
        timer <= timer + 1;
    end
    else timer <= 32'h0;
end

//=================================================
// Timer reset
//=================================================
always_ff @(posedge clk or negedge resetn ) begin
    if (!resetn) timer_exp <= 0;
    else if (timer == TIMER_STOP) timer_exp <= 1;
    else timer_exp <= 0;
end


always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        ring_cnt <= 1'b0;
        grnt   <= 2'b0;
    end
    else begin
        if (req == 2'b0) begin
            grnt <= 2'b0;
        end
        if (timer_start) begin
 //=================================================
 // Only one req from masters pulse
 //=================================================
            if(req == 2'b01) begin
                grnt <= 2'b01;
            end
            else if(req == 2'b10) begin
                grnt <= 2'b10;
            end
            else begin
//=================================================
 // New logic output req to slaves  pulse
 //=================================================
                if (timer_exp) begin
                    ring_cnt <= ring_cnt + 1;
                end
                if (ring_cnt == 1'b0) begin
                    if(req[0]) begin
                        grnt <= 2'b01;
                    end
                    else begin
                        ring_cnt <= ring_cnt + 1;
                    end
                end
                if (ring_cnt == 1'b1) begin
                    if(req[1]) begin
                        grnt <= 2'b10;
                    end
                    else begin
                        ring_cnt <= ring_cnt + 1;
                    end
                end
                end
            end
            else if (!timer_start && timer == 1)
                ring_cnt <= ~ring_cnt;
    end
end

endmodule
