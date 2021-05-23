./build.sh &&

ghdl -r testbench --wave="testbench.ghw" --stop-time=100ns &&

gtkwave testbench.ghw testbench.gtkw