library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity testbench is
end testbench;

architecture behaviour of testbench is
    component lz77_decomp
        port(
            offset:         in std_logic_vector(12 downto 0);
            length:         in std_logic_vector(2 downto 0);
            byte:           in std_logic_vector(7 downto 0);
            data_out:       out std_logic_vector(63 downto 0);

            clock:          in std_logic;
            enable:         in std_logic
        );
    end component lz77_decomp;

    for dec_0: lz77_decomp use entity work.lz77_decomp;
    signal s_clock:             std_logic;
    signal s_enable:            std_logic;
    signal s_offset:            std_logic_vector(12 downto 0) := "0000000000000";
    signal s_length:            std_logic_vector(2 downto 0) := "000";
    signal s_byte:              std_logic_vector(7 downto 0) := "00000000";
begin
    dec_0: lz77_decomp port map (
        clock       => s_clock,
        enable      => s_enable,
        offset      => s_offset,
        length      => s_length,
        byte        => s_byte
    );
    process
    begin
        s_enable <= '1';
        s_length <= "000";
        s_offset <= "0000000000001";

        s_clock <= '0';
        wait for 5 ns;
        s_clock <= '1';
        wait for 5 ns;
    end process;
end architecture behaviour;