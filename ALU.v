module mux_2_to_1(out, i0, i1, s0);
	//port declarations
	output out;
	input i0, i1;
	input s0;
	wire s0n;
	wire y0, y1;
	//logic
	not(s0n, s0);
	and(y0, s0n, i0); 
	and(y1, s0, i1);
	or(out, y0, y1);
endmodule

module mux_4_to_1(out, i0, i1, i2, i3, s1, s0);
	//port declarations
	output out;
	input i0, i1, i2, i3;
	input s1, s0;
	wire s1n, s0n;
	wire y0, y1, y2, y3;
	//logic
	not(s0n, s0);
	not(s1n, s1);
	and(y0, i0, s1n, s0n);
	and(y1, i1, s1n, s0);
	and(y2, i2, s1, s0n);
	and(y3, i3, s1, s0);
	or(out, y0, y1, y2, y3);
endmodule

module mux_4bit_4_to_1(out, i0, i1, i2, i3, s1, s0);
	//port declarations
	output [3:0] out;
	input [3:0]i0;
	input [3:0]i1;
	input [3:0]i2;
	input [3:0]i3;
	input s1, s0;
	//logic
	mux_4_to_1 mux1(out[0], i0[0], i1[0], i2[0], i3[0], s1, s0);
	mux_4_to_1 mux2(out[1], i0[1], i1[1], i2[1], i3[1], s1, s0);
	mux_4_to_1 mux3(out[2], i0[2], i1[2], i2[2], i3[2], s1, s0);
	mux_4_to_1 mux4(out[3], i0[3], i1[3], i2[3], i3[3], s1, s0);
endmodule

module mux_8_to_1(out, i0, i1, i2, i3, i4, i5, i6, i7, s2, s1, s0);
	//port declarations
	input s2, s1, s0;
	input i0, i1, i2, i3, i4, i5, i6, i7;
	output out;
	wire outTemp1, outTemp2;

	mux_4_to_1 mux1(outTemp1, i0, i1, i2, i3, s1, s0);
	mux_4_to_1 mux2(outTemp2, i4, i5, i6, i7, s1, s0);
	mux_2_to_1 mux3(out, outTemp1, outTemp2, s2);
endmodule

module mux_4bit_8_to_1(out, i0, i1, i2, i3, i4, i5, i6, i7, s2, s1, s0);
	//port declarations 
	output [3:0] out;
	input [3:0] i0, i1, i2, i3, i4, i5, i6, i7;
	input s2, s1, s0;
	
	mux_8_to_1 mux1(out[0], i0[0], i1[0], i2[0], i3[0], i4[0], i5[0], i6[0], i7[0], s2, s1, s0);
	mux_8_to_1 mux2(out[1], i0[1], i1[1], i2[1], i3[1], i4[1], i5[1], i6[1], i7[1], s2, s1, s0);
	mux_8_to_1 mux3(out[2], i0[2], i1[2], i2[2], i3[2], i4[2], i5[2], i6[2], i7[2], s2, s1, s0);
	mux_8_to_1 mux4(out[3], i0[3], i1[3], i2[3], i3[3], i4[3], i5[3], i6[3], i7[3], s2, s1, s0);

endmodule


module opcodeDecoder (out, opcode);
	input [4:0] opcode;
	output [8:0] out;
	
	assign out[8] = opcode[3], //main control 
	out[7] = opcode[4], 
	out[6] = opcode[2], //logic 
	out[5] = opcode[1], 
	out[4] = opcode[0], 
	out[3] = opcode[0], //add/sub
	out[2] = opcode[2], //shift
	out[1] = opcode[1], 
	out[0] = opcode[0];
	
endmodule	

module top (carry, result, in);
	input [12:0] in;
	output carry;
	output [3:0] result;
	
	wire [3:0] a, b;
	wire [4:0] opcode;
	wire [8:0] outFromDecoder;
	
	assign a = in[12:9], b = in[8:5], opcode = in[4:0];
	
	opcodeDecoder decoder(outFromDecoder, opcode);
	ALU topAlu(carry, result, a, b, outFromDecoder [8:7], outFromDecoder [6:4], outFromDecoder[3], outFromDecoder[2:0]);	
	
endmodule

module setLessThan (out, a, b);
	
	output [3:0] out;
	input [3:0] a, b;

	assign out = (a < b) ? 4'b1111 : 4'b0000;
	
endmodule


module leftRightShifter(out, in, select);

	output [3:0] out;
	
	input [3:0] in;
	input [2:0] select;
	
	wire [3:0] leftOut, rightOut;
	wire zero = 1'b0;
	
	//mux_4bit_4_to_1(out, i0, i1, i2, i3, s1, s0);
	mux_4_to_1 rightShiftMux0(rightOut[0], in[0], in[1], in[2], in[3], select[1], select[0]);
	mux_4_to_1 rightShiftMux1(rightOut[1], in[1], in[2], in[3], zero, select[1], select[0]);
	mux_4_to_1 rightShiftMux2(rightOut[2], in[2], in[3], zero, zero, select[1], select[0]);
	mux_4_to_1 rightShiftMux3(rightOut[3], in[3], zero, zero, zero, select[1], select[0]);
	
	mux_4_to_1 leftShiftMux0(leftOut[0], in[0], zero, zero, zero, select[1], select[0]);
	mux_4_to_1 leftShiftMux1(leftOut[1], in[1], in[0], zero, zero, select[1], select[0]);
	mux_4_to_1 leftShiftMux2(leftOut[2], in[2], in[1], in[0], zero, select[1], select[0]);
	mux_4_to_1 leftShiftMux3(leftOut[3], in[3], in[2], in[1], in[0], select[1], select[0]);
	
	mux_4bit_4_to_1 leftorRightMux(out, rightOut, leftOut, 4'b0000, 4'b0000, zero, select[2]);

endmodule 


module FourBitCarryLookAheadAdderWithSub(sum, c4, x, y, c0);
	//Outs
	output [3:0] sum;
	output c4;
	
	//Ins
	input c0;
	input [3:0] x, y;
	
	//Wires
	wire p0, p1, p2, p3, g0, g1, g2, g3, c1, c2, c3;
	
	//Specific wires for sub functionality
	wire y0, y1, y2, y3;
	
	//For c1 and c2
	wire c0p0, g0p1, c0p0p1, g0p1_OR_c0p0p1;
	//For c3
	wire c0p0p1p2, g0p1p2, g1p2, g2_OR_g1p2, g2_OR_g1p2_OR_g0p1p2;
	//For c4
	wire c0p0p1p2p3, g0p1p2p3, g1p2p3, g2p3;
	wire g3_OR_g2p3, g3_OR_g2p3_OR_g1p2p3, g3_OR_g2p3_OR_g1p2p3_OR_g0p1p2p3;
	
	//Xor values for subtraction
	xor(y0, c0, y[0]);
	xor(y1, c0, y[1]);
	xor(y2, c0, y[2]);
	xor(y3, c0, y[3]);
	
	//Determining g values
	and(g0, x[0], y0);
	and(g1, x[1], y1);
	and(g2, x[2], y2);
	and(g3, x[3], y3);
	
	//Determining p values
	xor(p0, x[0], y0);
	xor(p1, x[1], y1);
	xor(p2, x[2], y2);
	xor(p3, x[3], y3);
	
	//Determining c1's value 
	//1) c0p0
	and(c0p0, c0, p0);
	//2) c1 = g0 + c0p0
	or(c1, g0, c0p0);
	
	//Determining c2's value 
	//1) g0 + p1
	and(g0p1, g0, p1);
	//2) c0p0p1
	and(c0p0p1, c0p0, p1);
	//3) g0p1 + c0p0p1 
	or(g0p1_OR_c0p0p1, g0p1, c0p0p1);
	//4) c2 = g1 + g0p0 + c0p0p1
	or(c2, g0p1_OR_c0p0p1, g1);
	
	//Determining c3's value 
	//1) c0p0p1p2
	and(c0p0p1p2, c0p0p1, p2);
	//2) g0p1p2
	and(g0p1p2, g0p1, p2);
	//3) g1p2 
	and(g1p2, g1, p2);
	//4) g2 + g1p2
	or(g2_OR_g1p2, g2, g1p2);
	//5) g2 + g1p2 + g0p1p2
	or(g2_OR_g1p2_OR_g0p1p2, g2_OR_g1p2, g0p1p2);
	// c3 = g2 + g1p2 + g0p1p2 + c0p0p1p2
	or(c3, g2_OR_g1p2_OR_g0p1p2, c0p0p1p2);
	
	//Determining c4's value 
	//1) c0p0p1p2p3
	and(c0p0p1p2p3, c0p0p1p2, p3);
	//2) g0p1p2p3
	and(g0p1p2p3, g0p1p2, p3);
	//3) g1p2p3
	and(g1p2p3, g1p2, p3);
	//4) g2p3
	and(g2p3, g2, p3);
	//5) g3 + g2p3
	or(g3_OR_g2p3, g3, g2p3);
	//6) g3 + g2p3 + g1p2p3
	or(g3_OR_g2p3_OR_g1p2p3, g3_OR_g2p3, g1p2p3);
	//7) g3 + g2p3 + g1p2p3 + g0p1p2p3 
	or(g3_OR_g2p3_OR_g1p2p3_OR_g0p1p2p3, g3_OR_g2p3_OR_g1p2p3, g0p1p2p3);
	//8) c4 = g3 + g2p3 + g1p2p3 + g0p1p2p3 + c0p0p1p2p3
	or(c4, g3_OR_g2p3_OR_g1p2p3_OR_g0p1p2p3, c0p0p1p2p3);

	xor(sum[0], p0, c0);
	xor(sum[1], p1, c1);
	xor(sum[2], p2, c2);
	xor(sum[3], p3, c3);
endmodule


module FourBitLogic(out, x, y, s2, s1, s0);
	//Port Declarations:
	//Outs
	output [3:0] out;
	
	//Ins
	input [3:0] x, y;
	input s0, s1, s2;
	
	//Wires
	wire [3:0] andWire, orWire, xorWire, norWire, notWireX, notWireY, nandWire, xnorWire;
	
	//perform logic
	and(andWire[0], x[0], y[0]);
	and(andWire[1], x[1], y[1]);
	and(andWire[2], x[2], y[2]);
	and(andWire[3], x[3], y[3]);
	
	or(orWire[0], x[0], y[0]);
	or(orWire[1], x[1], y[1]);
	or(orWire[2], x[2], y[2]);
	or(orWire[3], x[3], y[3]);
	
	xor(xorWire[0], x[0], y[0]);
	xor(xorWire[1], x[1], y[1]);
	xor(xorWire[2], x[2], y[2]);
	xor(xorWire[3], x[3], y[3]);

	nor(norWire[0], x[0], y[0]);
	nor(norWire[1], x[1], y[1]);
	nor(norWire[2], x[2], y[2]);
	nor(norWire[3], x[3], y[3]);

	not(notWireX[0], x[0]);
	not(notWireX[1], x[1]);
	not(notWireX[2], x[2]);
	not(notWireX[3], x[3]);

	not(notWireY[0], y[0]);
	not(notWireY[1], y[1]);
	not(notWireY[2], y[2]);
	not(notWireY[3], y[3]);	

	nand(nandWire[0], x[0], y[0]);
	nand(nandWire[1], x[1], y[1]);
	nand(nandWire[2], x[2], y[2]);
	nand(nandWire[3], x[3], y[3]);
	
	xnor(xnorWire[0], x[0], y[0]);
	xnor(xnorWire[1], x[1], y[1]);
	xnor(xnorWire[2], x[2], y[2]);
	xnor(xnorWire[3], x[3], y[3]);

	//Now call the 4 bit 8 to 1 mux to choose what logic operation to perform
	mux_4bit_8_to_1 mux8to1(out, andWire, orWire, xorWire, norWire, notWireX, notWireY, nandWire, xnorWire, s2, s1, s0);
	
endmodule

module ALU(carry, result, a, b, mainControl, controlForLogic, cin, controlForShift);
	output carry;
	output [3:0] result;
	
	input cin;
	input [1:0] mainControl;
	input [2:0] controlForShift, controlForLogic;
	input [3:0] a, b;
	
	wire [3:0] outFromLogic, outFromAddSub, shift_a_Wire, outFromLessThan;
	
	FourBitLogic logicComponent(outFromLogic, a, b, controlForLogic[2], controlForLogic[1], controlForLogic[0]);
	FourBitCarryLookAheadAdderWithSub addSub(outFromAddSub, carry, a, b, cin);
	leftRightShifter Shift_a(shift_a_Wire, a, controlForShift);
	setLessThan isLessThan(outFromLessThan, a, b);

	
	//(out, i0, i1, i2, i3, s1, s0)	
	mux_4bit_4_to_1 ALU_Mux(result, outFromLogic, outFromAddSub, shift_a_Wire, outFromLessThan, mainControl[1], mainControl[0]);

endmodule

//we now need a module for simulation
module stimulus; //ports not given, there could be no ports

	reg [12:0] IN;
	wire [3:0] RESULT;
	wire CARRY;

	top testALU(CARRY, RESULT, IN);
	
	initial 
		begin
			$monitor($time," A = %b%b%b%b, B = %b%b%b%b,\nOPCODE = %b%b%b%b%b, --- RESULT = %b%b%b%b, CARRY = %b\n\n", IN[12], IN[11], IN[10], IN[9], IN[8], IN[7], IN[6], IN[5], IN[4], IN[3], IN[2], IN[1], IN[0], RESULT[3], RESULT[2], RESULT[1], RESULT[0], CARRY);
		end
	
	initial
		begin

			$display("Perform logic operations");
			$display("\n---------------------------------------------------------------------------\n");		
			$display("AND:\n");		
			IN = 14'b1110_1100_00000;
			#5 $display("OR:\n");
			IN = 14'b1110_1100_00001;
			#5 $display("XOR:\n");
			IN = 14'b1110_1100_00010;
			#5 $display("NOR:\n");
			IN = 14'b1110_1100_00011;
			#5 $display("NOTA:\n");
			IN = 14'b1110_1100_00100;
			#5 $display("NOTB:\n");
			IN = 14'b1110_1100_00101;
			#5 $display("NAND:\n");
			IN = 14'b1110_1100_00110;
			#5 $display("XNOR:\n");
			IN = 14'b1110_1100_00111;
	
			#5 $display("Perform Add/Sub operations");
			#5 $display("\n---------------------------------------------------------------------------\n");
			#5 $display("A+B:");
			IN = 14'b1110_1100_10000;
			#5 $display("A-B:");
			IN = 14'b1110_1100_10001;
			
			#5 $display("Perform shift operations");
			#5 $display("\n---------------------------------------------------------------------------\n");			
			#5 $display("Right 0 bits:\n");
			IN = 14'b1111_1100_01000;
			#5 $display("Right 1 bit:\n");
			IN = 14'b1111_1100_01001;
			#5 $display("Right 2 bits:\n");
			IN = 14'b1111_1100_01010;
			#5 $display("Right 3 bits:\n");
			IN = 14'b1111_1100_01011;
			#5 $display("Left 0 bits:\n");			
			IN = 14'b1111_1100_01100;
			#5 $display("Left 1 bit:\n");
			IN = 14'b1111_1100_01101;
			#5 $display("Left 2 bits:\n");
			IN = 14'b1111_1100_01110;
			#5 $display("Left 3 bits:\n");
			IN = 14'b1111_1100_01111;	
			
			#5 $display("Set Less Than");
			#5 $display("\n---------------------------------------------------------------------------\n");			
			IN = 14'b1111_1100_11000;	

			#5 $display("Perform logic operations");
			#5 $display("\n---------------------------------------------------------------------------\n");		
			#5 $display("AND:\n");
			IN = 14'b0001_1001_00000;	
			#5 $display("OR:\n");
			IN = 14'b0101_1101_00001;	
			#5 $display("XOR:\n");
			IN = 14'b0101_1001_00010;	
			#5 $display("NOR:\n");
			IN = 14'b0101_1001_00011;	
			#5 $display("NOTA:\n");
			IN = 14'b1010_1100_00100;
			#5 $display("NOTB:\n");
			IN = 14'b1010_1100_00101;
			#5 $display("NAND:\n");
			IN = 14'b1010_1100_00110;
			#5 $display("XNOR:\n");
			IN = 14'b1010_1100_00111;
			
			#5 $display("Perform Add/Sub operations");
			#5 $display("\n---------------------------------------------------------------------------\n");
			#5 $display("A+B:");
			IN = 14'b1010_1100_10000;
			#5 $display("A-B:");
			IN = 14'b1010_1100_10001;

			#5 $display("Perform shift operations");
			#5 $display("\n---------------------------------------------------------------------------\n");			
			#5 $display("Right 0 bits:\n");
			IN = 14'b1010_1100_01000;
			#5 $display("Right 1 bit:\n");
			IN = 14'b1010_1100_01001;
			#5 $display("Right 2 bits:\n");
			IN = 14'b1010_1100_01010;
			#5 $display("Right 3 bits:\n");
			IN = 14'b1010_1100_01011;
			#5 $display("Left 0 bits:\n");
			IN = 14'b1010_1100_01100;
			#5 $display("Left 1 bit:\n");
			IN = 14'b1010_1100_01101;
			#5 $display("Left 2 bits:\n");
			IN = 14'b1010_1100_01110;
			#5 $display("Left 3 bits:\n");
			IN = 14'b1010_1100_01111;
			
			#5 $display("Set Less Than");
			#5 $display("\n---------------------------------------------------------------------------\n");			
			IN = 14'b1010_1100_11000;	

		end
endmodule
