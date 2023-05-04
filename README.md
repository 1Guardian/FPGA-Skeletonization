# Project
FPGA Skeletonization implementation

# Class
University of Missouri St Louis: CS 6420

## Functionality
The provided files are split into 4 main sections:

The Harris-FPGA-Design has the design for the FPGA implementing skeletonization via the Harris corner detection and thinning written in system verilog

The Moravec-FPGA-Design has the design for the FPGA implementing skeletonization via Moravec's corner detection and thinning written in system verilog

The Python Algorithms contain non-production blueprints to how I learned and mapped out the algorithms I implemented in verilog

The Block Diagrams contain the output for both designs from yosys, showing successful synthesis as well as rough svg mapping of each design

# Requirements for building
  Node.JS: 
    https://nodejs.org/en/download/ (*NIX, Linux, And Windows)

  NPM:
    https://nodejs.org/en/download/ (*NIX, Linux, And Windows)

  Yosys: 
    You will need to fetch yosys from their git:
    https://github.com/YosysHQ/yosys

  NetlistSVG:
    Used for generating blocks after synthesis:
    https://github.com/nturley/netlistsvg
  
  Icarus Verilog:
    Used for waveform generation and simulation:
    https://github.com/steveicarus/iverilog

# Build Process
  For each design, there are independent make files; the top most make file handles block generation and synthesis and routing to JSON files. The inner modules have their own make files for generating waveforms via icarus verilog to check cycle accuracy.

# Notes
  These designs are not optimized due to time constraints, and overall may look like the work of a novice to system verilog. That is simply because I am! This project is the basis for a paper that corrects and proposes a new design for a proposed skeletonization via corner retention and thinning published in 2019. It served as my semester project as well as my entire project to learn how FPGAs work, how Verilog works, how System Verilog works, and how to think like a hardware designer instead of a programmer.