/**************************************************************/
// File            : Utilities
// Author          : Trung-Khanh Le
// Contact         : - ltkhanh@hcmus.edu.vn
//                   - ltkhanh@bigdolphin.com.vn
// Version         : 1.0
// Date            : 2022/11/28
// Modified Date   : 2023/07/02
// License         : MIT
/**************************************************************/

/**
 * @brief Frequency Measure
 * @param[in] clock's Name
 * @param[in] Stop/Start
 * @param[in] Clock
 * @return none
 * @attention
 */
module frequencyMeasure
#(	
    parameter clockName = "Clock"
)
(
    input stop,
    input clk    
);
real    first_time       = 0; // store the first clk posedge
real    run_time         = 0;
integer count_pulse_high = 0;
integer count_pulse_low  = 0;
integer count_pulse      = 0;
real    count_pulse_duty = 0;
real    clk_freq         = 0; // clk freq (measured)
/*
Unit_number Time unit
-3 	        1ms
-6 	        1us
-9 	        1ns
-12 	    1ps
-15 	    1fs
*/
initial begin
    $timeformat(-6,2,"us",10);
end
// Count High states
always@(posedge clk) begin    
    #0.001           // this delay is required for simulation    
    if(clk) begin   // this check is required to ensure the measure starting after the main module
        count_pulse_high <= count_pulse_high + 1;
    end
end
// Count Low states
always@(negedge clk) begin    
    #0.001           // this delay is required for simulation
    if(!clk) begin  // this check is required to ensure the measure starting after the main module
        count_pulse_low <= count_pulse_low + 1;    
    end
end
// Set the first time
always@(posedge clk or negedge clk) begin            
    if((count_pulse_high==0) && (count_pulse_low==0)) begin
        first_time = $realtime;                
        //$display("[%t] Frq Measure: First edge\t: %t",$realtime,first_time);
    end
end
// Stop measuring
always@(negedge stop) begin
    if(!stop) begin
    run_time = $realtime - first_time;
    if(count_pulse_high==0) begin
        count_pulse = 0;
        count_pulse_duty = 0;
        clk_freq = 0;
    end
    else if(count_pulse_low==0) begin
        count_pulse = 0;
        count_pulse_duty = 100;
        clk_freq = 0;
    end
    else begin
        count_pulse = count_pulse_high+count_pulse_low;
        count_pulse_duty = (100 * count_pulse_high/count_pulse);
        clk_freq = (count_pulse/ 2 / run_time);// * 1000;
    end
    $display("[%t] Frq Measure: %s clock\t: %t, %5d pulses,\tfrequency: %.4f MHz,\tduty cycle: %.1f %%",$realtime,clockName,
                                                                                            run_time,count_pulse,
                                                                                            clk_freq,
                                                                                            count_pulse_duty);    
    end
end
endmodule
