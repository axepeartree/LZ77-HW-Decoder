library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity testbench is
end testbench;

architecture behaviour of testbench is
    type rom is array (2**8 - 1 downto 0) of std_logic_vector(23 downto 0);

    component lz77_decomp
        port(
            offset:         in std_logic_vector(12 downto 0);
            length:         in std_logic_vector(2 downto 0);
            byte:           in std_logic_vector(7 downto 0);
            data_out:       out std_logic_vector(63 downto 0);
            write_data:     out std_logic;

            clock:          in std_logic;
            enable:         in std_logic
        );
    end component lz77_decomp;

    for dec_0: lz77_decomp use entity work.lz77_decomp;
    signal s_clock:             std_logic := '0';
    signal s_enable:            std_logic := '1';
    signal s_write:             std_logic;
    signal s_offset:            std_logic_vector(12 downto 0);
    signal s_length:            std_logic_vector(2 downto 0);
    signal s_byte:            std_logic_vector(7 downto 0);
    signal s_rom:               rom := (
        0 => x"00000A",
        1 => x"00000B",
        2 => x"00000C",
        3 => x"00120A",
        4 => x"002B0F",
        5 => x"00120B",
        6 => x"001B0E",
        others => x"000000"
    );
    signal s_mem_ptr:             integer := 0;
begin
    dec_0: lz77_decomp port map (
        clock       => s_clock,
        enable      => s_enable,
        write_data  => s_write,
        offset      => s_offset,
        length      => s_length,
        byte        => s_byte
    );
    process
        variable v_token: std_logic_vector(23 downto 0);
        variable v_mem_ptr: integer := s_mem_ptr;
    begin
        v_token := s_rom(s_mem_ptr);
        s_mem_ptr <= s_mem_ptr + 1;

        s_offset <= v_token(23 downto 11);
        s_length <= v_token(10 downto 8);
        s_byte <= v_token(7 downto 0);

        s_clock <= '1';
        wait for 5 ns;
        s_clock <= '0';
        wait for 5 ns;
    end process;
end architecture behaviour;