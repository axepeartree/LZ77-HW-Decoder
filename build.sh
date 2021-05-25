ghdl --clean &&
ghdl --remove &&

echo "Building decoder"

ghdl -a src/lz77_decoder.vhdl &&
ghdl -e lz77_decoder &&

echo "Building rom"

ghdl -a src/rom.vhdl &&
ghdl -e rom &&

echo "Building tb"

ghdl -a test/lz77_decoder_tb.vhdl &&
ghdl -e lz77_decoder_tb &&

ghdl -a test/testbench.vhdl &&
ghdl -e testbench