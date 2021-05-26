library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity testbench is
end testbench;

architecture behaviour of testbench is
    type file_t is file of integer;
    type rom is array (2**8 - 1 downto 0) of std_logic_vector(23 downto 0);
    signal s_clock:             std_logic := '0';
    signal s_enable:            std_logic := '1';
    signal s_write:             std_logic;
    signal s_offset:            std_logic_vector(12 downto 0);
    signal s_length:            std_logic_vector(2 downto 0);
    signal s_byte:              std_logic_vector(7 downto 0);
    signal s_data_out:          std_logic_vector(63 downto 0);
    signal s_rom:               rom := (
        0 => x"00000A",
        1 => x"00090B",
        2 => x"00000C",
        3 => x"00120E",
        4 => x"001A0F",
        5 => x"00240A",
        6 => x"00340A",
        others => x"000000"
    );
    signal s_mem_ptr:             integer := 0;
    file out_buf:        file_t;
begin
    decoder_inst: entity work.lz77_decoder port map(
        clock       => s_clock,
        enable      => s_enable,
        write_data  => s_write,
        offset      => s_offset,
        length      => s_length,
        data_out    => s_data_out,
        byte        => s_byte
    );

    file_open(out_buf, "./output/ram", write_mode);

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

        if s_write = '1' then
            write(out_buf, to_integer(unsigned(s_data_out(31 downto 0))));
            write(out_buf, to_integer(unsigned(s_data_out(63 downto 32))));
        end if;

        s_clock <= '0';
        wait for 5 ns;
    end process;
end architecture behaviour;