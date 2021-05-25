./build.sh &&

ghdl -r testbench --wave="testbench.ghw" --stop-time=200ns &&
gtkwave testbench.ghw testbench.gtkw