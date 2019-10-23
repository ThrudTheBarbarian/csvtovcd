
initial begin
    $dumpfile("simple.vcd");
    $dumpvars(0,clk);
    $monitor("clk is %b", clk);
end

