#Vars
WAV = dump.vcd a.out

#force make to run the synethesization (iverilog 8 and below), and run wave generation (iverilog x.xx)
wave:
	iverilog '-Wall' design.sv testbench.sv  && unbuffer vvp a.out

#Clean
clean: 
	rm $(WAV)