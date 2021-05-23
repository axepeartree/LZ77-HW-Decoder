ghdl --clean &&
ghdl --remove &&

ghdl -a --workdir=work src/decompressor.vhdl &&
ghdl -e --workdir=work decompressor &&

ghdl -a --workdir=work test/testbench.vhdl &&
ghdl -e --workdir=work testbench

