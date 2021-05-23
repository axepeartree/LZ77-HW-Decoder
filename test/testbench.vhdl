library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity testbench is
end testbench;

architecture behaviour of testbench is
    component decompressor
        port (
            clock:      in std_logic;
            offset:     in std_logic_vector(11 downto 0);
            length:     in std_logic_vector(3 downto 0);
            byte:       in std_logic_vector(7 downto 0)
        );
    end component decompressor;

    for dec_0: decompressor use entity work.decompressor;
    signal s_clock: std_logic;
    signal s_offset:     std_logic_vector(11 downto 0);
    signal s_length:     std_logic_vector(3 downto 0);
    signal s_byte:       std_logic_vector(7 downto 0);
begin
    dec_0: decompressor port map (
        clock => s_clock,
        offset => s_offset,
        length => s_length,
        byte => s_byte
    );
    process
    begin
        s_length <= b"0010";

        s_clock <= '0';
        wait for 5 ns;
        s_clock <= '1';
        wait for 5 ns;

        s_clock <= '0';
        wait for 5 ns;
        s_clock <= '1';
        wait for 5 ns;

        s_clock <= '0';
        wait for 5 ns;
        s_clock <= '1';
        wait for 5 ns;

    end process;
end architecture behaviour;