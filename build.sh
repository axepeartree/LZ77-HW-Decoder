ghdl --clean &&
ghdl --remove &&

ghdl -a --workdir=work src/lz77_decomp.vhdl &&
ghdl -e --workdir=work lz77_decomp &&

ghdl -a --workdir=work test/testbench.vhdl &&
ghdl -e --workdir=work testbench

