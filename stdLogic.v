/**************************************************************/
// File            : Standard Logic Cells
// Author          : Trung-Khanh Le
// Contact         : - ltkhanh@hcmus.edu.vn
//                   - ltkhanh@bigdolphin.com.vn
// Version         : 1.2
// Date            : 2022/11/28
// Modified Date   : 2023/12/16
// License         : MIT
/**************************************************************/

/**
 * @brief Inverter
 * @param[in] Signal
 * @return Inverted signal
 * @attention
 */
module stdINV(
    output y,
    input x
);
//not #(0.01,0.01) u0(y,x);
not u0(y,x);
endmodule

/**
 * @brief Short delay Buffer
 * @param[in] Signal
 * @return Non-inverted signal
 * @attention
 */
module stdBUF(
    output y,
    input x
);
wire yn;
stdINV u0(yn,x);
stdINV u1(y,yn);
endmodule

/**
 * @brief Buffer with output enable
 * @param[in] Signal
 * @param[in] Enable
 * @return Non-inverted signal or Tri-state
 * @attention
 */
module stdBUFZ(
    output y,
    input x,
    input e
);
assign y = e?x:1'bz;
endmodule

/**
 * @brief 2-input AND Gate
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdAND2(
    output y,
    input a,
    input b
);
//and #(0.01,0.01) u0(y,a,b);
and u0(y,a,b);
endmodule

/**
 * @brief 2-input OR Gate
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdOR2(
    output y,
    input a,
    input b
);
//or #(0.01,0.01) u0(y,a,b);
or u0(y,a,b);
endmodule

/**
 * @brief 2-input NAND Gate
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdNAND2(
    output y,
    input a,
    input b
);
//nand #(0.01,0.01) u0(y,a,b);
nand u0(y,a,b);
endmodule

/**
 * @brief 2-input NOR Gate
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdNOR2(
    output y,
    input a,
    input b
);
//nor #(0.01,0.01) u0(y,a,b);
nor u0(y,a,b);
endmodule

/**
 * @brief 2-input XOR Gate
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdXOR2(
    output y,
    input a,
    input b
);
//xor #(0.01,0.01) u0(y,a,b);
xor u0(y,a,b);
endmodule

/**
 * @brief 2-input XNOR Gate
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdXNOR2(
    output y,
    input a,
    input b
);
//xnor #(0.01,0.01) u0(y,a,b);
xnor u0(y,a,b);
endmodule

/**
 * @brief 3-input AND Gate
 * @param[in] Signal
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdAND3(
    output y,
    input a,
    input b,
    input c
);
//assign #(0.01,0.01) y = a & b & c;
assign y = a & b & c;
endmodule

/**
 * @brief 3-input NAND Gate
 * @param[in] Signal
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdNAND3(
    output y,
    input a,
    input b,
    input c
);
//assign #(0.01,0.01) y = ~(a & b & c);
assign y = ~(a & b & c);
endmodule

/**
 * @brief 3-input OR Gate
 * @param[in] Signal
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdOR3(
    output y,
    input a,
    input b,
    input c
);
//assign #(0.01,0.01) y = a & b & c;
assign y = a & b & c;
endmodule

/**
 * @brief 3-input NOR Gate
 * @param[in] Signal
 * @param[in] Signal
 * @param[in] Signal
 * @return Output
 * @attention
 */
module stdNOR3(
    output y,
    input a,
    input b,
    input c
);
//assign #(0.01,0.01) y = ~(a & b & c);
assign y = ~(a & b & c);
endmodule

/**
 * @brief N-input AND Gate
 * @param[in] Signal list
 * @return Output
 * @attention
 */
module stdANDN
#(
    parameter N = 3
)
(
    output y,
    input [N-1:0] x
);
wire rs[N-1:0] /*verilator split_var*/;
genvar i;
generate
    assign rs[0] = x[0];    
    for(i=1;i<N;i=i+1) begin:loop
        assign rs[i] = rs[i-1] & x[i];
    end    
endgenerate
assign y = rs[N-1];
endmodule

/**
 * @brief N-input OR Gate
 * @param[in] Signal list
 * @return Output
 * @attention
 */
module stdORN
#(
    parameter N = 3
)
(
    output y,
    input [N-1:0] x
);
wire rs[N-1:0] /*verilator split_var*/;
genvar i;
generate
    assign rs[0] = x[0];    
    for(i=1;i<N;i=i+1) begin:loop
        assign rs[i] = rs[i-1] | x[i];
    end    
endgenerate
assign y = rs[N-1];
endmodule

/**
 * @brief N-input NAND Gate
 * @param[in] Signal list
 * @return Output
 * @attention
 */
module stdNANDN
#(
    parameter N = 3
)
(
    output y,
    input [N-1:0] x
);
wire rs[N-1:0] /*verilator split_var*/;
genvar i;
generate
    assign rs[0] = x[0];    
    for(i=1;i<N;i=i+1) begin:loop
        assign rs[i] = rs[i-1] & x[i];
    end    
endgenerate
assign y = ~rs[N-1];
endmodule

/**
 * @brief N-input NOR Gate
 * @param[in] Signal list
 * @return Output
 * @attention
 */
module stdNORN
#(
    parameter N = 3
)
(
    output y,
    input [N-1:0] x
);
wire rs[N-1:0] /*verilator split_var*/;
genvar i;
generate
    assign rs[0] = x[0];    
    for(i=1;i<N;i=i+1) begin:loop
        assign rs[i] = rs[i-1] | x[i];
    end    
endgenerate
assign y = ~rs[N-1];
endmodule

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
