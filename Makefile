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
MoravecBlock: json svg

#make Moravec block json files and svgs
svg:
	netlistsvg -o Block-Diagrams/Moravec/mainController.svg Block-Diagrams/Moravec/mainController.json
	netlistsvg -o Block-Diagrams/Moravec/centerMask.svg Block-Diagrams/Moravec/centerMask.json
	netlistsvg -o Block-Diagrams/Moravec/kernelRam.svg Block-Diagrams/Moravec/kernelRam.json
	netlistsvg -o Block-Diagrams/Moravec/design.svg Block-Diagrams/Moravec/design.json
	netlistsvg -o Block-Diagrams/Moravec/writeController.svg Block-Diagrams/Moravec/writeController.json
	netlistsvg -o Block-Diagrams/Moravec/counter.svg Block-Diagrams/Moravec/counter.json
	rm Block-Diagrams/Moravec/*.json

json:
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
        
#Clean
clean: 
	rm $(WAV)
        rm ./Block-Diagrams/Moravec/*.svg