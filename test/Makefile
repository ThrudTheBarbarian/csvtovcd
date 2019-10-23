all:
	../build/Release/csvtovcd -i test.csv -o dut_tb.v -m dut -mP
	iverilog -o dut.vvp dut_tb.v dut.v 
	./dut.vvp

clean:
	rm -f dut_tb.v simple.vcd dut.vvp