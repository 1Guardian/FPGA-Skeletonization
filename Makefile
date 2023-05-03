#Vars
WAV = dump.vcd a.out MoravecDesign.dot MoravecDesign.json MoravecDesign.svg
DOTTESTBENCH = dottestbench
TESTBENCH = testbench

#working on getting dot files generation working
dot:
	yosys \
        -p "read_verilog -sv -formal $(DOTTESTBENCH).sv" \
        -p "hierarchy -check -top tb" \
        -p "proc" \
        -p "show -prefix MoravecDesign -notitle -colors 2 -width -format dot"

#also work on getting a renderable svg file
MoravecBlock: json-M svg-M
HarrisBlock: json-H svg-H

#make Moravec block json files and svgs
svg-M:
	netlistsvg -o Block-Diagrams/Moravec/mainController.svg Block-Diagrams/Moravec/mainController.json
	netlistsvg -o Block-Diagrams/Moravec/centerMask.svg Block-Diagrams/Moravec/centerMask.json
	netlistsvg -o Block-Diagrams/Moravec/kernelRam.svg Block-Diagrams/Moravec/kernelRam.json
	netlistsvg -o Block-Diagrams/Moravec/design.svg Block-Diagrams/Moravec/design.json
	netlistsvg -o Block-Diagrams/Moravec/writeController.svg Block-Diagrams/Moravec/writeController.json
	netlistsvg -o Block-Diagrams/Moravec/counter.svg Block-Diagrams/Moravec/counter.json
	netlistsvg -o Block-Diagrams/Moravec/Moravec-Flip-Flops.svg Block-Diagrams/Moravec/Moravec-Flip-Flops.json
	rm Block-Diagrams/Moravec/*.json

json-M:
	yosys \
		-p "read_verilog -sv -formal ./Moravec-FPGA-Design/design.sv ./Moravec-FPGA-Design/Moravec-Flip-Flops.sv ./Moravec-FPGA-Design/kernelRam.sv ./Moravec-FPGA-Design/counter.sv ./Moravec-FPGA-Design/writeController.sv ./Moravec-FPGA-Design/centerMask.sv ./Moravec-FPGA-Design/mainController.sv" \
		-p "hierarchy -check -top mainController" \
		-p "proc" \
		-p "write_json Block-Diagrams/Moravec/mainController.json" \
		-p "read_verilog -sv -formal ./Moravec-FPGA-Design/kernelRam.sv ./Moravec-FPGA-Design/centerMask.sv" \
		-p "hierarchy -check -top centerMask" \
		-p "proc" \
		-p "write_json Block-Diagrams/Moravec/centerMask.json" \
		-p "read_verilog -sv -formal ./Moravec-FPGA-Design/kernelRam.sv" \
		-p "hierarchy -check -top kernelRam" \
		-p "proc" \
		-p "write_json Block-Diagrams/Moravec/kernelRam.json" \
		-p "read_verilog -sv -formal ./Moravec-FPGA-Design/design.sv" \
		-p "hierarchy -check -top v_rams_09" \
		-p "proc" \
		-p "write_json Block-Diagrams/Moravec/design.json" \
		-p "read_verilog -sv -formal ./Moravec-FPGA-Design/writeController.sv" \
		-p "hierarchy -check -top writeController" \
		-p "proc" \
		-p "write_json Block-Diagrams/Moravec/writeController.json" \
		-p "read_verilog -sv -formal ./Moravec-FPGA-Design/counter.sv" \
		-p "hierarchy -check -top counter" \
		-p "proc" \
		-p "write_json Block-Diagrams/Moravec/counter.json" \
		-p "read_verilog -sv -formal ./Moravec-FPGA-Design/Moravec-Flip-Flops.sv" \
		-p "hierarchy -check -top MoravecFF" \
		-p "proc" \
		-p "write_json Block-Diagrams/Moravec/Moravec-Flip-Flops.json"

#make Harris block json files and svgs
svg-H:
	netlistsvg -o Block-Diagrams/Harris/mainController.svg Block-Diagrams/Harris/mainController.json
	
	netlistsvg -o Block-Diagrams/Harris/kernelRam.svg Block-Diagrams/Harris/kernelRam.json
	netlistsvg -o Block-Diagrams/Harris/design.svg Block-Diagrams/Harris/design.json
	netlistsvg -o Block-Diagrams/Harris/writeController.svg Block-Diagrams/Harris/writeController.json
	netlistsvg -o Block-Diagrams/Harris/counter.svg Block-Diagrams/Harris/counter.json
	netlistsvg -o Block-Diagrams/Harris/Gaussian.svg Block-Diagrams/Harris/Gaussian.json
	netlistsvg -o Block-Diagrams/Harris/SobelsOperator.svg Block-Diagrams/Harris/SobelsOperator.json
	rm Block-Diagrams/Harris/*.json

json-H:
	yosys \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/design.sv ./Harris-FPGA-Design/SobelsOperator.sv ./Harris-FPGA-Design/gaussian.sv ./Harris-FPGA-Design/kernelRam.sv ./Harris-FPGA-Design/counter.sv ./Harris-FPGA-Design/writeController.sv ./Harris-FPGA-Design/centerMask.sv ./Harris-FPGA-Design/mainController.sv" \
		-p "hierarchy -check -top mainController" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/mainController.json" \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/kernelRam.sv ./Harris-FPGA-Design/centerMask.sv" \
		-p "hierarchy -check -top centerMask" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/centerMask.json" \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/kernelRam.sv" \
		-p "hierarchy -check -top kernelRam" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/kernelRam.json" \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/design.sv" \
		-p "hierarchy -check -top v_rams_09" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/design.json" \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/writeController.sv" \
		-p "hierarchy -check -top writeController" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/writeController.json" \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/counter.sv" \
		-p "hierarchy -check -top counter" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/counter.json" \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/SobelsOperator.sv" \
		-p "hierarchy -check -top Sobels" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/SobelsOperator.json" \
		-p "read_verilog -sv -formal ./Harris-FPGA-Design/gaussian.sv" \
		-p "hierarchy -check -top Gaussian" \
		-p "proc" \
		-p "write_json Block-Diagrams/Harris/Gaussian.json"
        
#Clean
clean: 
	rm ./Block-Diagrams/Harris/*.svg
	rm ./Block-Diagrams/Moravec/*.svg