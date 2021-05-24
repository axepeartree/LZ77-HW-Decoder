./build.sh &&

ghdl -r testbench --wave="testbench.ghw" --stop-time=400ns &&

gtkwave testbench.ghw testbench.gtkw