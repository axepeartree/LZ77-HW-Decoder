library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lz77_decomp is
    port(
        offset:         in std_logic_vector(12 downto 0);
        length:         in std_logic_vector(2 downto 0);
        byte:           in std_logic_vector(7 downto 0);

        data_out:       out std_logic_vector(63 downto 0);

        clock:          in std_logic;
        enable:         in std_logic
    );
end entity lz77_decomp;

architecture behaviour of lz77_decomp is
    -- array of 8191 bytes
    type buf_mem_type is array (2**13 - 1 downto 0) of std_logic_vector(7 downto 0);

    signal s_buffer:            buf_mem_type;
    signal s_buffer_head:       std_logic_vector(12 downto 0) := "1111111111111"; -- head of the circular buffer
    signal s_match_position:    integer := 0; -- only for debugging reasons
begin
    process(clock) is
    begin
        if rising_edge(clock) and enable = '1' then
            -- move the buffer head to it's next position
            if unsigned(s_buffer_head) + unsigned(length) + 1 > 8191 then
                s_buffer_head <= std_logic_vector((unsigned(s_buffer_head) + unsigned(length)) - 8191);
            else
                s_buffer_head <= std_logic_vector((unsigned(s_buffer_head) + unsigned(length)) + 1);
            end if;
        end if;
    end process;
end architecture behaviour;