module two_input_mux
  (
    input wire selector,
    input wire [31:0] in0, in1,
    output wire [31:0] out
  );
  assign out = (selector == 0) ? in0 : in1;
endmodule