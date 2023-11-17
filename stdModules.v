/**************************************************************/
// File            : Standard Logic Modules
// Author          : Trung-Khanh Le
// Contact         : - ltkhanh@hcmus.edu.vn
//                   - ltkhanh@bigdolphin.com.vn
// Version         : 1.1
// Date            : 2022/11/28
// Modified Date   : 2023/11/17
// License         : MIT
/**************************************************************/

/**
 * @brief General Multiplexer N to 1
 * @param[in] Number of signals
 * @param[in] List of signals
 * @param[in] Code of selection
 * @return selected signal
 * @attention
 */
module stdMUXN
#(
    parameter N = 2
)
(
    output y,
    input [N-1:0] x,
    input [$clog2(N)-1:0] code
);
assign y = x[code];
endmodule

/**
 * @brief D Flip Flop
 * @param[in] Value
 * @param[in] Reset Flipflop
 * @param[in] Clock
 * @return Q
 * @return Inverted Q
 * @attention
 */
module stdDFF2(
    output q,
    output qn,
    input d,
    input rs,
    input clk
);
wire        s,r,sn,rn,rsn;
stdINV      u0(rsn,rs);
stdNAND2    u1(sn,s,rn);
stdNAND3    u2(s,clk,rsn,sn);
stdNAND3    u3(r,clk,s,rn);
stdNAND3    u4(rn,d,rsn,r);
stdNAND2    u5(q,s,qn);
stdNAND3    u6(qn,q,rsn,r);
endmodule

/**
 * @brief D Flip Flop
 * @brief It is not stable compared to logic gate version
 * @param[in] Value
 * @param[in] Reset Flipflop
 * @param[in] Clock
 * @return Q
 * @return Inverted Q
 * @attention
 */
module stdDFF(
    output reg q,
    output qn,
    input d,
    input rs,
    input clk
);
initial begin
    q <= 1'b0;
end
always@(posedge clk or posedge rs) begin
	if(rs)
		q <= 1'b0;
	else
		q <= d;
end
stdINV u0(qn,q);
endmodule

/**
 * @brief Phase Frequency Detector
 * @param[in] Signal
 * @param[in] Referent signal
 * @param[in] Reset Flipflop
 * @return Fast
 * @return Inverted Fast
 * @return Slow
 * @return Inverted Slow
 * @attention
 */
module stdPFD(    
    output fast,
    output fastn,
    output slow,
    output slown,
    input signal,    
    input refClk,
    input reset
);
supply0 GND;
supply1 PWR;
wire rs,rs1;
stdDFF  u0(.q(slow),.qn(slown),.d(PWR),.rs(rs),.clk(signal));
stdDFF  u1(.q(fast),.qn(fastn),.d(PWR),.rs(rs),.clk(refClk));
stdAND2 u2(rs1,slow,fast);
stdOR2  u3(rs,rs1,reset);
endmodule

/**
 * @brief Delay signal in 1-clock cycle
 * @param[in] Signal
 * @param[in] Reset
 * @param[in] Clock
 * @return delayed signal
 * @attention
 */
module delayCell(    
    output dsig,    
    input sig,
    input reset,
    input clk
);
supply0 GND;
supply1 PWR;
wire       sign;
wire       rs;
stdINV     u000(sign,sig);
stdOR2     u010(rs,reset,sign);
// Capture state value
// --- Although can use sig as a clock for this flipflop, it is not stable on FPGA because of no delay
stdDFF     u100(.q(dsig),.qn(),.d(sig),.rs(rs),.clk(clk));
endmodule

/**
 * @brief Pulse Damper Shifter Duty into 1-clock cycle
 * @param[in] High duty cycle pulse
 * @param[in] Reset
 * @param[in] Clock
 * @return Damped pulse
 * @attention
 */
module plsDamperShifter1C(    
    output dsig,    
    input sig,
    input reset,
    input clk
);
supply0 GND;
supply1 PWR;
wire       sign,sigdl;
wire       rs;
wire[1:0]  dat;
stdINV     u000(sign,sig);
stdOR2     u010(rs,reset,sign);
// Capture state value
// --- Although can use sig as a clock for this flipflop, it is not stable on FPGA because of no delay
stdDFF     u100(.q(dat[0]),.qn(),.d(sig),.rs(rs),.clk(clk));
// --- Passing to the final flipflop and clear the final output
stdDFF     u101(.q(dat[1]),.qn(),.d(dat[0]),.rs(rs),.clk(clk));
// Clear output
stdXOR2    u200(dsig,dat[0],dat[1]);
endmodule

/**
 * @brief Pulse Damper Shifter Duty into 2-clock cycle
 * @param[in] High duty cycle pulse
 * @param[in] Reset
 * @param[in] Clock
 * @return Damped pulse
 * @attention
 */
module plsDamperShifter2C(    
    output dsig,    
    input sig,
    input reset,
    input clk
);
supply0 GND;
supply1 PWR;
wire       sign,sigdl;
wire       rs;
wire[2:0]  dat;
stdINV     u000(sign,sig);
stdOR2     u010(rs,reset,sign);
// Capture state value
// --- Although can use sig as a clock for this flipflop, it is not stable on FPGA because of no delay
stdDFF     u100(.q(dat[0]),.qn(),.d(sig),.rs(rs),.clk(clk));
// --- Passing to the next flipflop
stdDFF     u101(.q(dat[1]),.qn(),.d(dat[0]),.rs(rs),.clk(clk));
// --- Passing to the final flipflop and clear the final output
stdDFF     u102(.q(dat[2]),.qn(),.d(dat[1]),.rs(rs),.clk(clk));
// Clear output
stdXOR2    u200(dsig,dat[0],dat[2]);
endmodule

/**
 * @brief Pulse Damper Shifter Duty into 3-clock cycle
 * @param[in] High duty cycle pulse
 * @param[in] Reset
 * @param[in] Clock
 * @return Damped pulse
 * @attention
 */
module plsDamperShifter3C(    
    output dsig,    
    input sig,
    input reset,
    input clk
);
supply0 GND;
supply1 PWR;
wire       sign,sigdl;
wire       rs;
wire[3:0]  dat;
stdINV     u000(sign,sig);
stdOR2     u010(rs,reset,sign);
// Capture state value
// --- Although can use sig as a clock for this flipflop, it is not stable on FPGA because of no delay
stdDFF     u100(.q(dat[0]),.qn(),.d(sig),.rs(rs),.clk(clk));
// --- Passing to the next flipflop
stdDFF     u101(.q(dat[1]),.qn(),.d(dat[0]),.rs(rs),.clk(clk));
// --- Passing to the next flipflop
stdDFF     u102(.q(dat[2]),.qn(),.d(dat[1]),.rs(rs),.clk(clk));
// --- Passing to the final flipflop and clear the final output
stdDFF     u103(.q(dat[3]),.qn(),.d(dat[2]),.rs(rs),.clk(clk));
// Clear output
stdXOR2    u200(dsig,dat[0],dat[3]);
endmodule

/**
 * @brief Pulse Damper Logic Duty
 * @param[in] High duty cycle pulse
 * @return Damped pulse
 * @attention
 */
module plsDamperLogic(    
    output dsig,    
    input sig
);
supply0 GND;
supply1 PWR;
wire[10:0]    sign;
stdINV       u1(sign[0],sig);
//assign #0.01 sign[0] = ~sig;
stdBUF       u2(sign[1],sign[0]);
stdBUF       u3(sign[2],sign[1]);
stdBUF       u4(sign[3],sign[2]);
stdBUF       u5(sign[4],sign[3]);
stdBUF       u6(sign[5],sign[4]);
stdBUF       u7(sign[6],sign[5]);
stdBUF       u8(sign[7],sign[6]);
stdBUF       u9(sign[8],sign[7]);
stdBUF       u10(sign[9],sign[8]);
stdBUF       u11(sign[10],sign[9]);
stdAND2      u0(dsig,sig,sign[10]);
endmodule

/**
 * @brief 8-bit Dgital Controlled Oscillator
 * @param[in] 8-bit Control Value
 * @param[in] 8-bit Duty Cycle
 * @param[in] Reset
 * @param[in] Clock
 * @return Oscillation
 * @attention
 */
module stdDCO8(
    output osc,
    input [7:0] maxVal,
    input [7:0] duty,    
    input reset,
    input clk    
);
supply0 GND;
supply1 PWR;
wire       clkn;
wire[7:0]  counter;
wire[7:0]  counterf;
wire[6:0]  w_xor;
wire[6:0]  w_and;
wire       ovf,rs,fb;
wire       matched,toggle;
wire[13:0]  passed;
wire[13:0]  reached;
// Bit 0
stdDFF     u000(.q(counter[0]),.qn(fb),.d(fb),.rs(rs),.clk(clk));
stdXOR2    u001(w_xor[0],counter[0],counter[1]);
// Bit 1
stdDFF     u010(.q(counter[1]),.qn(),.d(w_xor[0]),.rs(rs),.clk(clk));
stdAND2    u011(w_and[0],counter[0],counter[1]);
stdXOR2    u012(w_xor[1],w_and[0],counter[2]);
// Bit 2
stdDFF     u020(.q(counter[2]),.qn(),.d(w_xor[1]),.rs(rs),.clk(clk));
stdAND2    u021(w_and[1],w_and[0],counter[2]);
stdXOR2    u022(w_xor[2],w_and[1],counter[3]);
// Bit 3
stdDFF     u030(.q(counter[3]),.qn(),.d(w_xor[2]),.rs(rs),.clk(clk));
stdAND2    u031(w_and[2],w_and[1],counter[3]);
stdXOR2    u032(w_xor[3],w_and[2],counter[4]);
// Bit 4
stdDFF     u040(.q(counter[4]),.qn(),.d(w_xor[3]),.rs(rs),.clk(clk));
stdAND2    u041(w_and[3],w_and[2],counter[4]);
stdXOR2    u042(w_xor[4],w_and[3],counter[5]);
// Bit 5
stdDFF     u050(.q(counter[5]),.qn(),.d(w_xor[4]),.rs(rs),.clk(clk));
stdAND2    u051(w_and[4],w_and[3],counter[5]);
stdXOR2    u052(w_xor[5],w_and[4],counter[6]);
// Bit 6
stdDFF     u060(.q(counter[6]),.qn(),.d(w_xor[5]),.rs(rs),.clk(clk));
stdAND2    u061(w_and[5],w_and[4],counter[6]);
stdXOR2    u062(w_xor[6],w_and[5],counter[7]);
// Bit 7
stdDFF     u070(.q(counter[7]),.qn(),.d(w_xor[6]),.rs(rs),.clk(clk));
stdAND2    u071(w_and[6],w_and[5],counter[7]);
// Bit OVF
stdDFF     u100(.q(ovf),.qn(),.d(w_and[6]),.rs(rs),.clk(clk));
wire       rsosc;
stdOR2     u101(rsosc,ovf,reset);
stdOR2     u102(rs,rsosc,matched);
stdINV     u110(clkn,clk);
// --- Remove head of signals to avoid overlap
stdAND2    u120(counterf[0],counter[0],clkn);
stdAND2    u121(counterf[1],counter[1],clkn);
stdAND2    u122(counterf[2],counter[2],clkn);
stdAND2    u123(counterf[3],counter[3],clkn);
stdAND2    u124(counterf[4],counter[4],clkn);
stdAND2    u125(counterf[5],counter[5],clkn);
stdAND2    u126(counterf[6],counter[6],clkn);
stdAND2    u127(counterf[7],counter[7],clkn);
// OSC
wire       tgRs,tgRs1;
stdDFF     u200(.q(),.qn(osc),.d(PWR),.rs(tgRs),.clk(toggle));
stdOR2     u201(tgRs,tgRs1,rs);
stdDFF     u202(.q(tgRs1),.qn(),.d(PWR),.rs(rs),.clk(matched));
// Compare
// --- Check duty cycle
stdXNOR2   u310(passed[0],counterf[0],duty[0]);
stdXNOR2   u311(passed[1],counterf[1],duty[1]);
stdXNOR2   u312(passed[2],counterf[2],duty[2]);
stdXNOR2   u313(passed[3],counterf[3],duty[3]);
stdXNOR2   u314(passed[4],counterf[4],duty[4]);
stdXNOR2   u315(passed[5],counterf[5],duty[5]);
stdXNOR2   u316(passed[6],counterf[6],duty[6]);
stdXNOR2   u317(passed[7],counterf[7],duty[7]);
// --- Collect results
stdAND2    u320(passed[8],passed[1],passed[0]);
stdAND2    u321(passed[9],passed[3],passed[2]);
stdAND2    u322(passed[10],passed[5],passed[4]);
stdAND2    u323(passed[11],passed[7],passed[6]);
stdAND2    u324(passed[12],passed[9],passed[8]);
stdAND2    u325(passed[13],passed[11],passed[10]);
stdAND2    u326(toggle,passed[13],passed[12]);
// --- Check cycle
stdXNOR2   u410(reached[0],counterf[0],maxVal[0]);
stdXNOR2   u411(reached[1],counterf[1],maxVal[1]);
stdXNOR2   u412(reached[2],counterf[2],maxVal[2]);
stdXNOR2   u413(reached[3],counterf[3],maxVal[3]);
stdXNOR2   u414(reached[4],counterf[4],maxVal[4]);
stdXNOR2   u415(reached[5],counterf[5],maxVal[5]);
stdXNOR2   u416(reached[6],counterf[6],maxVal[6]);
stdXNOR2   u417(reached[7],counterf[7],maxVal[7]);
// --- Collect results
stdAND2    u420(reached[8],reached[1],reached[0]);
stdAND2    u421(reached[9],reached[3],reached[2]);
stdAND2    u422(reached[10],reached[5],reached[4]);
stdAND2    u423(reached[11],reached[7],reached[6]);
stdAND2    u424(reached[12],reached[9],reached[8]);
stdAND2    u425(reached[13],reached[11],reached[10]);
stdAND2    u426(matched,reached[13],reached[12]);
endmodule

/**
 * @brief N-bit Dgital Controlled Oscillator
 * @param[in] N-bit Control Value
 * @param[in] N-bit Duty Cycle
 * @param[in] Reset
 * @param[in] Clock
 * @return Oscillation
 * @attention
 */
module stdDCON
#(
    parameter W = 8
)
(
    output reg osc,
    input [W-1:0] maxVal,
    input [W-1:0] duty,    
    input reset,
    input clk    
);
reg [W-1:0] counterCycle;
reg [W-1:0] counterDuty;
always@(posedge clk or posedge reset) begin
	if(reset) begin
		counterCycle <= 0;
		counterDuty <= 0;
		osc <= 1'b1;
	end else begin
		if(counterCycle<maxVal) begin
			counterCycle <= counterCycle + 1;
			counterDuty <= counterDuty + 1;
			if(counterDuty>duty) osc <= 1'b0;
			else osc <= 1'b1;
		end else begin
			counterCycle <= 0;
			counterDuty <= 0;
			osc <= 1'b1;
		end
	end
end
endmodule

