# LZ77 Decompressor - Hardware implementation

A VHDL-based LZ77 decompressor.

## General idea

Right now, the decoder entity is:

```vhdl
entity lz77_decoder is
    port(
        offset:         in std_logic_vector(12 downto 0);
        length:         in std_logic_vector(2 downto 0);
        byte:           in std_logic_vector(7 downto 0);
        data_out:       out std_logic_vector(63 downto 0);
        write_data:     out std_logic;
        clock:          in std_logic;
        enable:         in std_logic
    );
end entity lz77_decoder;
```

It should decode one token per cycle and write the output do `data_out`. The output is only valid if the `write_data` flag is enabled.

## Building and running the testbench

You'll need:

- `ghdl`
- `gtkwave`

To run the testbench, execute `./run.sh` on the root directory (`./build.sh` will only build the files).

You'll also need to create a `testbench.gtkw` file if you want to see the waveforms.

## Improvements

- Use generic widths for the token and output bus.
- Try to run some stuff in parallel.

## Acknowledgements

This was built as an assignment for a "Reconfigurable Logic/Computing" class.