ghdl --clean &&
ghdl --remove &&

echo "Building decoder"

ghdl -a src/lz77_decoder.vhdl &&
ghdl -e lz77_decoder &&

echo "Building testbench"

ghdl -a test/testbench.vhdl &&
ghdl -e testbench