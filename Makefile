#Vars
WAV = dump.vcd a.out MoravecDesign.dot MoravecDesign.json MoravecDesign.svg
DOTTESTBENCH = dottestbench
TESTBENCH = testbench

#force make to run the synethesization (iverilog 8 and below), and run wave generation (iverilog x.xx)
wave:
	iverilog '-Wall' design.sv $(TESTBENCH).sv  && unbuffer vvp a.out

#working on getting dot files generation working
dot:
	yosys \
        -p "read_verilog -sv -formal $(DOTTESTBENCH).sv" \
        -p "hierarchy -check -top tb" \
        -p "proc" \
        -p "show -prefix MoravecDesign -notitle -colors 2 -width -format dot"

#also work on getting a renderable svg file
svg:
	yosys \
        -p "read_verilog -sv -formal $(DOTTESTBENCH).sv" \
        -p "hierarchy -check -top tb" \
        -p "proc" \
        -p "write_json MoravecDesign.json"
	netlistsvg -o MoravecDesign.svg MoravecDesign.json
    
#Clean
clean: 
	rm $(WAV)